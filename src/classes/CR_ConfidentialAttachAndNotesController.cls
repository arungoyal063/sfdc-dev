/*********************************************************************************************************************
* Module Name   :  CR_ConfidentialAttachAndNotesController Apex Controller 
* Description   :  Test_ConfidentialAttachAndNotes
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

public Class CR_ConfidentialAttachAndNotesController {
    
    public Confidential_Attachment_and_Note__c noteAttachRecord{get; set;}
    public Note conNote{get; set;}    
    public Attachment conAttach{get; set;}
    public String selType{get; set;}
    public String crId;
    public Change_Request__c CRRecord;
    public String buttonText{get; private set;}
    public String fileName {get; private set;}
    public String filesize {get; private set;}
    
    public CR_ConfidentialAttachAndNotesController() {
        noteAttachRecord = new Confidential_Attachment_and_Note__c ();
        conNote = new Note();       
        conAttach = new Attachment();
        buttonText = 'Save';
        crId = ApexPages.currentPage().getParameters().get('id');
        if( crId != NULL && (!crId.trim().equals(''))) {
            List<Change_Request__c> CRList = [SELECT Id FROM Change_Request__c WHERE Id = :crId LIMIT 1];
            if(!CRList.isEmpty()) {
                CRRecord = CRList.get(0);
                noteAttachRecord.Change_Request__c = CRList.get(0).Id;
                selType = 'Note';
            }
        }
    }
    
    public void saveCon() {
       try {
           insert noteAttachRecord;    
       } catch(Exception e) {
           ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
       }
    }
    
    public void renderAction() {
        if(selType != NULL) {
            if(selType.equals('Attachment')){
                buttonText = 'Done';
            } else if (selType.equals('Note')) {
                buttonText = 'Save';
            }
        }        
    }
    
    public PageReference doSave() {
        try {
            if(!validateFields()) {           
                if(noteAttachRecord.Id != NULL) {
                    
                    if(selType.equals('Note') && conNote != NULL) {
                        update noteAttachRecord;                    
                        conNote.ParentId = noteAttachRecord.Id;
                        insert conNote;
                        if(conNote.Id != NULL) {
                            update CRRecord;
                            return new PageReference('/' + crId);
                        }
                    }  else {
                        return new PageReference('/' + crId);   
                    }               
                }    
            }
        } catch(DMLException e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));     
        } catch(Exception e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));     
        }
        return null;  
    }
    
    public PageReference doCancel() {
         if(noteAttachRecord != NULL) {
             delete noteAttachRecord;
         }
         return new PageReference('/' + crId);
    }
    
    public void saveAttachment() {
            try {
            if(selType.equals('Attachment') && conAttach != NULL) {
                if(conAttach.body == NULL) {
                      ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify a file to upload. Type in the path to the file, or use the "Browse" button to locate it in your local filesystem.')); 
                } else {
                    if(noteAttachRecord.Id != null) {
                        update noteAttachRecord; 
                        conAttach.ParentId = noteAttachRecord.Id;
                        fileName = conAttach.Name;                
                        insert conAttach;
                        if(conAttach.Id != null) {
                            //CRRecord.status = 'Customer Update';
                            update CRRecord;
                        }
                        conAttach = new Attachment();  
                    }  
                }
            }  
        } catch(DMLException e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));     
        } catch(Exception e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));     
        }      
    }
    
    public Boolean validateFields() {
         if(selType != NULL && selType != '') {
            if(selType.equals('Note') && conNote != NULL) {
                if(conNote.Title == NULL || conNote.Title.trim() == '') {
                      ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Enter Note Title.'));
                      return true;  
                }
            } 
        }        
        return false;
    }
    
}