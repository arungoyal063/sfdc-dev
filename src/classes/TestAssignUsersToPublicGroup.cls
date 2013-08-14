/**
*********************************************************************************************************************
* Module Name   :  TestAssignUsersToPublicGroup
* Description   :  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date        	  Author      	   WO#         Description of Action
* 1.0      02/05/2012     Milligan                 		Initial Version
*   
*******************************************************************************************************************
**/
public class TestAssignUsersToPublicGroup {
    
    @isTest(SeeAllData=true)
    public static void testUserGroupAssignment() {
        //Profile.name = 'System Administrator' and
        User adminUser = [select id from User where  Can_Create_Accounts__c = true and isActive = true LIMIT 1];
        Profile communitiesProfile = [Select id from Profile where name = 'Ellucian Communities Profile' LIMIT 1];
        System.runAs(adminUser) {
    		Account a = new Account();
	        a.Name = 'Test';
            a.type = 'Association';
	        insert a;
    		    		
    		//Create a Contact and A User for testing the trigger
			Contact contact = new Contact();
			contact.LastName = 'Test';
			contact.AccountId = a.Id;
			insert(contact);
			
			Group g1 = new Group();
			g1.Name = 'Test Group1';
			g1.Type = 'Regular';
			insert g1;
	
			Product2 prod = new Product2();
			prod.Name = 'Test Prod';
			prod.Security_Group__c = 'Test Group1';
			insert prod;
	
			Licensed_Product__c lp1 =  new Licensed_Product__c();
			lp1.Name = 'Lic Prod1';
			lp1.Account__c = a.Id;
			lp1.Product_New__c = prod.id;
			insert lp1;
            
            User u = new User();
			u.ContactId = contact.Id;
			u.ProfileId = communitiesProfile.id;
		//u.UserRoleId = r.Id;
		//u.accountId = a.id;
			u.LastName = 'TEST';
			u.Username = 'Test@RainmakerTest.com';
			u.LocaleSidKey = 'en_US';
			u.Alias = 'Test';
	    //u.IsPortalEnabled = true;
        u.isActive = true;
		u.Email = 'Test@RainmakerTest.com';
		u.TimeZoneSidKey = 'America/New_York';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.LanguageLocaleKey = 'en_US';

		insert(u);	
            
            u.isActive = false;
            update u;
            
            u.isActive = true;
            update u;
            
         
        }
    }
   
}