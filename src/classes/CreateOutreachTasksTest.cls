/**
	* CreateOutreachTasksTest - <description>
	* @author: Rainmaker Admin
	* @version: 1.0
*/

@isTest
private class CreateOutreachTasksTest {
	static testMethod void myUnitTest() {
		// TO DO: implement unit test
		
		Account accnt = new Account(Name='Test Account', Company_Tier__c = '1');
		insert accnt;
		
		Agreements__c agree = new Agreements__c(Account_Name__c =accnt.Id);
		agree.Subscription_Start_Date__c = Date.today();
		insert agree;
		
		accnt.Company_Tier__c = '2';
		update accnt;
		
		accnt.Company_Tier__c = '3';
		update accnt;
		
		accnt.Account_Status__c = 'biNOW Former Customer';
		update accnt;
		
	}
}