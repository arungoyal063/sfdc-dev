/*********************************************************************************************************************
* Module Name   :  UpdateCaseModification_OnCaseComment Trigger
* Description   :  This Trigger is used to update Last Updated By and Last Updated fields on Parent Case Record of Case Comment.
* Throws        :  <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  <Test_CaseComment_CaseModification>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
trigger UpdateCaseModification_OnCaseComment on CaseComment (after delete, after insert, after update) {
   boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{ 
    Set<String> caseIDSet = new Set<String>();
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            for(CaseComment cc :Trigger.new) {
                caseIDSet.add(cc.ParentId); 
            }
        }
        
        if(Trigger.isUpdate || Trigger.isDelete) {
            for(CaseComment cc :Trigger.old) {
                caseIDSet.add(cc.ParentId);              
            }   
        }
        
        
        String updateBy = UserInfo.getUserId();
        DateTime updateDate = DateTime.now();
            
        try {    
            Boolean updateFlag = CaseModificationUtility.updateCaseModificationActivity(caseIDSet, updateBy, updateDate);
            if(!updateFlag) { Trigger.New[0].addError('Error in Parent Case Updation');}
        } catch(DMLException e) {
            Trigger.New[0].addError(e.getDmlMessage(0));   
        }catch(Exception e) {
            Trigger.New[0].addError(e.getMessage());   
        }
    }
    
}
}