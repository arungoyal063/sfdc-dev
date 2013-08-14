/*********************************************************************************************************************
* Module Name   :  UpdateCaseStatus_OnCaseComment Trigger
* Description   :  This Trigger is used to update the status of Parent Case Record of Case Comment.
* Throws        :  <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  <Test_CaseComment_CaseModification>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      17/06/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
trigger UpdateCaseStatus_OnCaseComment on CaseComment (after insert) {
    boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
    if (ignoreTriggers==false)
    { 
        Set<String> caseIDSet = new Set<String>();
        List<Case> updateCaseList = new List<Case>();       
        
        if(Trigger.isInsert) {
            for(CaseComment cc :Trigger.new) {
               if(cc.IsPublished){
                  caseIDSet.add(cc.ParentId); 
               }  
            }
        }       
        
        if(!caseIdSet.isEmpty()){
            List<Case> caseList = [SELECT Id FROM Case WHERE Id IN: caseIdSet];            
            if(!caseList.isEmpty()){
                for(Case caseObj: caseList){
                    caseObj.Status = 'Client Action Required';
                    caseObj.Sub_Status__c = '';
                    caseObj.Completion_Date__c = system.now();
                    updateCaseList.add(caseObj);
                }
            }           
        }        
            
        if(!updateCaseList.isEmpty()) {
            try {
                update updateCaseList;
            } catch(DMLException e) {
                System.debug('Error' + e.getDMLMessage(0));
            } catch(Exception e) {
                System.debug('Error' + e.getMessage());
            }    
        }
        
    }
}