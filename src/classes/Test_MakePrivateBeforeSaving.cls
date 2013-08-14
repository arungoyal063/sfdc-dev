/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<TestMakePrivateBeforeSaving>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<22-11-2012>>
// Last Modified Date.....: <<22-11-2012>>
// Description/Requirement: <<Test Class for MakePrivateBeforeSaving Trigger>>
//---------------------------------------------------------------------------------------------------------------------------*/
@isTest 
private class Test_MakePrivateBeforeSaving {
    static testMethod void MakePrivateTriggerUnitTest() { 
        User pu = MockTestData.getPortalUser();     
        System.runAs(pu){
            Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test'); // Case Created 
            Case cc = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test'); // Case Created       
            System.assertNotEquals(null,c.Id);
            Attachment a = new Attachment(Name = 'Test', ParentId = c.Id, Body = Blob.valueOf('Test'));  // Attachment Created 
            a = new Attachment(Name = 'Test', ParentId = c.Id, Body = Blob.valueOf('Test'));  // Attachment Created
            try{  
                insert a;
                //To get Created Attchment  
                Attachment att = [SELECT isPrivate from Attachment WHERE id=:a.Id limit 1];
                System.assertEquals(false,att.isPrivate);  
                delete a;
                // add attachment to a closed case            
                a = new Attachment(Name = 'Test', ParentId = cc.Id, Body = Blob.valueOf('Test'));  // Attachment Created
                insert a;
            }catch(Exception ex){
                System.debug('Error :'+ex);
            } 
        }
           
    }
}