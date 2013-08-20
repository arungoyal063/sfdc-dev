/*******************************************************************************************************************
** Module Name   : Milestone1MilestoneTrigger_UnitTest
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
public with sharing class Milestone1MilestoneTrigger_UnitTest 
{
	Static testMethod void TestMethod1()
	{
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
	 	
		Milestone1_Milestone__c milesMileObj = new Milestone1_Milestone__c();
		milesMileObj.Name = 'TestMilestone';
		milesMileObj.Deadline__c = date.newInstance(2011, 3, 3);
		milesMileObj.Kickoff__c = date.newInstance(2006, 5, 5);
		milesMileObj.Project__c = milesProjObj.id;
		insert milesMileObj;
		milesMileObj.Deadline__c = date.newInstance(2011, 4, 3);
		milesMileObj.Kickoff__c = date.newInstance(2006, 6, 5);
		update milesMileObj;
	 					
	}  

}