/*********************************************************************************************************************
* Module Name   :  ConfidentialAttachAndNotesController Apex Controller 
* Description   :  ConfidentialAttachAndNotesController Controller Extension
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : Test_ConfidentialAttachAndNotes
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/

public Class ConfidentialAttachAndNotesController {
    
    public Confidential_Attachment_and_Note__c noteAttachRecord {get; set;}
    public Note conNote {get; set;}    
    public Attachment conAttach {get; set;}
    public String selType {get; set;}
    public String caseId;
    public Case cs;
    public String buttonText {get; private set;}
    public String fileName {get; private set;}
    public String filesize {get; private set;}
    public String showMessage {get; set;}
    public String showMessage1 {get; set;}
    
    // community and customer portal user type
    private Set<String> portalUser = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
    
    public ConfidentialAttachAndNotesController() {
        noteAttachRecord = new Confidential_Attachment_and_Note__c ();
        conNote = new Note();       
        conAttach = new Attachment();
        buttonText = 'Save';
        showmessage = 'false';
        showmessage1 = 'false';
        caseId = ApexPages.currentPage().getParameters().get('id');
        if( caseId != NULL && (!caseId.trim().equals(''))) {
            List<Case> caseList = [SELECT Id,Status,ClosedDate FROM Case WHERE Id = :caseId LIMIT 1];
            if(!caseList.isEmpty()) {
                cs = caseList.get(0);
                noteAttachRecord.Case__c = caseList.get(0).Id;
                selType = 'Note';
            }
        }
    }
    
    public void saveCon() {
       try {
           //insert noteAttachRecord;   
           
       } catch(Exception e) {
           ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
       }
    }
    
    public void renderAction() {
        showmessage = 'false';
        showmessage1 = 'false';
        if(selType != NULL) {
            if(selType.equals('Attachment')){
                buttonText = 'Done';
            } else if (selType.equals('Note')) {
                buttonText = 'Save';
            }
        }        
    }
    
    public PageReference doSave() {
        if(cs.ClosedDate != null){
                    if(Integer.valueOf((System.Now().getTime() -  cs.ClosedDate.getTime())/(1000*60*60*24))>30){
                    String customErrorMsg = 'Error: Invalid Data.\nReview all error messages below to correct your data.\nThis case has been closed greater than 30 days ago, you cannot add additional comments. Please submit a new case.';
                    showmessage = 'true';
                    return null;
                    }
        }

        if(!validateFields()) { 
        
            Savepoint sp = Database.setSavepoint();
            if(selType.equals('Note') && conNote != NULL) {
            if(noteAttachRecord != null ) {
                try{
                    insert noteAttachRecord ;
                }
                catch(Exception ex)
                {   
                    if(cs.ClosedDate != null){
                    if(Integer.valueOf((System.Now().getTime() -  cs.ClosedDate.getTime())/(1000*60*60*24))>30){
                    String customErrorMsg = 'Error: Invalid Data.\nReview all error messages below to correct your data.\nThis case has been closed greater than 30 days ago, you cannot add additional comments. Please submit a new case.';
                    showmessage = 'true';
                    return null;
                    }
                    }
                    showmessage1 = 'true';
                    //ApexPages.getMessages().clear();
                    //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                    return null;
                    //try{
                    //throw new MyCustomException(customErrorMsg);}catch(MyCustomException e) {
                        //Database.rollback(sp);
                        //ApexPages.getMessages().clear();
                        //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, customErrorMsg));
                        //return null; }                      
                }
            }                  
            if(noteAttachRecord.Id != NULL) {
                noteAttachRecord = [SELECT Id, Name, Case__c, Comments__c  FROM Confidential_Attachment_and_Note__c WHERE Id = :noteAttachRecord.Id];
                conNote.ParentId = noteAttachRecord.Id;
                try
                {
                    insert conNote;
                }
                catch(Exception ex)
                {
                    //ApexPages.getMessages().clear();
                    if(cs.ClosedDate != null){
                    if(Integer.valueOf((System.Now().getTime() -  cs.ClosedDate.getTime())/(1000*60*60*24))>30){
                    String customErrorMsg = 'Error: Invalid Data.\nReview all error messages below to correct your data.\nThis case has been closed greater than 30 days ago, you cannot add additional comments. Please submit a new case.';
                    showmessage = 'true';
                    return null;
                    }
                    }
                    showmessage1 = 'true';
                    return null;
                    //throw new MyCustomException(customErrorMsg);
                }
                
                
                if(conNote.Id != NULL && portalUser.contains(UserInfo.getUserType())) {
                    // update case status to client update by note from community user
                    /*if(cs.status != 'Client Update') {
                        cs.status = 'Client Update';
                    }*/
                    
                    System.debug('Error in Class...');
                    // Case Comment by confidential Note
                    CaseComment cc = new CaseComment();
                    cc.ParentId = noteAttachRecord.Case__c;
                    cc.CommentBody = 'New Note ' + noteAttachRecord.Name + ' Created';                        
                    try {
                        //Case status update by case comment insert
                        //update cs; 
                        insert cc;
                    } catch(DMLException e) {
                        Database.rollback(sp);
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));        
                        showmessage1 = 'true';
                        return null;
                    } catch(Exception e) {
                        Database.rollback(sp);
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                        showmessage1 = 'true';
                        return null;     
                    }
                }
                return new PageReference('/' + caseId);    
            }   
        } else {
             if(selType.equals('Attachment')){
                  update noteAttachRecord;
             } 
             return new PageReference('/' + caseId);      
        }
        }
        return null;
    }
    
    public PageReference doCancel() {
        return new PageReference('/' + caseId);
    }
    
    public void saveAttachment() {
        Savepoint sp = Database.setSavepoint();
        
         if(noteAttachRecord != null) {
             if(noteAttachRecord.Id == null) {
                 try{
                    insert noteAttachRecord ;
                }
                catch(Exception ex)
                {   
                    if(cs.ClosedDate != null){
                    if(Integer.valueOf((System.Now().getTime() -  cs.ClosedDate.getTime())/(1000*60*60*24))>30){
                    String customErrorMsg = 'Error: Invalid Data.\nReview all error messages below to correct your data.\nThis case has been closed greater than 30 days ago, you cannot add additional comments. Please submit a new case.';
                    showmessage = 'true';
                    //return null;
                    }else{showmessage1 = 'true';}
                    
                    }
                    
                    //return null;
                }    
                 
                 if(noteAttachRecord.Id != null) {
                     noteAttachRecord = [SELECT Id, Name, Case__c, Comments__c  FROM Confidential_Attachment_and_Note__c WHERE Id = :noteAttachRecord.Id];   
                 }
             }   
         }
         
        if(noteAttachRecord.Id != NULL) { 
            try{
                    update noteAttachRecord; 
                }
                catch(Exception ex)
                {   
                    if(cs.ClosedDate != null){
                    if(Integer.valueOf((System.Now().getTime() -  cs.ClosedDate.getTime())/(1000*60*60*24))>30){
                    String customErrorMsg = 'Error: Invalid Data.\nReview all error messages below to correct your data.\nThis case has been closed greater than 30 days ago, you cannot add additional comments. Please submit a new case.';
                    showmessage = 'true';
                    //return null;
                    }
                    }
                    else{showmessage1 = 'true';}
                    //return null;
                }
            
            if(selType.equals('Attachment') && conAttach != NULL) {
                if(conAttach.body == NULL) {
                      ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify a file to upload. Type in the path to the file, or use the "Browse" button to locate it in your local filesystem.')); 
                } else {
                    conAttach.ParentId = noteAttachRecord.Id;
                    fileName = conAttach.Name;                
                    insert conAttach;
                    if(conAttach.Id != null && portalUser.contains(UserInfo.getUserType())) {
                        // update case status to client update by attachment from community user
                        /*if(cs.status != 'Client Update') {
                            cs.status = 'Client Update';
                        }*/
                        // Case Comment by confidential Attachment
                        CaseComment cc = new CaseComment();
                        cc.ParentId = noteAttachRecord.Case__c;
                        cc.CommentBody ='New Attachment ' + noteAttachRecord.Name + ' Added';
          
                        try {
                            //Case status update by case comment insert
                            //update cs;
                            insert cc;
                        } catch(DMLException e) {
                            Database.rollback(sp);
                            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));                                  
                            showmessage1 = 'true';
                        } catch(Exception e) {
                            Database.rollback(sp);
                            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));  
                            showmessage1 = 'true';
                        }
                    }
                    conAttach = new Attachment();    
                }
            } 
        }       
    }
    
    public Boolean validateFields() {
         if(selType != NULL && selType != '') {
            
            if(selType.equals('Note') && conNote != NULL) {
                if(conNote.Title == NULL || conNote.Title.trim() == '') {
                      ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Enter Note Title.'));
                      showmessage1 = 'true';
                      return true;  
                }
            } 
        }        
        return false;
    }
    
}