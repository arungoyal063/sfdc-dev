/**
*********************************************************************************************************************
* Module Name   :  TestTransferFollowerFromCase
* Description   :  Test TransferFollowerFromCaseToCR  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :     :  
* 
* Organization  : Rainmaker Associates LLC
*      
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      06/10/2013     Milligan          362             Initial Version
*        
*******************************************************************************************************************
**/ 
@isTest(SeeAllData=true)
public with sharing  class TestTransferFollowerFromCase {
   static testMethod void TestTransferFollowerFromCase() {        
       
    test.startTest();
    
        UserRole ur = [Select u.Name, u.Id From UserRole u where name = 'Ellucian Customer Manager'];
        User temp = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        
        temp.Can_Create_Accounts__c = true;
        temp.Ignore_Validations__c = true;   
        //temp.UserRoleId = ur.id;
        update temp;
        
           User pu = getPortalUser();
           
           
       Case c = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');  // Case Created 
       Change_Request__c cr2 = MockTestData.createCRRecordByPrimaryCR('Test2',NULL, c.Id);   // Change Request Created 
       Change_Request__c cr = MockTestData.createCRRecordByPrimaryCR('Test', cr2.Id, c.Id);  // Change Request Created       
       Associated_Case_Change_Request__c accr = MockTestData.createAssociatedCaseCRRecord(c.id,cr.Id); // Associated Case Change Request Created
        
        
         //Create an Account to Associate to the Contact
         Account a = new Account();
         a.Name = 'Test';
         insert a;           

        Contact c1 = new Contact();
        c1.LastName = 'Jones';
        c1.AccountId = a.Id;
        insert c1; 
        
        Profile p = [SELECT Id FROM profile WHERE name='Ellucian Communities Profile']; 
 
       //Add followers to the Case - Using Entity Subscriptions.
        EntitySubscription eIns = new EntitySubscription();
        eIns.SubscriberId = pu.id;
        eIns.ParentId = c.id;
       // insert eIns;                    
 
       //Add followers to the Case - Using Entity Subscriptions.
        EntitySubscription eIns1 = new EntitySubscription();
        eIns1.SubscriberId = temp.id;
        eIns1.ParentId = c.id;
        insert eIns1;               
        
        Associated_Case_Change_Request__c ac = new Associated_Case_Change_Request__c();
        ac.Case__c = c.id;
        ac.Change_Request__c = cr.id;
        ac.Relationship__c = 'Associated';
        insert ac;
        
        
        Change_Request_Follower__c cf1 = new Change_Request_Follower__c();
        cf1.Follower__c = pu.Id;
        cf1.Change_Request__c = cr.id;
        
        //insert cf1;
        
        test.stopTest();
        
   }

    // create portal user
    public static User getPortalUser() {
           Contact con;
           User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
          
           System.runAs (thisUser) {
                 Account a = MockTestData.createAccountRecord('Test',100);
                 con = MockTestData.createContactRecord('lastname',a.id);  
           }
           Profile p = [SELECT Id FROM profile WHERE name='Ellucian Communities Profile']; 
        
           //Profile p = [SELECT Id FROM profile WHERE name='Customer Portal User']; 
           //UserRole r = [SELECT Id FROM UserRole WHERE PortalRole='Executive' LIMIT 1];       
           // mock test user
           User pu = new User(alias = 'newUser', email='newuser@tgerm.com',
                 emailencodingkey='UTF-8', lastname='Testing', 
                 languagelocalekey='en_US', localesidkey='en_US', 
                 profileid = p.Id, contactId = con.Id, Ignore_Validations__c = true,Ignore_Triggers__c = true,
                 timezonesidkey='America/Los_Angeles', username='newuser@tgerm.com' + System.now().getTime());
           Database.insert(pu);
           return pu;
     }      
       
}