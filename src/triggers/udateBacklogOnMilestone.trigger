/*******************************************************************************************************************
** Module Name   : udateBacklogOnMilestone
** Description   : Trigger to update backlog on the basis of milestone which has assigned and beign updated
** Throws        : NA
** Calls         : NA
** Test Class    : TestUdateBacklogOnMilestone 
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                 8/07/2013       Arun Goyal                       Initial Version
******************************************************************************************************************/
trigger udateBacklogOnMilestone on Milestone1_Milestone__c (after update) {

	List<Id> mileStoneIdList = new List<Id>();
	public static List<Milestone1_Milestone__c> mileStoneList = new List<Milestone1_Milestone__c>();
	public static List<User_Story__c> userStoryList = new List<User_Story__c>();
	
	for(Milestone1_Milestone__c mileStoneObj : Trigger.new){
		Milestone1_Milestone__c oldMileStoneObj = Trigger.oldMap.get(mileStoneObj.Id);
		if(mileStoneObj.Parent_Milestone__c != oldMileStoneObj.Parent_Milestone__c){
			mileStoneIdList.add(mileStoneObj.Id);
		}
	}
	
	mileStoneList = [SELECT Id,Parent_Milestone__c, (SELECT Id, Milestone1_Milestone__c, backlog__c FROM User_Stories__r) FROM Milestone1_Milestone__c WHERE Id IN: mileStoneIdList];
	for(Milestone1_Milestone__c lMilestoneObj: mileStoneList){
		if(lMilestoneObj.Parent_Milestone__c == null){
			for(User_Story__c userStoryObj: lMilestoneObj.User_Stories__r){
				userStoryObj.backlog__c = true;
				userStoryList.add(userStoryObj);
			}	 		
	 	}
	 	
	 	if(lMilestoneObj.Parent_Milestone__c != null){
	 		for(User_Story__c userStoryObj: lMilestoneObj.User_Stories__r){
				userStoryObj.backlog__c = false;
				userStoryList.add(userStoryObj);
			}
	 	}	 	
	}
	
	try{ 	
		if(TriggerRunOnce.runOnce()){
			update userStoryList;
		}        
    }catch(Exception e){}
}