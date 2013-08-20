@istest
public class TestCopyFinancialSectionOnMPM{
static testMethod void verifyCopyFinancialSectionOnMPM(){
User Usr= util.createUser();
Appirio_PSAe__Resource__c res= util.createResource(usr.Id);
Account acc= util.createAccount();
Opportunity opp= util.createOpportunity(acc.ID);
Appirio_PSAe__Proj__c prj= util.createProject(res.Id, opp.Id, acc.Id);
Milestone1_Project__c mp=new Milestone1_Project__c(Opportunity__c=opp.Id);
insert mp;
Appirio_PSAe__Proj__c prj1= util.createProject(res.Id, opp.Id, acc.Id);
Test.startTest();


test.stopTest();
System.debug('mp......' +mp);
}
}