/*******************************************************************************************************************
** Module Name   : batch_Milestone1Task_UnitTest
** Description   : Test Class
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun               Initial Version
******************************************************************************************************************/
@isTest(SeeAllData = true)
public with sharing class batch_Milestone1Task_UnitTest 
{
	static TestMethod void UnitTest()
	{
		User u = Util.createUser();
		Account Acc = Util.createAccount();
		
		RecordType rt = [SELECT id FROM RecordType WHERE Sobjecttype = 'Opportunity' and name = 'Rainmaker Master Opportunity'];
		Opportunity Opp = new Opportunity();
		Opp.name = 'Test';
		Opp.AccountId = Acc.id;
		Opp.CloseDate = date.newInstance(2005, 3, 3);
		Opp.ForecastCategoryName = 'Omitted';
		Opp.RecordTypeId = rt.id;
		Opp.StageName = 'Undefined Opportunity';
		Opp.Total_number_users__c = 5;
		insert Opp;
		
		Milestone1_Project__c milesProjObj = new Milestone1_Project__c();
		milesProjObj.Name = 'TestMilestoneProject';
		milesProjObj.Opportunity__c = Opp.id;
		milesProjObj.OwnerId = u.id;
	 	insert milesProjObj;
	 	
		Milestone1_Milestone__c milesMileObj = new Milestone1_Milestone__c();
		milesMileObj.Name = 'TestMilestone';
		milesMileObj.Deadline__c = date.newInstance(2011, 3, 3);
		milesMileObj.Kickoff__c = date.newInstance(2006, 5, 5);
		milesMileObj.Project__c = milesProjObj.id;
		insert milesMileObj;
		
		Milestone1_Task__c MilesTaskObj = new Milestone1_Task__c();
		MilesTaskObj.Name = 'testMilestoneTask';
		MilestaskObj.Project_Milestone__c  = milesMileObj.id;
		MilestaskObj.Due_Date__c = system.today();
		MilestaskObj.Assigned_To__c = u.id;
		MilestaskObj.Complete__c = false;
		insert MilestaskObj;	
		
		Milestone1_Task__c MilesTaskObj1 = new Milestone1_Task__c();
		MilesTaskObj1.Name = 'test1MilestoneTask';
		MilestaskObj1.Project_Milestone__c  = milesMileObj.id;
		MilestaskObj1.Due_Date__c = system.today().addDays(3);
		MilestaskObj1.Assigned_To__c = u.id;
		MilestaskObj1.Complete__c = false;
		insert MilestaskObj1;		
		
		Test.StartTest();		
    	batch_Milestone1Task bacTask =  new batch_Milestone1Task();       
    	ID batchprocessid = Database.executeBatch(bacTask);
    	Test.StopTest();
	}
}