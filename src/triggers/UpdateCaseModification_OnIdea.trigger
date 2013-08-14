/*********************************************************************************************************************
* Module Name   :  UpdateCaseModification_OnIdea Trigger
* Description   :  This Trigger is used to update Last Updated By and Last Updated fields on Parent Case Record of Idea.
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <Test_IdeaCaseModification>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
trigger UpdateCaseModification_OnIdea on Idea (after delete, after insert, after update) {
boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    Set<String> caseIDSet = new Set<String>();
     sObject sobj;
     
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            sobj = Trigger.new[0];
            for(Idea idea :Trigger.new) {
                if(idea.Case__c != null) {
                    caseIDSet.add(idea.Case__c);
                } 
              
            }
        }
        
        if(Trigger.isUpdate || Trigger.isDelete) {  
           sobj = Trigger.old[0];
           for(Idea idea :Trigger.Old) {
                if(idea.Case__c != null) {
                    caseIDSet.add(idea.Case__c);
                }               
            }               
        }
        
        String updateBy = UserInfo.getUserId();
        DateTime updateDate = DateTime.now(); 
        try {   
            Boolean updateFlag = CaseModificationUtility.updateCaseModificationActivity(caseIDSet, updateBy, updateDate);
            if(!updateFlag) {
                Trigger.New[0].addError('Error in Idea Related Case Updation');
            }
        } catch(DMLException e) {
            if(sobj != null)
                sobj.addError(e.getDmlMessage(0));   
        } catch(Exception e) {
            if(sobj != null)
                sobj.addError(e.getMessage());   
        }
    }  
}
}