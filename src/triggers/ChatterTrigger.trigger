/**
    * ChatterTrigger - <description>
    * @author: Rainmaker Admin
    * @version: 1.0
*/

trigger ChatterTrigger on Change_Request_Follower__c bulk (before delete, before insert) {
	boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
	if (ignoreTriggers) return; 
	 
	    if(Trigger.isInsert){
	            Change_Request_Follower__c[] users = Trigger.new;
	            ChatterManagementService.AddUsers(users);
	       
	    }
	    if (Trigger.isDelete) {
	        Change_Request_Follower__c[] users = Trigger.old;
	        ChatterManagementService.RemoveUsers(users);
	    }
	    
	 
}