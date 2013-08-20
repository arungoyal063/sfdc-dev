/*******************************************************************************************************************
** Module Name   : udateUserStoryBacklog
** Description   : Trigger to update backlog on the basis of milestone which is being assigned(parent/child)
** Throws        : NA
** Calls         : NA
** Test Class    : TestUdateUserStoryBacklog 
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                 8/07/2013       Arun Goyal                       Initial Version
******************************************************************************************************************/
trigger udateUserStoryBacklog on User_Story__c (after insert, after update) {
	
	public static List<User_Story__c> userStoryList = new List<User_Story__c>();
	public static List<User_Story__c> updateUserStoryList = new List<User_Story__c>();
	public static List<Milestone1_Milestone__c> milestoneList = new List<Milestone1_Milestone__c>();	
	public static Map<Id, Milestone1_Milestone__c> mileStoneMap = new Map<Id, Milestone1_Milestone__c>();
	
	
	milestoneList = [SELECT Parent_Milestone__c FROM Milestone1_Milestone__c /*WHERE Id IN: mileStoneIds*/];
	for(Milestone1_Milestone__c mileStoneObj : milestoneList){
		mileStoneMap.put(mileStoneObj.Id, mileStoneObj);
	}	
	
	userStoryList = [SELECT Milestone1_Milestone__r.Id, Id, Backlog__c FROM User_Story__c WHERE Id IN: Trigger.newMap.keyset()];
		
	for(User_Story__c userStoryObj: userStoryList){
	 	Milestone1_Milestone__c lMileStoneObj = mileStoneMap.get(userStoryObj.Milestone1_Milestone__r.Id);	 	
	 			 	
	 	if(lMileStoneObj == null || lMileStoneObj.Parent_Milestone__c == null){
	 		userStoryObj.Backlog__c = true;
	 	}
	 	
	 	if(lMileStoneObj != null && lMileStoneObj.Parent_Milestone__c != null){
	 		userStoryObj.Backlog__c = false;
	 	}
		 updateUserStoryList.add(userStoryObj);		 
	}
	
	try{ 	
		if(TriggerRunOnce.runOnce()){
			update updateUserStoryList;
		}        
    }catch(Exception e){}
}