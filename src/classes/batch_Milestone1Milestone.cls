/*******************************************************************************************************************
** Module Name   : batch_Milestone1Milestone
** Description   : batch class for "batch_Milestone1Milestone"
** Throws        : NA
** Calls         : NA
** Test Class    : batch_Milestone1Milestone_UnitTest
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun              
******************************************************************************************************************/
global class batch_Milestone1Milestone implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Name, Deadline__c, Project__r.Account__r.Owner.Email, 
											Project__r.Owner.Email FROM Milestone1_Milestone__c ]); 
	}
	
	global void finish(Database.BatchableContext BC){
		//to do mail 
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){		
		String emailSubject = '';
		String emailBody = '';
		
		for(Sobject sobj : scope) {
			Milestone1_Milestone__c mileStoneObj = (Milestone1_Milestone__c)sobj;            
    		
    		String PMemail = mileStoneObj.Project__r.Owner.Email;
    		String EMemail = mileStoneObj.Project__r.Account__r.Owner.Email;
    		
	    	if(mileStoneObj != null && mileStoneObj.Deadline__c >= System.today() && (System.today().daysBetween(mileStoneObj.Deadline__c)) <= 5){
	        	String[] toaddress = new String[]{};					   	
	        	emailSubject = 'Milestone deadLine will be reached in ' + System.today().daysBetween(mileStoneObj.Deadline__c) + ' days.';
	        	emailBody = 'Milestone# ' + mileStoneObj.Name + ' DeadLine will be reached in ' + System.today().daysBetween(mileStoneObj.Deadline__c) + ' days.';
	        				
	        	if(PMemail != null && PMemail != ''){
	        		toaddress.add(PMemail);
	        	}
	        	if(EMemail != null && EMemail != ''){
	        		toaddress.add(EMemail);
	        	}
	        	if(!test.isRunningTest()){
	        		Util.sendEmail(emailSubject, emailBody, toaddress);
	        	}
	        }
        }
	}	
}