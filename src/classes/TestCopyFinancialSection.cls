@istest
public class TestCopyFinancialSection{
static testMethod void verifyCopyFinancialSection(){
    Account a1= util.createAccount();
    Opportunity opp= util.createOpportunity(a1.Id); 
    User user1= util.createUser();
    Appirio_PSAe__Resource__c res= util.createResource(user1.Id);
    Appirio_PSAe__Proj__c projct= util.createProject(res.Id,opp.Id,a1.Id);
	Milestone1_Project__c mp =new Milestone1_Project__c(Opportunity__c=opp.Id);
	
    Test.StartTest();
	Insert mp;
	Test.stopTest();
 	
    System.debug('mp......'+ mp);
	System.debug('opp.' +opp);
}

}