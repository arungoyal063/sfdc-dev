/*********************************************************************************************************************
* Module Name   :  TestCaseAgentArticleController Test Class 
* Description   :  Test Class for CaseAgentArticleController Class
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
private class Test_CaseAgentArticleController {

    static testMethod void Test_CaseAgentUnitTest() { 
        Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3',null,null); 
        String caseSubject = 'my test';
        String caseDesc = 'my test description';
        c.subject= caseSubject;
        c.description = caseDesc;       
        update c; 
     
        String caseId = c.id;       
        ApexPages.currentPage().getParameters().put('sourceId', caseId);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new FAQ__kav());
        new CaseAgentArticleController(ctl);
        System.assertEquals(caseId, ctl.getSourceId());
        System.assertEquals(caseSubject, ctl.getRecord().get('title'));
    }
}