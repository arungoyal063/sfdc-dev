@isTest
private class Test_contentVersionTrigger {

    static testMethod void myUnitTest() {
        /*Account acc= MockTestData.createAccountRecord('Abc', 120);
        Contact con = MockTestData.createContactRecord('Test', acc.Id);
     	Opportunity o = new Opportunity();
     	//o.RecordType='Opportunity';
        o.accountid = acc.id;
        o.name = 'test';
        o.amount = 100;
        o.closedate = system.today();
        o.Contract_Status__c = 'Signed';
        o.Team__c  = '01 - North';
        o.Opportunity_Type__c = 'Services Only';
        o.Solution__c = 'Banner';
        o.Summary__c = 'Test';
        o.stagename = 'Proposal';
        o.ForecastCategoryName  = '0 - Closed';
        o.LeadSource = 'Contract Vehicle';
        o.Has_Primary_Contact__c = TRUE;
        o.Services_Planned_Start_Date__c =system.today();
        o.Services_Planned_End_Date__c =system.today();
        o.Primary_Contact_2__c =con.id;
        o.CurrencyIsoCode = 'USD';
        o.IsPrivate = false;
        o.deal_review_required__c = false;
        o.ap_survey_results_call__c = false;
        o.ilp__c = false;
        o.key_deal__c = false;
        o.colleague_erp__c = false;
        o.is_new_account__c = false;
        o.request_contract__c = false;
        o.synced_to_clarity__c = true;
        o.is_ms_signed__c = true;
        o.pre_sales_resource_confirmed__c = false;
		o.port_to_sql__c = false;
		o.other__c = false;			            
        insert o;
        
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Sales Documents'];
		ContentVersion testContentInsert =new ContentVersion();
		testContentInsert.ContentURL='http://www.google.com/';
		testContentInsert.Title ='Google.com';
		testContentInsert.re
		insert testContentInsert; */
		ContentVersion testContentInsert = new ContentVersion();
		testContentInsert.ContentURL='http://www.google.com/';
		testContentInsert.Title = 'Google.com';
		//testContentInsert.RecordTypeId = ContentRT.Id;
		
		insert testContentInsert; 
    }
}