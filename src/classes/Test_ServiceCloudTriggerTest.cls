@isTest
public with sharing class Test_ServiceCloudTriggerTest {

    static testMethod void Contact_WebPortalActivationTriggerTest()
    {
        Contact contact = new Contact();
        
        User temp = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(temp)
        {
            //Create an Account to Associate to the Contact 
            Account a = MockTestData.createAccountRecord('Test',100);
                        
            //Create a Contact and A User for testing the trigger
            contact = MockTestData.createContactRecord('lastname',a.id);
            contact.Inactive__c = true;
            update contact;
        }
        
        Profile p = [SELECT Profile.Id FROM Profile WHERE UserLicense.Name like '%Customer Portal%' LIMIT 1];
        UserRole r = [SELECT UserRole.Id FROM UserRole WHERE UserRole.PortalType = 'CustomerPortal' LIMIT 1];

        User u = new User();
        u.ContactId = contact.Id;
        u.ProfileId = p.Id;
        //u.UserRoleId = r.Id;
        u.LastName = 'TEST';
        u.Username = 'Test@RainmakerTest.com';
        u.LocaleSidKey = 'en_US';
        u.Alias = 'Test';
        u.Email = 'Test@RainmakerTest.com';
        u.TimeZoneSidKey = 'America/New_York';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        try
        {
            insert(u);
        }
        catch (Exception ex)
        {
            //JGP 9/19/2012
            throw new ApplicationException('There was an error inserting a new Portal User. My research has indicated that the defaults for creating a new user as a portal user by default and a default role will prevent this from happening. The actual error is as follows: '+ex.getmessage());
        }
       
        //contact.Inactive__c = true; 
        //update(contact);
    }    
    
    static testMethod void Account_BillableMinutesRollupTriggerTEST()
    {
        
        //Create an Account        
        Account a = MockTestData.createAccountRecord('Test',100);
        
        //Insert an Entitlement
        Entitlement e = new Entitlement();
        e.AccountId = a.Id;
        e.Name = 'TEST';
        insert(e);
        //Create Tasks for the Account with billable minutes
        Task t = new Task();
        t.Subject = 'Test';
        t.WhatId = a.Id;
        t.Billable_Minutes__c = 100;
        insert(t);
        //Create a second task and add it to facilitate additional code coverage (multiple tasks)
        Task t2 = new Task();
        t2.Subject = 'Test2';
        t2.WhatId = a.Id;
        t2.Billable_Minutes__c = 100;
        insert(t2);
    }
    
    public class ApplicationException extends Exception{}
}