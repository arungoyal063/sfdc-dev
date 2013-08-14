@istest
Public Class Test_Total_Billable_Minutes
{
  Static TestMethod Void mytest()
    {
      
      User pu = getPortalUser(); 
      System.runAs(pu) {   
		Test.StartTest();
		Case c=MockTestData.createCaseRecord('Open', 'Email', 'Level 3',null,null);
		   
		/*Billable_Time__c cbtr = MockTestData.createBillableTimeRecord(c.Id);
		cbtr.Minutes__c = 50.00 ;
		cbtr.Type__c = 'Billable' ;
		cbtr.Allocated_Date__c = date.newinstance(2013, 2, 17);
		cbtr.Account__c = pu.AccountId;
		update cbtr;*/ 
		   
		Total_Billable_Minutes tbm=new Total_Billable_Minutes();         
		Billable_Time__c cbtr1=MockTestData.createBillableTimeRecord(c.Id);
		cbtr1.Minutes__c = 50.00 ;
		cbtr1.Type__c = 'Allocated' ;
		cbtr1.Allocated_Date__c = date.newinstance(2013, 2, 17);
		cbtr1.Account__c = pu.AccountId;
		update cbtr1;  
		Total_Billable_Minutes tbm1 =new Total_Billable_Minutes();         
		Test.StopTest();  
       }
     }
      
     public static User getPortalUser() {
          Account a;
          Contact c;
          a = new Account(name = 'TEST ACCOUNT');
          Database.insert(a);
            
          c = new Contact(AccountId = a.id, lastname = 'lastname');
          Database.insert(c);
     
           Profile p = [SELECT Id FROM profile WHERE name='Ellucian Communities Profile'];        
           // mock test user
           User pu = new User(alias = 'newUser', email='newuser@tgerm.com',
                 emailencodingkey='UTF-8', lastname='Testing', 
                 languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id,contactId = c.id,
                 timezonesidkey='America/Los_Angeles', username='newuser@tgerm.com' + System.now().getTime());
           Database.insert(pu);
           return pu;
     }
}