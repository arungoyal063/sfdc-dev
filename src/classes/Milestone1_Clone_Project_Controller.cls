/* 
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer. 
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class Milestone1_Clone_Project_Controller {
    
    public Milestone1_Project__c rec {get; set;}
    public Milestone1_Project__c dummyProj {get; set;}
    private List<Milestone1_Milestone__c> milestones {get; set;}
    private List<Milestone1_Task__c> tasks {get; set;}
    private List<User> statusList{get; set;}
    public Boolean isProjOwnerActive{get;set;}
    public boolean isInactiveUserToBeReplaced{get;set;}
    
    public Milestone1_Clone_Project_Controller(ApexPages.StandardController stc){
        //query project record
        rec = [SELECT Id,
                      Name,
                      Deadline__c,
                      Description__c,
                      Status__c,
                      Total_Expense_Budget__c,
                      Total_Hours_Budget__c,
                      KickOff__c,
                      OwnerId                      
               FROM Milestone1_Project__c
               WHERE Id = :stc.getId()
              ];        
        
        //query milestone records
        milestones = [SELECT Id,
                             Name,
                             Parent_Milestone__c,
                             Complete__c,
                             Deadline__c,
                             Description__c,
                             Expense_Budget__c,
                             Hours_Budget__c,
                             OwnerId,
                             KickOff__c
                      FROM Milestone1_Milestone__c
                      WHERE Project__c = :rec.Id
                     ];
        
        //query task records 
        tasks = [SELECT Id,
                        Name,
                        Project_Milestone__c,
                        User_Story__c,
                        Assigned_To__c,
                        Complete__c,
                        Description__c,
                        Start_Date__c,
                        Due_Date__c,
                        Priority__c,
                        Task_Stage__c,
                        Class__c,
                        Blocked__c,
                        Blocked_Reason__c,
                        Last_Email_Received__c,
                        Estimated_Hours__c,
                        Estimated_Expense__c
                 FROM Milestone1_Task__c
                 WHERE Project_Milestone__r.Project__c = :rec.Id
                ];
                
        dummyProj = new Milestone1_Project__c();
        dummyProj.Name = 'Copy of ' + rec.Name;      
        statusList = [SELECT IsActive from User where id = :rec.OwnerId];
        if(statusList  != null && statusList.size() > 0 )
            isProjOwnerActive = statusList[0].IsActive;
    }
    
    public PageReference createClone(){      
        Savepoint preSave = Database.setSavepoint(); //set savepoint so we can rollback the whole save if there are errors
        PageReference pageReference = null;
        try{
            
          if(isProjOwnerActive == false){
                if(dummyProj.OwnerId == null){
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,system.label.Milestone1_InactiveUsersError);
                   ApexPages.addMessage(myMsg);
                   isInactiveUserToBeReplaced = true;
                   return pageReference;
                }if(dummyProj.OwnerId != null){
                    rec.ownerId = dummyProj.OwnerId;                 
                }
            }             
            
            //create new project record
            rec.Name = dummyProj.Name;
            
            Milestone1_Project__c newProj = Milestone1_Clone_Utility.cloneProject(rec);
            insert newProj;
            //separate milestone records into parents and subs
            List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
            List<Milestone1_Milestone__c> bottomMilestones = new List<Milestone1_Milestone__c>();
            for(Milestone1_Milestone__c oldMS : milestones){
                if(oldMS.Parent_Milestone__c == null){
                    topMilestones.add(oldMS);
                } else {
                    bottomMilestones.add(oldMS);
                }
            }            
            //clone and insert top milestone records
            Map<String, Milestone1_Milestone__c> newTopMilestoneMap = Milestone1_Clone_Utility.cloneMilestonesIntoMap(topMilestones);
            for(Milestone1_Milestone__c newMS : newTopMilestoneMap.values()){
                newMS.Project__c = newProj.Id;
            }
            insert newTopMilestoneMap.values();
            
            //clone and insert sub milestone records
            Map<String, Milestone1_Milestone__c> newBottomMilestoneMap = Milestone1_Clone_Utility.cloneMilestonesIntoMap(bottomMilestones);
            for(Milestone1_Milestone__c newMS : newBottomMilestoneMap.values()){
                newMS.Project__c = newProj.Id;
                newMS.Parent_Milestone__c = newTopMilestoneMap.get(newMS.Parent_Milestone__c).Id;
            }
            insert newBottomMilestoneMap.values();
            //collect all milestones into one map
            Map<String, Milestone1_Milestone__c> allNewMilestoneMap = new Map<String, Milestone1_Milestone__c>();
            allNewMilestoneMap.putAll(newTopMilestoneMap);
            allNewMilestoneMap.putAll(newBottomMilestoneMap);            
            
            
            list<User_Story__c> userStoryList = new list<User_Story__c>([SELECT Milestone1_Milestone__c, Id, Name__c, Backlog__c, Feature_Request__c, (Select Id, Name__c, Backlog__c, Feature_Request__c, Milestone1_Milestone__c From Feature_Requests__r) FROM User_Story__c WHERE Milestone1_Milestone__c IN:milestones]);
            //list<User_Story__c> allUserStoryList = new list<User_Story__c>([SELECT Milestone1_Milestone__c, Id, Name__c, Backlog__c, Feature_Request__c, (Select Id From Feature_Requests__r) FROM User_Story__c WHERE Id IN:userStoryList OR Feature_Request__c IN:userStoryList]);
            //separate user story records into parents and subs
            /*List<User_Story__c> topUserStory = new List<User_Story__c>();
            List<User_Story__c> bottomUserStory = new List<User_Story__c>();
            for(User_Story__c oldUS : userStoryList){
                //if(oldUS.Feature_Requests__r == null || oldUS.Feature_Requests__r.isEmpty()){
                    topUserStory.add(oldUS);
                //} else {
                	for(User_Story__c childUS : oldUS.Feature_Requests__r){
                		bottomUserStory.add(childUS);
                	}
                    //bottomUserStory.add(oldUS);
                //}
            }*/
            List<Map<String, Object>> userStoryTree = new List<Map<String, Object>>();
            for(User_Story__c uStory : userStoryList)
            {
            	Map<String, Object> userStory = new Map<String, Object>();
            	userStory.put('userStory',uStory);
            	List<Map<String, Object>> children = new List<Map<String, Object>>();
                for(User_Story__c child : uStory.Feature_Requests__r)
                {
                	List<User_Story__c> aChild = new List<User_Story__c>();
                	aChild.add(child); 
                	children.add(Milestone1_Clone_Utility.getUserListChildren(aChild));
                }
            	userStory.put('children',children);
            	userStoryTree.add(userStory);
            }
            system.debug('userStoryTree>>>>>>>>>>>' + userStoryTree);
            Map<String, User_Story__c> recMap = new Map<String, User_Story__c>();
            Milestone1_Clone_Utility.cloneUserStoryIntoMap2(userStoryTree, recMap, allNewMilestoneMap, null, 1);
            system.debug('<<<<<<<<<recMap'+ recMap);
            /*system.debug('topUserStory>>>>>>>>>>>' + topUserStory);
            system.debug('bottomUserStory>>>>>>>>>>>' + bottomUserStory);
            //clone and insert top user story records
            Map<String, User_Story__c> newTopUserStoryMap = Milestone1_Clone_Utility.cloneUserStoryIntoMap(topUserStory);
            for(User_Story__c newUS : newTopUserStoryMap.values()){
            	if(allNewMilestoneMap.get(newUS.Milestone1_Milestone__c) != null)
                	newUS.Milestone1_Milestone__c = allNewMilestoneMap.get(newUS.Milestone1_Milestone__c).Id;
            }
            insert newTopUserStoryMap.values();
            
            //clone and insert sub user Story records
            Map<String, User_Story__c> newBottomUserStoryMap = Milestone1_Clone_Utility.cloneUserStoryIntoMap(bottomUserStory);
            for(User_Story__c newUS : newBottomUserStoryMap.values()){
            	if(allNewMilestoneMap.get(newUS.Milestone1_Milestone__c) != null)
                	newUS.Milestone1_Milestone__c = allNewMilestoneMap.get(newUS.Milestone1_Milestone__c).Id;
                if(newTopUserStoryMap.get(newUS.Feature_Request__c) != null)
                	newUS.Feature_Request__c = newTopUserStoryMap.get(newUS.Feature_Request__c).Id;
            }
            insert newBottomUserStoryMap.values();
            //collect all milestones into one map
            Map<String, User_Story__c> allNewUserStoryMap = new Map<String, User_Story__c>();
            allNewUserStoryMap.putAll(newTopUserStoryMap);
            allNewUserStoryMap.putAll(newBottomUserStoryMap);*/
            
            /*// To clone User stories
            map<Id,User_Story__c> objUS = new map<Id,User_Story__c>([SELECT Milestone1_Milestone__c, Id, Name__c, Backlog__c FROM User_Story__c WHERE Milestone1_Milestone__c IN:milestones]);
            Map<String, User_Story__c> newUserStoryMap = Milestone1_Clone_Utility.cloneUserStoryIntoMap(objUS.values());
            for(User_Story__c newUS : newUserStoryMap.values()){
                newUS.Milestone1_Milestone__c = allNewMilestoneMap.get(newUS.Milestone1_Milestone__c).Id;
            }
            insert newUserStoryMap.values();
            list<User_Story__c> toUserStoryInsert = new list<User_Story__c>();
            for(User_Story__c us:objUS.values()){
            	User_Story__c tmpUserStory = us.clone(false);
            	tmpUserStory.Milestone1_Milestone__c = allNewMilestoneMap.get(us.Milestone1_Milestone__c).Id;
            	toUserStoryInsert.add(tmpUserStory);
            }
            if(!toUserStoryInsert.isEmpty()){
            	insert toUserStoryInsert;
        	}
        	for(User_Story__c us:toUserStoryInsert){
        		if(objUS.get(us.Id) != null){
        			for(Milestone1_Task__c t:objUS.get(us.Id).Tasks__r){
		        		t.User_Story__c = us.Id;
		        		toTaskInsert.add(t.clone(false));
		        	}
        		}	        	  
        	} 
        	if(!toTaskInsert.isEmpty()){
        		insert toTaskInsert;
    		}*/
    		 
            //clone and insert task records
            List<Milestone1_Task__c> newTasks = Milestone1_Clone_Utility.cloneTasksIntoList(tasks);
            for(Milestone1_Task__c newTask : newTasks){
                newTask.Project_Milestone__c = allNewMilestoneMap.get(newTask.Project_Milestone__c).Id;
                if(recMap.get(newTask.User_Story__c) != null){
                	system.debug('<<<<<<recMap.get(newTask.User_Story__c).Id'+ recMap.get(newTask.User_Story__c).Id);
                	newTask.User_Story__c = recMap.get(newTask.User_Story__c).Id;
                }
                /*if(allNewUserStoryMap.get(newTask.User_Story__c) != null){
                	newTask.User_Story__c = allNewUserStoryMap.get(newTask.User_Story__c).Id;
                }*/
            }
            insert newTasks;
            
            //direct user to cloned project's detail page
            return new ApexPages.StandardController(newProj).view();
         
        }catch(Exception e){
            ApexPages.addMessages(e); //show save error(s) on the visualforce page
            Database.rollback(preSave); //rollback any completed saves if the transaction has errors
        }
        return pageReference;
    }

}