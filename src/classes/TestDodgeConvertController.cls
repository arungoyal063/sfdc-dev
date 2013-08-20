// ==================================================================================
//   Object: TestDodgeConvertController 
//  Company: ManningTon
//   Author: Mohan (Sales Optimizer)
// Comments: Tests the DodgeConvertController class and SetDodgeProjectOwner trigger
// ==================================================================================
//  Changes: 2011-12-23 Initial version.
// ==================================================================================

@isTest
private class TestDodgeConvertController {

    static testMethod void dodgeConvertController_Test1() {
        // TO DO: implement unit test
        Dodge_Project__c dp = new Dodge_Project__c();
        dp.Title__c = 'Test Project';
        dp.Report_ID__c = '123';
        dp.Dodge_Report_Version_Number__c = '1';
        dp.Dodge_Report_Number__c = '12';
        insert dp;
        
        Dodge_Contact__c dc = new Dodge_Contact__c();
        dc.Firm_Name__c = 'Test Firm';
        dc.Contact_Name__c = 'Test Contact';
        dc.Dodge_Project__c = dp.Id;
        dc.Role__c = 'Architect';
        dc.Address_Line_1__c = 'abc';
        dc.Address_Line_2__c = 'xyz';
        dc.Address_Line_3__c = 'pqr';
        insert dc;
        dc = new Dodge_Contact__c();
        dc.Firm_Name__c = 'Dodge Firm';
        dc.Contact_Name__c = 'Dodge Contact';
        dc.Dodge_Project__c = dp.Id;
        dc.Role__c = 'Owner';
        insert dc;
        
        Apexpages.currentPage().getParameters().put('id', dp.Id);
        DodgeConvertController dcc = new DodgeConvertController(new Apexpages.Standardcontroller(dp));
        System.currentPageReference().getParameters().put('rIndex', '0');
        dcc.dodgeContactList.get(0).accountOptSelected = 'Create New';
        dcc.fetchContacts();
        dcc.convert();
        Apexpages.currentPage().getParameters().put('primaryRowIndexValue', '0');
        dcc.dodgeContactList.get(0).contactSelected = 'Create New';
        dcc.convert();
        
        DodgeConvertController dcc1 = new DodgeConvertController(new Apexpages.Standardcontroller(dp));
        Apexpages.currentPage().getParameters().put('primaryRowIndexValue', '0');
        dcc1.convert();
        dcc1.cancel();
    }
    
    static testMethod void dodgeConvertController_Test2() {
        // TO DO: implement unit test
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        Contact c = new Contact();
        c.LastName = 'Test Contact';
        c.Phone = '1234566890';
        c.Email = 'test@test.com';
        c.AccountId = a.Id;
        insert c;
        
        Dodge_Project__c dp = new Dodge_Project__c();
        dp.Title__c = 'Test Project';
        dp.Report_ID__c = '123';
        dp.Dodge_Report_Version_Number__c = '1';
        dp.Dodge_Report_Number__c = '12';
        dp.Bid_Date__c = Date.today();
        insert dp;
        
        Dodge_Contact__c dc = new Dodge_Contact__c();
        dc.Firm_Name__c = 'TestAccount';
        dc.Contact_Name__c = 'Test Contact';
        dc.Dodge_Project__c = dp.Id;
        dc.Role__c = 'Architect';
        dc.Phone__c = '1234566890';
        dc.Email__c = 'test@test.com';
        dc.Address_Line_2__c = 'xyz';
        dc.Address_Line_3__c = 'pqr';
        insert dc;
        
        dc = new Dodge_Contact__c();
        dc.Firm_Name__c = 'Test Dodge Firm';
        dc.Contact_Name__c = 'Test Contact';
        dc.Dodge_Project__c = dp.Id;
        dc.Role__c = 'Architect';
        insert dc;
        
        Apexpages.currentPage().getParameters().put('id', dp.Id);
        DodgeConvertController dcc = new DodgeConvertController(new Apexpages.Standardcontroller(dp));
        System.currentPageReference().getParameters().put('rIndex', '0');
        dcc.dodgeContactList.get(0).accountOptSelected = a.Id;
        dcc.fetchContacts();
        Apexpages.currentPage().getParameters().put('primaryRowIndexValue', '0');
        dcc.dodgeContactList.get(0).contactSelected = c.Id;
        dcc.convert();
    }
    
    static testMethod void setDodgeProjectOwner_Test1() {
    	Group grp = new Group();
    	grp.Name = 'test group';
    	insert grp;
    	
    	Dodge_Queue__c dq = new Dodge_Queue__c();
    	dq.ZipCode__c = 'tzip1';
    	dq.Queue_Name__c = 'test queue';
    	insert dq;
    	
    	dq = new Dodge_Queue__c();
    	dq.ZipCode__c = 'tzip2';
    	dq.Queue_Name__c = 'test queue';
    	insert dq;
    	
    	Dodge_Project__c dp = new Dodge_Project__c();
        dp.Title__c = 'Test Project';
        dp.Report_ID__c = '123';
        dp.Dodge_Report_Version_Number__c = '1';
        dp.Dodge_Report_Number__c = '12';
        insert dp;
        
        Dodge_Contact__c dc = new Dodge_Contact__c();
        dc.Firm_Name__c = 'Test Firm';
        dc.Contact_Name__c = 'Test Contact';
        dc.Dodge_Project__c = dp.Id;
        dc.Role__c = 'Architect';
        dc.Address_Line_1__c = 'abc';
        dc.Address_Line_2__c = 'xyz';
        dc.Address_Line_3__c = 'pqr';
        dc.Zip_Code5__c = 'tzip1';
        insert dc;
        
        dc.Zip_Code5__c = 'tzip2';
        update dc;
        
        dc.Role__c = 'Test';
        update dc;
        
        dc.Role__c = 'Architect';
        dc.Zip_Code5__c = 'tzip1';
        update dc;
    }
}