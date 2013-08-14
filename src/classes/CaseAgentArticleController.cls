/*********************************************************************************************************************
* Module Name   :  CaseAgentArticleController Class
* Description   :  This Class is Used for Creating Article from Case
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : TestAgentContributionArticleController
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      30/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
public class CaseAgentArticleController {
    // The constructor must take a ApexPages.KnowledgeArticleVersionStandardController as an argument
    public CaseAgentArticleController(ApexPages.KnowledgeArticleVersionStandardController ctl) {
        FAQ__kav article = (FAQ__kav)ctl.getRecord();   //this is the SObject for the new article. 
                                             //It can optionally be cast to the proper article type, e.g. FAQ__kav article = (FAQ__kav) ctl.getRecord();
        
        String sourceId = ctl.getSourceId(); //this returns the id of the case that was closed.
        Case c = [SELECT Subject, Description, Problem_Statement__c, Resolution_Summary__c FROM Case WHERE id=:sourceId];
                
        if(c.Problem_Statement__c == null)
            c.Problem_Statement__c = '';                 
        if(c.Resolution_Summary__c == null)
            c.Resolution_Summary__c = '';
            
        article.put('title',c.subject);  //this overrides the default behavior of pre-filling the title of the article with the subject of the closed case.     
        article.put('FAQ_Details__c','Problem Statement: '+c.Problem_Statement__c+'<br/>'+'Resolution Summary: '+c.Resolution_Summary__c);  
    }
}