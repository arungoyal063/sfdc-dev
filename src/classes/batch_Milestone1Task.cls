/*******************************************************************************************************************
** Module Name   : batch_Milestone1Task
** Description   : batch class for "batch_Milestone1Task"
** Throws        : NA
** Calls         : NA
** Test Class    : batch_Milestone1Task_UnitTest
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun              
******************************************************************************************************************/
global class batch_Milestone1Task implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(test.isRunningTest()){
			return Database.getQueryLocator([SELECT Name, Assigned_To__c, Due_Date__c, Complete__c, Project_Milestone__r.Project__r.Owner.Email 
											FROM Milestone1_Task__c Limit 200]);
		}
		else{
			return Database.getQueryLocator([SELECT Name, Assigned_To__c, Due_Date__c, Complete__c, Project_Milestone__r.Project__r.Owner.Email 
											FROM Milestone1_Task__c ]);
		}		 
	}
	
	global void finish(Database.BatchableContext BC){
		//to do mail 
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){		
		String emailSubject = '';
		String emailBody = '';	
		Map<ID, String> userIdVsEmailMap = new Map<ID, String>();		
		List<User> userList = [SELECT Name, Email FROM User];
		for(User lUser: userList){
			if(lUser.Email != null && lUser.Email != ''){
				userIdVsEmailMap.put(lUser.ID, lUser.Email);			
			}			
		}		
		
		for(Sobject sobj : scope) {
			Milestone1_Task__c mileStoneTaskObj = (Milestone1_Task__c)sobj;            
            String PMemail = mileStoneTaskObj.Project_Milestone__r.Project__r.Owner.Email;
	    	String taskOwnerEmail = userIdVsEmailMap.get(mileStoneTaskObj.Assigned_To__c);
	    	   	
	    	if(mileStoneTaskObj != null && mileStoneTaskObj.Due_Date__c <= System.today() && !mileStoneTaskObj.Complete__c){
	        	String[] toaddress = new String[]{};					   	
	        	emailSubject = 'Task deadLine has been reached.';
	        	emailBody = 'Task# ' + mileStoneTaskObj.Name + ' DeadLine has been reached.';
	        				
	        	if(PMemail != null && PMemail != ''){
	        		toaddress.add(PMemail);
	        	}	        	
	        	if(!test.isRunningTest()){
        			Util.sendEmail(emailSubject, emailBody, toaddress);
	        	}
	        }
	        
	        if(mileStoneTaskObj != null && mileStoneTaskObj.Due_Date__c >= System.today() && (System.today().daysBetween(mileStoneTaskObj.Due_Date__c)) <= 5){
	        	String[] toaddress = new String[]{};					   	
	        	emailSubject = 'Task deadLine will be reached in '+ System.today().daysBetween(mileStoneTaskObj.Due_Date__c) + ' days.';
	        	emailBody = 'Task# ' + mileStoneTaskObj.Name + ' DeadLine will be reached in ' + System.today().daysBetween(mileStoneTaskObj.Due_Date__c) + ' days.';
	        				
	        	if(PMemail != null && PMemail != ''){
	        		toaddress.add(PMemail);
	        	}
	        	if(taskOwnerEmail != null && taskOwnerEmail != ''){
	        		toaddress.add(taskOwnerEmail);
	        	}	        	
	        	Util.sendEmail(emailSubject, emailBody, toaddress);
	        }
        }
	}
	
}