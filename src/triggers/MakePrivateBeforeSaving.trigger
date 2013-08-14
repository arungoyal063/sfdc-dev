/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<ValidationOnStatus>> 
// Version................: <<1.0>>
// Created Date...........: <<23-11-2012>>
// Last Modified Date.....: <<23-11-2012>>
// Description/Requirement: <<1-This will be handled though Case Comments or through an APEX trigger that updates the status to "Open" when an attachment is uploaded.
                              2-Ability to add/remove attachments to a case with an audience field on the attachment>>
//---------------------------------------------------------------------------------------------------------------------------*/

trigger MakePrivateBeforeSaving on Attachment (before insert,after insert,after update,after delete) {
   /* 2/25/2013; AIM; Do not run for data migration */ 
   
boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    /* Added code for 1nd requirement CM#60*/
    Set<String> portalUser = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
   
   if(!portalUser.contains(UserInfo.getUserType())) {    
        if(Trigger.isBefore && Trigger.isInsert) {            
            String ParentId;
            for(Attachment a: Trigger.new) {
                ParentId = a.ParentId;
                /*
                    @Description: If a attachment is added on "Case" or "Change Request" then by default it should be private
                    @Hard code value1: a0G => Id prefix of "Change Request" object.
                    @Hard code value2: 500 => Id prefix of "Case".
                */
                if (ParentId.Left(3) == 'a0G'|| ParentId.Left(3) == '500') {
                    a.IsPrivate = false;
                }        
            }
        }
    }
    
    /* Added code for 1nd requirement CM#111*/
    if(Trigger.isAfter && Trigger.isInsert) {
        /*To collect parent Id of Attachment*/
        Set<Id> attechmentParentId = new Set<Id>();
        Map<String,Integer> attCountMap = new Map<String,Integer>();
        
        for(Attachment att: Trigger.new) {
            attechmentParentId.add(att.ParentId);
            if(attCountMap.containsKey(att.ParentId)) {
                attCountMap.put(att.ParentId, attCountMap.get(att.ParentId) + 1);
            }
            else {
                attCountMap.put(att.ParentId, 1);
            }
            
        }
        list<Case> caseStatusUpdate = [SELECT Id, Status,Total_Billable_Minutes__c, ClosedDate,Completion_Date__c,Sub_Status__c FROM Case WHERE Id IN :attechmentParentId];        
        list<Case> tempCaseStatusUpdate = new list<Case>();
        if(!caseStatusUpdate.isEmpty()) {
            /*To update status of the case to open.*/
            List<CaseComment> caseCommentList = new List<CaseComment>();
            for(Case cas: caseStatusUpdate) {                
                if((cas.Total_Billable_Minutes__c > 0) && (cas.ClosedDate != null) &&                                                                
                   ((dateTime.now().year() > cas.ClosedDate.year()) || ((dateTime.now().year() == cas.ClosedDate.year()) && (dateTime.now().month() > cas.ClosedDate.month())))) {
                        Trigger.New[0].addError('You cannot upload an attachment to case, Beacuse Case has already been closed.Please contact your Administrator!');
                    
                } else if((cas.ClosedDate != null) && (cas.ClosedDate.date().daysBetween(Date.Today()) > 30) ){  
                    Trigger.New[0].addError('You are not authorized to update or re-open this case due to the time elapsed since it was closed. Please open a new case for assistance with your issue.');
                } else {  
                    if(portalUser.contains(UserInfo.getUserType())) {     
                        //status update by case comment insert
                        CaseComment cc = new CaseComment();
                        cc.ParentId = cas.Id;
                        cc.CommentBody = attCountMap.get(cas.Id) + ' new attachment uploaded';
                        caseCommentList.add(cc);
                    }   
                }
                if(!portalUser.contains(UserInfo.getUserType())) {
                    // David asked not to update case status whenever any attachment gets uploaded to cases UAT 7-1 1413
                    /*if(cas.Status != 'New'){
                       cas.Status = 'Client Action Required';
                       cas.Sub_Status__c = '';
                    } */  
                    if(cas.Completion_Date__c == null){
                        cas.Completion_Date__c = system.now();
                    }
                    tempCaseStatusUpdate.add(cas);  
                }
            }
            try {
                //system.debug('------------------'+tempCaseStatusUpdate);
                //Case Status Update by Case Comment Insert
                if(!tempCaseStatusUpdate.isEmpty()){
                    update tempCaseStatusUpdate;
                }
                insert caseCommentList;
            } catch(DMLException e) {
                System.debug('Error ::' + e);
                Trigger.New[0].addError(e.getDmlMessage(0));   
            } catch(Exception e) {
                System.debug('Error' + e);
                Trigger.New[0].addError(e.getMessage());
            }
        }
    }
    
    /*** Update Parent Case Last Update Details ***/
    Set<String> caseIDSet = new Set<String>();
    String updateBy = UserInfo.getUserId();
    DateTime updateDate = DateTime.now();    
    Sobject sobj;
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            sobj = Trigger.new[0];
            for(Attachment a: Trigger.new) {
                caseIDSet.add(a.ParentId); 
            }
        }    
        if(Trigger.isUpdate || Trigger.isDelete) {
            sobj = Trigger.Old[0];
            for(Attachment a: Trigger.Old) {
                caseIDSet.add(a.ParentId); 
            }   
        }    
        
        try {
            if(!caseIDSet.isEmpty()) {
                List<Confidential_Attachment_and_Note__c> caList = [SELECT Id, Case__c FROM Confidential_Attachment_and_Note__c WHERE Id IN :caseIDSet AND Case__c != null];          
                for(Confidential_Attachment_and_Note__c ca :caList) {
                    caseIDSet.remove(ca.Id);
                    caseIDSet.add(ca.Case__c);      
                }                                                    
           
                Boolean updateFlag = CaseModificationUtility.updateCaseModificationActivity(caseIDSet, updateBy, updateDate);
                if(!updateFlag) {
                    Trigger.New[0].addError('Error in Parent Case Updation');
                }
            }
        } catch(DMLException e) {
            sobj.addError(e.getDmlMessage(0));   
        } catch(Exception e) {
            sobj.addError(e.getMessage());   
        }
    } 
  }
    /*** Update Parent Case Last Update Details ***/
}