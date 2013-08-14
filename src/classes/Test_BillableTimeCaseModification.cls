/*********************************************************************************************************************
* Module Name   :  Test_BillableTime _CaseModification Test Class 
* Description   :  Test Class for UpdateCaseModification_OnBillableTime trigger on Billable Time Object
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
@isTest(seeAllData = true) 
private class Test_BillableTimeCaseModification{
     static testMethod void Test_BillableTimeCaseModificationUnitTest() { 
         Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created
         Case relCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created  
         Task t = MockTestData.createTaskRecord(relCase.Id);
         System.assert(t.Id != null);
         Billable_Time__c bt = [Select Id, Minutes__c from Billable_Time__c where Task_ID__c = :t.Id];
         System.assertEquals(t.Billable_Minutes__c,bt.Minutes__c);
         bt.Minutes__c = 200;         
         update bt;
         try {                         
             delete bt;
         } catch(Exception e) {System.debug('Error :' + e);}
     } 
       
}