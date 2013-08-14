/**
    * CaseChatterTrigger - <description>
    * @author: Rainmaker Admin Ellucian
    * @version: 1.0
*/

trigger CaseChatterTrigger on Case_Follower__c bulk (before insert,before delete) {
	boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
	if (ignoreTriggers) return;
	    if (Trigger.isInsert) {
	            Case_Follower__c[] users = Trigger.new;
	            ChatterManagementService.AddUsers(users);
	       }   
	    
	    
	  
        if (Trigger.isDelete) {
            Case_Follower__c[] users = Trigger.old;
            ChatterManagementService.RemoveUsers(users);
        }
	   
	
	
}