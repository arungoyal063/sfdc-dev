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
global with sharing class Milestone1_Clone_Utility {

    global static Milestone1_Project__c cloneProject(Milestone1_Project__c rec){
        Milestone1_Project__c newRec = rec.clone(false);
        newRec.ImportID__c = rec.Id;
        return newRec;
    }
    
    global static Map<String, Milestone1_Milestone__c> cloneMilestonesIntoMap(List<Milestone1_Milestone__c> recs){
        Map<String, Milestone1_Milestone__c> recMap = new Map<String, Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c rec : recs){
            Milestone1_Milestone__c newRec = rec.clone(false);
            newRec.ImportID__c = rec.Id;
            recMap.put(rec.Id, newRec);
        }
        return recMap;
    }
    
    global static List<Milestone1_Task__c> cloneTasksIntoList(List<Milestone1_Task__c> recs){
        List<Milestone1_Task__c> newRecs = new List<Milestone1_Task__c>();
        for(Milestone1_Task__c rec : recs){
            Milestone1_Task__c newRec = rec.clone(false);
            newRecs.add(newRec);
        }
        return newRecs;
    }
    //To clone US
    global static Map<String, User_Story__c> cloneUserStoryIntoMap(List<User_Story__c> recs){
        Map<String, User_Story__c> recMap = new Map<String, User_Story__c>();
        for(User_Story__c rec : recs){
            User_Story__c newRec = rec.clone(false);
            recMap.put(rec.Id, newRec);
        }
        return recMap;
    }
    
    global static void cloneUserStoryIntoMap2(List<Map<String, Object>> userStoryTree, Map<String, User_Story__c> recMap, Map<String, Milestone1_Milestone__c> allNewMilestoneMap, User_Story__c parentUserStory, Integer level){
        for(Map<String, Object> userStoryMapObj : userStoryTree)
        {
        	User_Story__c userStoryObj = null;
        	User_Story__c newUserStoryObj = null;
            if(userStoryMapObj.get('userStory') != null)
            {
            	userStoryObj = (User_Story__c)userStoryMapObj.get('userStory');
            	newUserStoryObj = userStoryObj.clone(false);
                if(level == 1)
                {
	            	if(allNewMilestoneMap.get(userStoryObj.Milestone1_Milestone__c) != null)
	                	newUserStoryObj.Milestone1_Milestone__c = allNewMilestoneMap.get(userStoryObj.Milestone1_Milestone__c).Id;
                }
                else if(level > 1)
                {
                	if(allNewMilestoneMap.get(userStoryObj.Milestone1_Milestone__c) != null)
                	{
                		newUserStoryObj.Milestone1_Milestone__c = allNewMilestoneMap.get(userStoryObj.Milestone1_Milestone__c).Id;
                	}
                	if(parentUserStory != null)
                	{
                		newUserStoryObj.Feature_Request__c = parentUserStory.Id;
                	}
                }
                insert newUserStoryObj;
                recMap.put(userStoryObj.id, newUserStoryObj);
            } 
            if(userStoryMapObj.get('children') != null)
            {
            	if( ((List<Map<String, Object>>)userStoryMapObj.get('children') ).size() > 0 && newUserStoryObj != null)
            	{
            		cloneUserStoryIntoMap2((List<Map<String, Object>>)userStoryMapObj.get('children'), recMap, allNewMilestoneMap , newUserStoryObj, level+1);
            	}
            }
        }
    }
    
    global static Map<String, Object> getUserListChildren(List<User_Story__c> child){
    	list<User_Story__c> userStoryList = new list<User_Story__c>([SELECT Milestone1_Milestone__c, Id, Name__c, Backlog__c, Feature_Request__c, (Select Id, Name__c, Backlog__c, Feature_Request__c, Milestone1_Milestone__c From Feature_Requests__r) FROM User_Story__c WHERE ID IN:child]);
	    Map<String, Object> userStory = new Map<String, Object>();
        if(userStoryList.size() == 1)
        {
	        for(User_Story__c uStory : userStoryList)
	        {
	        	userStory.put('userStory',uStory);
	        	List<Map<String, Object>> children = new List<Map<String, Object>>();
	            for(User_Story__c lChild : uStory.Feature_Requests__r)
	            {
                	List<User_Story__c> aChild = new List<User_Story__c>();
                	aChild.add(lChild);
	            	children.add(getUserListChildren(aChild));
	            }
	        	userStory.put('children',children);
	        }	        
        }
        return userStory;
    }
    
    global static Map<String, Milestone1_Task__c> cloneTasksIntoMap(List<Milestone1_Task__c> recs){
        Map<String, Milestone1_Task__c> recMap = new Map<String, Milestone1_Task__c>();
        for(Milestone1_Task__c rec : recs){
            Milestone1_Task__c newRec = rec.clone(false);
            newRec.ImportID__c = rec.Id;
            recMap.put(rec.Id, newRec);
        }
        return recMap;
    }

}