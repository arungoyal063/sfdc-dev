/*********************************************************************************************************************
* Module Name   :  ShareConfidentialNoteAttachTrigger Trigger
* Description   :  This Trigger is Used to Share Confidential Notes and Attachments on Case with Case Contact
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
trigger ShareConfidentialNoteAttachTrigger on Confidential_Attachment_and_Note__c (after insert) {
      /* 2/25/2013; AIM; Do not run for data migration */ 
boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    Set<String> portalUser = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
    
    if(!portalUser.contains(UserInfo.getUserType())) {    
        List<Confidential_Attachment_and_Note__Share> shareList = new List<Confidential_Attachment_and_Note__Share>();
        Set<String> caseIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Map<String,String> caseUserMap = new Map<String,String>();
        Map<String,String> conatctCaseMap = new Map<String,String>();
        
        for(Confidential_Attachment_and_Note__c can: Trigger.New) {
            //List<Attachment> at = [Select Id,Name From Attachment Where ParentId =: can.Id]; && at.size() == 0
            if(can.Case__c != null) {
                caseIds.add(can.Case__c);                
            }    
        }
        
        list<Case> caseStatusUpdate = [SELECT Id, Status,Total_Billable_Minutes__c, Completion_Date__c, ClosedDate FROM Case WHERE Id IN :caseIds];        
        list<Case> tempCaseStatusUpdate = new list<Case>();
        
        List<CaseMilestone> toUpdate = new List<CaseMilestone>();
        Map<Id,CaseMilestone> milestones = new Map<Id,CaseMilestone>([SELECT
        CaseMilestone.Id,
        CaseMilestone.CaseId,
        CaseMilestone.CompletionDate
        FROM CaseMilestone
        WHERE CaseMilestone.CaseId IN: CaseIds
        and Case.Completion_Date__c = null]);
        
        for(CaseMilestone cm:milestones.values())
        {
            if (cm.CompletionDate == null)
            {
                cm.CompletionDate = Datetime.now();
                //cm.Iscompleted = true;
                toUpdate.add(cm);
            }
        }   
        if (!toUpdate.isEmpty()) {
            try { 
                update(toUpdate);
            } catch(DMLException e) {
                Trigger.New[0].addError(e.getDMLMessage(0));    
            } 
            catch(Exception e) {
                Trigger.New[0].addError(e.getMessage());      
            }
        } 
        for(Case cas:caseStatusUpdate){       
            //if(cas.Status != 'New'){
              //cas.Status = 'Client Action Required';
              //cas.Sub_Status__c = null;
            //}
            /*if(cas.Completion_Date__c == null){
                cas.Completion_Date__c = system.now();
            }*/
            tempCaseStatusUpdate.add(cas);
        }
        if(!tempCaseStatusUpdate.isEmpty()){
            system.debug('>>>>>>>>>>>>>>>>'+tempCaseStatusUpdate);
            try { 
               update tempCaseStatusUpdate;
            }catch(DMLException e) {
                    String dmlErrorMsg =  e.getDMLMessage(0);
                    Trigger.New[0].addError(dmlErrorMsg);                           
            }
            
        }
        
        if(!caseIds.isEmpty()) {
            Map<ID,Case> caseContactMap = new Map<ID,Case>([SELECT Id,ContactId FROM Case WHERE Id IN :caseIds AND ContactId != null]);
            for(String c: caseContactMap.keySet()) {
                conatctCaseMap.put(caseContactMap.get(c).ContactId,c);    
            }
            
            if(!conatctCaseMap.isEmpty()) {
                 Map<ID,User> contactUserMap  = new Map<ID,User>([SELECT Id, ContactId FROM User WHERE ContactId IN :conatctCaseMap.keySet()]);
                 for(String u :contactUserMap.keySet()) {                
                     caseUserMap.put(conatctCaseMap.get(contactUserMap.get(u).ContactId),u); 
                 }   
            }
            
          
            if(!caseUserMap.isEmpty()) {
                for(Confidential_Attachment_and_Note__c co: Trigger.New) {
                    if((co.Case__c != null) && caseUserMap.containsKey(co.Case__c)) {
                         Confidential_Attachment_and_Note__Share  shareObj = new Confidential_Attachment_and_Note__Share();
                         shareObj.UserOrGroupId = caseUserMap.get(co.Case__c);
                         shareObj.ParentId = co.Id;
                         shareObj.RowCause = Schema.Confidential_Attachment_and_Note__Share.RowCause.Manual;
                         shareObj.AccessLevel = 'Read';
                         shareList.add(shareObj);
                    }     
                }
            }
            
            if(!shareList.isEmpty()) {
                
                Database.SaveResult[] lsr = Database.Insert(shareList,false);
               
                Integer i=0;
                for(Database.SaveResult sr : lsr) {
                    if(!sr.isSuccess()){
                        // Get the first save result error
                        Database.Error err = sr.getErrors()[0];
                        trigger.newMap.get(shareList[i].ParentId).
                              addError(
                               'Unable to grant sharing access due to following exception: '
                               + err.getMessage());
                       
                    }
                    i++;
                }   
              
            }
           
        }
   }
}
}