/*******************************************************************************************************************
** Module Name   : Milestone1MilestoneTrigger
** Description   : trigger "Milestone1MilestoneTrigger"
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
trigger Milestone1MilestoneTrigger on Milestone1_Milestone__c (after update) {
	String emailSubject = '';
	String emailBody = '';	
	
	Map<ID, String> milestoneIdVsProjectMgrEmailMap = new Map<ID, String>();
	Map<ID, String> milestoneIdVsEngagementMgrEmailMap = new Map<ID, String>();
	List<ID> mileStoneIdList = new List<ID>();
	for(Milestone1_Milestone__c milestone: Trigger.new){
		mileStoneIdList.add(milestone.Id);
	}
	List<Milestone1_Milestone__c> milestoneList = [SELECT Project__r.Account__r.Owner.Email, Project__r.Owner.Email FROM Milestone1_Milestone__c WHERE Id IN: mileStoneIdList];
	for(Milestone1_Milestone__c lMilestone: milestoneList){
		if(lMilestone.Project__r.Owner.Email != null && lMilestone.Project__r.Owner.Email != ''){
			milestoneIdVsProjectMgrEmailMap.put(lMilestone.ID, lMilestone.Project__r.Owner.Email);			
		}
		if(lMilestone.Project__r.Account__r.Owner.Email != null && lMilestone.Project__r.Account__r.Owner.Email != ''){
			milestoneIdVsEngagementMgrEmailMap.put(lMilestone.ID, lMilestone.Project__r.Account__r.Owner.Email);			
		}
	}
	
	for(Milestone1_Milestone__c milestone: Trigger.new){		
	
		String PMemail = milestoneIdVsProjectMgrEmailMap.get(milestone.Id);
    	String EMemail = milestoneIdVsEngagementMgrEmailMap.get(milestone.Id);    	
    	
		if(trigger.isUpdate){
	        Milestone1_Milestone__c oldmilestone =  Trigger.oldMap.get(milestone.Id);	        
	       
			// If the milestone dates are modified, send an email to PM, EM and Kalyan
	        if(oldmilestone != null && oldmilestone.Deadline__c != milestone.Deadline__c){
	        	String[] toaddress = new String[]{};					   	
	        	emailSubject = 'Milestone DeadLine date has been changed.';
	        	emailBody = 'Milestone# ' + milestone.Name + ' Deadline date has been changed:' + '\n' +
	        				'New DeadLine Date : '+ milestone.Deadline__c + '\n' +
	        				'Old Deadline Date : '+ oldmilestone.Deadline__c;
	        	if(PMemail != null && PMemail != ''){
	        		toaddress.add(PMemail);
	        	}
	        	if(EMemail != null && EMemail != ''){
	        		toaddress.add(EMemail);
	        	}
	        	toaddress.add('klanka@rainmaker-llc.com');
	        	Util.sendEmail(emailSubject, emailBody, toaddress);
	        }
	        
	        // If the milestone dates are modified, send an email to PM, EM and Kalyan
	        if(oldmilestone != null && oldmilestone.Kickoff__c != milestone.Kickoff__c){
	        	String[] toaddress = new String[]{};					   	
	        	emailSubject = 'Milestone Kickoff date has been changed.';
	        	emailBody = 'Milestone# ' + milestone.Name + ' Kickoff date has been changed:' + '\n' +
	        				'New Kickoff Date : '+ milestone.Kickoff__c + '\n' +
	        				'Old Kickoff Date : '+ oldmilestone.Kickoff__c;
	        	if(PMemail != null && PMemail != ''){
	        		toaddress.add(PMemail);
	        	}
	        	if(EMemail != null && EMemail != ''){
	        		toaddress.add(EMemail);
	        	}
	        	toaddress.add('klanka@rainmaker-llc.com');		        	
	        	Util.sendEmail(emailSubject, emailBody, toaddress);
	        }
		}
    }

}