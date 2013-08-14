/*********************************************************************************************************************
* Module Name   :  Test_Case_MilestoneComplete_OnEmail Test Class 
* Description   :  Test Class for Case_MilestoneComplete_OnEmail trigger on EmailMessage
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
private class Test_Case_MilestoneComplete_OnEmail  {

    static testMethod void emialMessageUnitTest() {
       try {
           Case c = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');   // Case Created       
           List<Entitlement> entlList = [Select Licensed_Product__r.Product_New__c,status,Licensed_Product__c, Id From Entitlement where status='Active' LIMIT 1];
            if(!entlList.isEmpty()) {
                c.EntitlementId = entlList.get(0).Id;            
                update c;
                EmailMessage newEmail = MockTestData.createEmailMessageRecord(c.Id);
            }
       } catch(Exception e) {
         System.debug(e);
       }
    }
    
}