/*********************************************************************************************************************
* Module Name   :  Test_CaseComment_CaseModification Test Class 
* Description   :  Test Class for UpdateCaseModification_OnCaseComment trigger on CaseComment
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

@isTest 
private class Test_CaseComment_CaseModification {
     static testMethod void Test_UpdateCaseModification_OnRelatedCase_UnitTest() { 
         Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');  // Case record         
         CaseComment cc = MockTestData.createCaseCommentRecord(c.Id,'Test');        // CaseComment record
         try {
             update cc; 
             delete cc;
         } catch(Exception e) {
             System.debug('Error :' + e);
         }
     }     
}