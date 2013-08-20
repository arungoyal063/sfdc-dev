/*******************************************************************************************************************
** Module Name   : Milestone1TaskTrigger
** Description   : trigger "Milestone1TaskTrigger"
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun              
******************************************************************************************************************/
trigger Milestone1TaskTrigger on Milestone1_Task__c (after insert, after update, before delete) {	
	String emailSubject = '';
	String emailBody = '';	
	Map<ID, String> userIdVsEmailMap = new Map<ID, String>();
	Map<ID, String> userIdVsNameMap = new Map<ID, String>();
	List<User> userList = [SELECT Name, Email FROM User];
	for(User lUser: userList){
		if(lUser.Email != null && lUser.Email != ''){
			userIdVsEmailMap.put(lUser.ID, lUser.Email);			
		}
		userIdVsNameMap.put(lUser.ID, lUser.Name);	
	}
	
	Map<ID, String> taskIdVsEmailMap = new Map<ID, String>();
	Map<ID, String> taskIdVsProjectMap = new Map<ID, String>();
	Map<ID, String> taskIdVsMileStoneMap = new Map<ID, String>();
	Map<ID, String> taskIdVsMileStoneIdMap = new Map<ID, String>();
	List<Milestone1_Task__c> taskList = [SELECT Project_Milestone__c, Project_Milestone__r.Name, Project_Milestone__r.Project__r.Name, Project_Milestone__r.Project__r.Owner.Email FROM Milestone1_Task__c WHERE Project_Milestone__r.Project__r.Owner.Email != null];
	for(Milestone1_Task__c lTask: taskList){
		if(lTask.Project_Milestone__r.Project__r.Owner.Email != null && lTask.Project_Milestone__r.Project__r.Owner.Email != ''){
			taskIdVsEmailMap.put(lTask.ID, lTask.Project_Milestone__r.Project__r.Owner.Email);
			taskIdVsProjectMap.put(lTask.ID, lTask.Project_Milestone__r.Project__r.Name);
			taskIdVsMileStoneMap.put(lTask.ID, lTask.Project_Milestone__r.Name);
			taskIdVsMileStoneIdMap.put(lTask.ID, lTask.Project_Milestone__c);
		}
	}
	
	if(trigger.isUpdate || trigger.isInsert){
		for(Milestone1_Task__c taskObj: Trigger.new){		
		
			String PMemail = taskIdVsEmailMap.get(taskObj.Id);
	    	String taskOwnerEmail = userIdVsEmailMap.get(taskObj.Assigned_To__c);
	    	String projectName = taskIdVsProjectMap.get(taskObj.Id);
	    	String mileStoneName = taskIdVsMileStoneMap.get(taskObj.Id);
	    	String mileStoneURL = ' (' + URL.getSalesforceBaseUrl().getProtocol() +'://' + URL.getSalesforceBaseUrl().getHost()+ '/'+ taskIdVsMileStoneIdMap.get(taskObj.Id) + ')';  	
	    	
			if(trigger.isUpdate){
		        Milestone1_Task__c oldTaskObj =  Trigger.oldMap.get(taskObj.Id);	        
		       
				// If the task deadline is modified, send an email to PM and task owner
		        if(oldTaskObj != null && oldTaskObj.Due_Date__c != taskObj.Due_Date__c){
		        	String[] toaddress = new String[]{};					   	
		        	emailSubject = 'Task deadLine has been changed.';
		        	emailBody = 'Task# ' + taskObj.Name + ' DeadLine date has been changed:' + '\n' +
		        				'New DeadLine Date : '+ taskObj.Due_Date__c + '\n' +
		        				'Old DeadLine Date : '+ oldTaskObj.Due_Date__c + '\n' + 
		        				'Project : ' + projectName + '\n' + 
		        				'Milestone : ' + mileStoneName + mileStoneURL;
		        	if(PMemail != null && PMemail != ''){
		        		toaddress.add(PMemail);
		        	}
		        	if(taskOwnerEmail != null && taskOwnerEmail != ''){
		        		toaddress.add(taskOwnerEmail);
		        	}		        	
		        	if(!test.isRunningTest()){
	        			Util.sendEmail(emailSubject, emailBody, toaddress);
		        	}
		        }
		        
		        // If the task owner is modified, send an email to the old owner and the new owner
		        if(oldTaskObj != null && oldTaskObj.Assigned_To__c != taskObj.Assigned_To__c){
		        	String oldTaskOwnerEmail = userIdVsEmailMap.get(oldTaskObj.Assigned_To__c);
		        	
		        	String[] toaddress = new String[]{};					
		        	emailSubject = 'Task owner has been changed.';
		        	emailBody = 'Task# ' + taskObj.Name + ' new owner has been set to: ' + userIdVsNameMap.get(taskObj.Assigned_To__c) + '\n' + 
		        				'Project : ' + projectName + '\n' + 
		        				'Milestone : ' + mileStoneName + mileStoneURL;
		        	if(oldTaskOwnerEmail != null && oldTaskOwnerEmail != ''){
		        		toaddress.add(oldTaskOwnerEmail);
		        	}
		        	if(taskOwnerEmail != null && taskOwnerEmail != ''){
		        		toaddress.add(taskOwnerEmail);
		        	}	        	
		        	Util.sendEmail(emailSubject, emailBody, toaddress);
		        }
		        
		        // If the task is blocked, send an email to PM and Kalyan		        
		        if(oldTaskObj != null && !oldTaskObj.Blocked__c && taskObj.Blocked__c){
	    			String[] toaddress = new String[]{};					
					emailSubject = 'Task has been blocked.';
		        	emailBody = 'Task# ' + taskObj.Name + ' has been blocked.' + '\n' + 
		        				'Project : ' + projectName + '\n' + 
		        				'Milestone : ' + mileStoneName + mileStoneURL;
		        	if(PMemail != null && PMemail != ''){
		        		toaddress.add(PMemail);
		        	}
		        	toaddress.add('klanka@rainmaker-llc.com');
		        	Util.sendEmail(emailSubject, emailBody, toaddress);
		        }
			}
			
			if(trigger.isInsert){
				
				// If the task is created and owner is assigned, send an email to the task owner
		        if(taskObj.Assigned_To__c != null){
					String[] toaddress = new String[]{};					
					emailSubject = 'Task has been created and assigned.';
		        	emailBody = 'Task# ' + taskObj.Name + ' has been assigned to '+ userIdVsNameMap.get(taskObj.Assigned_To__c) + '\n' + 
		        				'Project : ' + projectName + '\n' + 
		        				'Milestone : ' + mileStoneName + mileStoneURL;
		        	if(taskOwnerEmail != null && taskOwnerEmail != ''){
		        		toaddress.add(taskOwnerEmail);
		        	}
		        	/*if(userIdVsEmailMap.get(taskObj.Assigned_To__c) != null && userIdVsEmailMap.get(taskObj.Assigned_To__c) != ''){
		        		toaddress.add(userIdVsEmailMap.get(taskObj.Assigned_To__c));
		        	}*/
		        	if(!test.isRunningTest()){
	        			Util.sendEmail(emailSubject, emailBody, toaddress);
		        	}		        	
		        }
		        
		        /*// If the task is blocked, send an email to PM and Kalyan		        
		        if(taskObj.Blocked__c != null && taskObj.Blocked__c){
		    		String[] toaddress = new String[]{};					
					emailSubject = 'Task has been blocked.';
		        	emailBody = 'Task# ' + taskObj.Name + ' has been blocked.';
		        	if(PMemail != null && PMemail != ''){
		        		toaddress.add(PMemail);
		        	}
		        	Util.sendEmail(emailSubject, emailBody, toaddress);
		        }*/
			}
	    }
	}
	
	if(trigger.isDelete){		
		// If the task is deleted, send an email to PM		
		for(Milestone1_Task__c oldTaskObj: Trigger.old){
			String projectName = taskIdVsProjectMap.get(oldTaskObj.Id);
	    	String mileStoneName = taskIdVsMileStoneMap.get(oldTaskObj.Id);
	    	String mileStoneURL = ' (' + URL.getSalesforceBaseUrl().getProtocol() +'://' + URL.getSalesforceBaseUrl().getHost()+ '/'+ taskIdVsMileStoneIdMap.get(oldTaskObj.Id) + ')';
			String PMemail = taskIdVsEmailMap.get(oldTaskObj.Id);
			String[] toaddress = new String[]{};			
	        emailSubject = 'Task has been deleted.';
	    	emailBody = 'Task# ' + oldTaskObj.Name + ' has been deleted.' + '\n' + 
        				'Project : ' + projectName + '\n' + 
        				'Milestone : ' + mileStoneName + mileStoneURL;
	    	if(PMemail != null && PMemail != ''){
	    		toaddress.add(PMemail);
	    	}      	
	    	Util.sendEmail(emailSubject, emailBody, toaddress);	
		}		
	}
}