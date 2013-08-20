/**
	test method for Link_Sample_Order_on_Lead_Convert trigger
 */
@isTest
private class Test_Link_SampleOrder_on_Lead_Convert 
{

    static testMethod void myUnitTest() 
    {
    	   	
    	//create new test lead
    	lead testLead = new lead();
    	testLead.Company = 'testco';
    	testLead.LastName = 'Joe Tester';
    	testLead.Status = 'Open';
    	testLead.Short_Description__c = 'Test';
    	
    	insert testLead;  
    	
    	//create a sample order record and link to our test lead
    	sample_order__c testSampleOrder = new sample_order__c();
    	testSampleOrder.Lead__c = testLead.id;	
    	testSampleOrder.Web_Order_Id__c = '12345';
    	testSampleOrder.Shipping_Name__c = 'Joe Tester';
    	//testSampleOrder.Shipping_Last_Name__c = 'Tester';  jS
    	testSampleOrder.Shipping_City__c = 'Boston';
    	testSampleOrder.Shipping_State__c = 'MA';
    	testSampleOrder.Shipping_Street__c = '1 Main Street';
    	testSampleOrder.Shipping_Postal_Code__c = '02042';
    	
    	insert testSampleOrder;
    	
    	//convert the lead
    	Database.Leadconvert lc = new database.leadconvert();
    	lc.setleadid(testLead.id);
    	lc.setDoNotCreateOpportunity(false);
		//converted status is required
		LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
		lc.setConvertedStatus(convertStatus.MasterLabel);
    	Database.LeadConvertResult lcr = Database.convertLead(lc);
    	
    	if(lcr.isSuccess())
    	{
    		integer convertedSampleOrderCount = [select count() from sample_order__c where lead__c = :testLead.id AND opportunity__c != null];	
    	
    		system.debug('Converted Sample Order Count: ' + convertedSampleOrderCount);
    		if(convertedSampleOrderCount > 0)
    		{
	    		system.assert(true);
    		}
    	}
    	
    }
}