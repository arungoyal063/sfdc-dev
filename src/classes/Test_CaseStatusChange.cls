/*********************************************************************************************************************
* Module Name   :  Test_CaseStatusChange Test Class 
* Description   :  Test Class for CaseStatusChange trigger on case Object
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      17/07/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest/*(seeAllData = true)*/
private class Test_CaseStatusChange {
	
	static testMethod void myUnitTest() { 
         Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created
         EntitySubscription entitySub = new EntitySubscription();
         entitySub.ParentId = orgCase.Id;         
         entitySub.SubscriberId = UserInfo.getUserId();
         try {          	
         	insert entitySub;
         	orgCase.Status = 'Client Action Required';
			update orgCase;                  
         } catch(Exception e) {System.debug('Error :' + e);}
     }
}