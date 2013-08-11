public with sharing class CaseTest {

	@isTest
	public static void testCaseAssignment(){
		Account a = new Account();
		a.Name = 'Test Account';
		a.Account_Num__c = '8989898';
		insert a;
		System.debug('a.id --> ' + a.id);
		Case c = new Case();
		c.Account_Number__c  = '8989898';
		c.Dispatch_Customer_Comment_Number__c = '879879';
		insert c;
		update c;
		System.debug('c.id --> ' + c.id);
		
		
	}
}