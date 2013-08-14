/*********************************************************************************************************************
* Module Name   :  UpdateCaseModification_OnBillableTime Trigger
* Description   :  1.This Trigger is used to update Last Updated By and Last Updated fields on Parent Case Record of Billable Time.
                   2. This Trigger Updates Billable Minutes on the task related to Billable Time record
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <Test_BillableTimeCaseModification>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
trigger UpdateCaseModification_OnBillableTime on Billable_Time__c(after delete, after insert, after update) {
    
  boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{  Set<String> caseIDSet = new Set<String>();
    Set<String> taskIds = new Set<String>(); 
    
    if(Trigger.isAfter && TriggerRunOnce.billRunOnce()) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            for(Billable_Time__c bt :Trigger.new){
                if(bt.Case__c != null) {
                    caseIDSet.add(bt.Case__c);
                } 
                if(bt.Task_ID__c != null) {
                    taskIds.add(bt.Task_ID__c);
                }
            }
           List<Task> taskList = new List<Task>();
           for(Task t :[SELECT Id, Billable_Time__c, Billable_Minutes__c FROM Task WHERE Id IN :taskIds]){
               if(t.Billable_Time__c != null) {
                   if(Trigger.NewMap.containsKey(t.Billable_Time__c)) {
                       t.Billable_Minutes__c = Trigger.NewMap.get(t.Billable_Time__c).Minutes__c;
                       taskList.add(t);
                   }
               }               
           }
           
           if(!taskList.isEmpty()) {
               try {
                   update taskList;   
               } catch(DMLException e) {
                   Trigger.New[0].addError(e.getDMLMessage(0));
               }catch(Exception e) {
                   Trigger.New[0].addError(e.getMessage());
               }
           }
            
        }
        
        
        
        if(Trigger.isUpdate || Trigger.isDelete) {  
           for(Billable_Time__c bt :Trigger.Old) {
                if(bt.Case__c != null) {
                    caseIDSet.add(bt.Case__c);
                }               
            }               
        }
        
        String updateBy = UserInfo.getUserId();
        DateTime updateDate = DateTime.now(); 
        try {   
            Boolean updateFlag = CaseModificationUtility.updateCaseModificationActivity(caseIDSet, updateBy, updateDate);
            if(!updateFlag) {
                Trigger.New[0].addError('Error in Billabe Time Related Case Updation');
            }
        }catch(DMLException e) {
            Trigger.New[0].addError(e.getDmlMessage(0));   
        }catch(Exception e) {
            Trigger.New[0].addError(e.getMessage());   
        }
    }
        
}
}