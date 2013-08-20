// ==================================================================================
//   Object: testAccountBeforeInsertUpdate 
//  Company: Mannington
//   Author: John Westenhaver (Sales Optimizer)
// Comments: Tests accountBeforeInsertUpdate AND opportunityBeforeInsertUpdate triggers. 
// ==================================================================================
//  Changes: 2011-11-08 Initial version.
// ==================================================================================

@isTest
private class testAccountBeforeInsertUpdate 
{
    static testMethod void unitTest() 
    {
    	test.startTest();
/*
    	User u = [SELECT Id, Name, Sales_Office__c FROM User WHERE Id = :userInfo.getUserId()];
    	if (u.Sales_Office__c == null)
    	{
    		u.Sales_Office__c = '0010 - Northeast';
    		update u;
    	}
    	Account a = new Account(Name = 'TEST ACCOUNT');
    	insert a;
    	Opportunity o = new Opportunity(Name = 'TEST OPPORTUNITY', AccountId = a.Id, StageName = 'Test', CloseDate = system.today() + 1);
    	insert o;
*/    	
    	test.stopTest();
    }
}