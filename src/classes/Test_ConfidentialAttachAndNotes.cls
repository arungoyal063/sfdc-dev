/*********************************************************************************************************************
* Module Name   :  Test_IdeaCaseModification Test Class 
* Description   :  Test Class for ConfidentialAttachAndNotesController
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/


@isTest 
private class Test_ConfidentialAttachAndNotes{
     static testMethod void Test_ConfidentialAttachAndNotesUnitTest() { 
         User pu = MockTestData.getPortalUser(); 
         System.runas(pu) {         	
         	/*Account a = MockTestData.createAccountRecord('MyTest Account', 500);
         	Case c1 = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');
         	ApexPages.currentPage().getParameters().put('id', string.valueof(c1.Id));
			Confidential_Attachment_and_Note__c cAN = MockTestData.createConfidentialAttachNoteRecord(c1.Id, 'Test');  //Create Confidential_Attachment_and_Note__c
         	Contact cnct = new Contact();
			cnct.LastName='LastName';
			cnct.FirstName='FirstName';
			cnct.AccountId=a.Id;
			insert cnct;
         	Opportunity o = new Opportunity();
	        o.accountid = a.id;
	        o.name = 'test';
	        o.amount = 100;
	        o.closedate = system.today();
	        o.Contract_Status__c = 'Signed';
	        o.Team__c  = '01 - North';
	        o.Opportunity_Type__c = 'Services Only';
	        o.Solution__c = 'Banner';
	        o.Summary__c = 'Test';
	        o.recordtypeid = '012G0000000yBn3IAE';
	        o.stagename = 'Proposal';
	        o.ForecastCategoryName  = '0 - Closed';
	        o.LeadSource = 'Contract Vehicle';
	        o.BAS_Territory__c = '005G0000001xxOwIAI';
	        o.ISR_Territory__c = '005G0000001xxOwIAI';
	        o.Has_Primary_Contact__c = TRUE;
	        o.Services_Planned_Start_Date__c =system.today();
	        o.Services_Planned_End_Date__c =system.today();
	        o.Primary_Contact_2__c =cnct.id;
	        o.CurrencyIsoCode = 'USD';
	        //system.debug('******************************'+o1.id);
	        //o.Parent_Action_Plan__c = o1.id;
	        insert o;
         	Note n1 = new Note();    //Create Note
        	n1.ParentId = o.Id;
       	 	n1.Title = 'test';
        	n1.Body = 'test';
        	insert n1;
        	Attachment att1 = new Attachment(ParentId=c1.Id,Name='att1',body= Blob.valueOf('Unit Test Attachment Body'));   //Create Attachment 
        	insert att1;
        	ConfidentialAttachAndNotesController cACobj = new ConfidentialAttachAndNotesController(); 
        	cACobj.noteAttachRecord = cAN;
        	cACobj.conNote = n1;
        	cACobj.conAttach = att1;
        	cACobj.selType = 'Attachment';*/
        	
			 Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created 
			 ApexPages.currentPage().getParameters().put('id', orgCase.Id);
			 ConfidentialAttachAndNotesController ct = new ConfidentialAttachAndNotesController();
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