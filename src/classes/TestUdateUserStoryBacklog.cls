/*******************************************************************************************************************
** Module Name   : TestUdateUserStoryBacklog
** Description   : Test Class
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               	Arun            Initial Version
******************************************************************************************************************/
@isTest
private class TestUdateUserStoryBacklog {

    static testMethod void myUnitTest() {
        User u = Util.createUser();
		Account acc = new Account();
		acc.Client_Requires_a_Purchase_Order__c = 'No';
	    acc.Industry = 'Education';
	    acc.name = 'James Miller';
	    acc.OwnerId = u.id;
	    insert(acc);
		
		RecordType rt = [SELECT id FROM RecordType WHERE Sobjecttype = 'Opportunity' and name = 'Rainmaker Master Opportunity'];
		Opportunity Opp = new Opportunity();
		Opp.name = 'Test';
		Opp.AccountId = acc.id;
		Opp.CloseDate = date.newInstance(2005, 3, 3);
		Opp.ForecastCategoryName = 'Omitted';
		Opp.RecordTypeId = rt.id;
		Opp.StageName = 'Undefined Opportunity';
		Opp.Total_number_users__c = 5;
		insert Opp;
		
		Milestone1_Project__c milesProjObj = new Milestone1_Project__c();
		milesProjObj.Name = 'TestMilestoneProject';
		milesProjObj.Opportunity__c = Opp.id;
		milesProjObj.Account__c = acc.id;
	 	insert milesProjObj;
	 	
	 	Milestone1_Milestone__c parentMilesMileObj = new Milestone1_Milestone__c();
		parentMilesMileObj.Name = 'ParentTestMilestone';		
		parentMilesMileObj.Project__c = milesProjObj.id;
		insert parentMilesMileObj;
		
		Milestone1_Milestone__c milesMileObj = new Milestone1_Milestone__c();
		milesMileObj.Name = 'TestMilestone';		
		milesMileObj.Project__c = milesProjObj.id;
		insert milesMileObj;
		
		User_Story__c userStoryObj = new User_Story__c();
		userStoryObj.Name__c = 'testUserStory';
		userStoryObj.Milestone1_Milestone__c = parentMilesMileObj.Id;
		insert userStoryObj;	
		
		milesMileObj.Parent_Milestone__c = parentMilesMileObj.Id;
		update milesMileObj;
		
		userStoryObj.Milestone1_Milestone__c = milesMileObj.Id;
		update userStoryObj;    
	}
}