/*********************************************************************************************************************
* Module Name   :  UpdateCaseModification_OnAssociatedCaseCR Trigger
* Description   :  This Trigger is used to update Last Updated By and Last Updated fields on Parent Case Record.
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <-->
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
trigger UpdateCaseModification_OnAssociatedCaseCR on Associated_Case_Change_Request__c (after delete, after insert, after update) {
boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{    
    Set<String> caseIDSet = new Set<String>();
    sObject sobj;
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            sobj = Trigger.new[0];
            for(Associated_Case_Change_Request__c ar :Trigger.new) {
                if(ar.Case__c != NULL) {
                    caseIDSet.add(ar.Case__c);
                } 
            }
        }
        
        if(Trigger.isUpdate || Trigger.isDelete) {
            sobj = Trigger.old[0];
            for(Associated_Case_Change_Request__c ar :Trigger.old) {
                if(ar.Case__c != NULL){
                    caseIDSet.add(ar.Case__c); 
                }
            }   
        }
        
        String updateBy = UserInfo.getUserId();
        DateTime updateDate = DateTime.now();  
        try {  
            Boolean updateFlag = CaseModificationUtility.updateCaseModificationActivity(caseIDSet, updateBy, updateDate);
            if(!updateFlag) {            
                sobj.addError('Error in Associated Case Last Update Details Updation');
            }
        } catch(DMLException e){
           if(sobj != null)
               sobj.addError(e.getDMLMessage(0));    
        } catch(Exception e){
            if(sobj != null)
                sobj.addError(e.getMessage());    
        }
    }
    
    //new functionality by b.matthews 2/21/13
    if(Trigger.isInsert) {
        Associated_Case_Change_Request__c[] items = Trigger.new;
        ChatterManagementService.CreateFollowers(items);
    }
    
}
}