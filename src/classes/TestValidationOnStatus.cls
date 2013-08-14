/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<TestValidationOnStatus>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<22-11-2012>>
// Last Modified Date.....: <<22-11-2012>>
// Description/Requirement: <<Test Class for ValidationOnStatus Trigger>>
//---------------------------------------------------------------------------------------------------------------------------*/
@isTest 
private class TestValidationOnStatus {
    static testMethod void valTriggerUnitTest() {        
        Case c = MockTestData.createCaseRecord('New', 'Email', 'Level 3', 'Test','Test');  // Case Created 
        Change_Request__c cr = MockTestData.createCRRecord('Test');  // Change Request Created 
        Account a =  MockTestData.createAccountRecord('Test',100);   // Account Created 
        Associated_Case_Change_Request__c accr = MockTestData.createAssociatedCaseCRRecord(c.Id, cr.Id);
        c.AccountId = a.Id;
        update c;
        System.assertEquals(c.AccountId,a.Id);
        
        try {
            c.Status = 'Change Request Open';   
            c.Sub_Status__c = 'Defect';     
            update c;
        } catch(Exception e){
            System.Debug('Error :;'+ e);
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Change Request Open Status : No Change Request Associated With the Case!'), 
                e.getMessage());
        }
        try { 
            cr.Originating_Case__c = c.Id;
            update cr;               
            c.Total_Billable_Minutes__c = 100;              
            update c;        
            c.Status = 'Closed';
        } catch(Exception e) {
            System.debug('Error :' + e);
        }           
        try {
            update c;
        } catch(Exception e){
            System.Debug('Error ::' + e.getMessage());
            //System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, You are not authorise to Close this Case,Please contact your Administrator!'), 
                //e.getMessage());
        } 
        
    }    
}