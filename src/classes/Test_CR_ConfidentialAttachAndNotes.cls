@isTest

private class Test_CR_ConfidentialAttachAndNotes {

    static testMethod void Test_CR_ConfidentialAttachAndNotesUnitTest() { 
         User pu = MockTestData.getPortalUser(); 
         System.runas(pu) {
             Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created 
             ApexPages.currentPage().getParameters().put('id', orgCase.Id);
             CR_ConfidentialAttachAndNotesController ct = new CR_ConfidentialAttachAndNotesController();
             ct.saveCon();
             ct.renderAction();
             ct.doSave();
             ct.selType = 'Note';
             ct.conNote.Title= 'Test';
             ct.conNote.Body = 'Test';
             ct.doSave();
            
             ct.selType = 'Attachment';         
             ct.saveAttachment();
             
             ct.conAttach = new Attachment();
             ct.conAttach.Name = 'Test';
             ct.conAttach.Body = Blob.valueOf('Test');
             ct.saveAttachment();
             ct.validateFields();
             ct.doCancel();
         }
     }
     
     static testMethod void ShareConfidentialNoteAttachUnitTest() {
         User pu = MockTestData.getPortalUser();   
         System.runas(pu) {
         
             Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');
             User u = [Select ContactId from User where Id =:pu.Id];
             Contact con = [Select Id from Contact where Id = :u.ContactId];
             
             orgCase.ContactId = con.Id;
             update orgCase;
         
             MockTestData.createConfidentialAttachNoteRecord(orgCase.Id, 'Test');
                 
         }        
     }
}