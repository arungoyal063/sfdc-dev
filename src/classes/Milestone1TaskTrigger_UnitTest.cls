/*******************************************************************************************************************
** Module Name   : Milestone1TaskTrigger_UnitTest
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

@isTest(SeeAllData = True)
public with sharing class Milestone1TaskTrigger_UnitTest 
{
	Static TestMethod void TestMethod1()
	{
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
	 	insert milesProjObj;
	 	
		Milestone1_Milestone__c milesMileObj = new Milestone1_Milestone__c();
		milesMileObj.Name = 'TestMilestone';
		milesMileObj.Deadline__c = date.newInstance(2011, 3, 3);
		milesMileObj.Kickoff__c = date.newInstance(2006, 5, 5);
		milesMileObj.Project__c = milesProjObj.id;
		insert milesMileObj;
		
		List<User> u = [SELECT id FROM user LIMIT 2];
		
		Milestone1_Task__c MilesTaskObj = new Milestone1_Task__c();
		MilesTaskObj.Name = 'testMilestoneTask';
		MilestaskObj.Project_Milestone__c  = milesMileObj.id;
		MilestaskObj.Due_Date__c = date.newInstance(2008, 8, 6);
		MilestaskObj.Assigned_To__c = u[0].id;
		MilestaskObj.Blocked__c = false;
		
		insert MilestaskObj; 
		
		MilestaskObj.Due_Date__c = date.newInstance(2008, 5, 6);
		MilestaskObj.Assigned_To__c = u[1].id;
		MilestaskObj.Blocked__c = true;
		MilestaskObj.Blocked_Reason__c = 'Testing';
		update MilestaskObj;
		
		delete MilestaskObj;
	}
}