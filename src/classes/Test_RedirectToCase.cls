/*********************************************************************************************************************
* Module Name   :  Test_RedirectToCase Test Class 
* Description   :  Test Class for RedirectToCase
* Throws        :  <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest 
private class Test_RedirectToCase {
     //Test for Internal User
     static testMethod void RedirectToCase_UnitTest() { 
         Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created 
         ApexPages.currentPage().getParameters().put('Id',orgCase.Id);
         ApexPages.StandardController controller = new ApexPages.StandardController(orgCase);
         RedirectToCase rc = new RedirectToCase(controller); 
         rc.pageRedirect();
     }
     //Test for community User
     static testMethod void RedirectToCase_UnitTest1() { 
         Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created 
         pageReference pr = new pageReference('/clients/caseproductselection?retURL=/500/o');
         Test.setCurrentPage(pr); 
         ApexPages.StandardController controller = new ApexPages.StandardController(orgCase);
         RedirectToCase rc = new RedirectToCase(controller); 
         rc.pageRedirect();
     }
     //Test for Negative User
     static testMethod void RedirectToCase_UnitTest2() { 
         Case orgCase = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test', 'Test');  // Originating Case Created 
         ApexPages.StandardController controller = new ApexPages.StandardController(orgCase);
         RedirectToCase rc = new RedirectToCase(controller); 
         rc.pageRedirect();
     }
}