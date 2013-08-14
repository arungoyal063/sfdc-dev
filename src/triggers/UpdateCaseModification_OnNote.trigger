/*********************************************************************************************************************
* Module Name   :  UpdateCaseModification_OnNote Trigger
* Description   :  This Trigger is used to update Last Updated By and Last Updated fields on Parent Case Record of Note.
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
trigger UpdateCaseModification_OnNote on Note (after delete, after insert, after update) {
boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    /*** Update Parent Case Last Update Details ***/
    Set<String> caseIDSet = new Set<String>();
    String updateBy = UserInfo.getUserId();
    DateTime updateDate = DateTime.now();    
    Sobject sobj;
    if(Trigger.isAfter) {
        
        if(Trigger.isInsert || Trigger.isUpdate) {
            sobj = Trigger.new[0];
            for(Note a: Trigger.new) {
                caseIDSet.add(a.ParentId); 
            }
        }    
        
        if(Trigger.isUpdate || Trigger.isDelete) {
            sobj = Trigger.Old[0];
            for(Note a: Trigger.Old) {
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
                    sobj.addError('Error in Parent Case Updation');
                }
            }
        } catch(DMLException e) {
            if(sobj != null)
                sobj.addError(e.getDmlMessage(0));   
        } catch(Exception e) {
            if(sobj != null)
                sobj.addError(e.getMessage());   
        }
    } 
    /*** Update Parent Case Last Update Details ***/

}
}