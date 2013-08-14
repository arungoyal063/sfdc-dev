/*********************************************************************************************************************
* Module Name   :  CaseModificationUtility Controller
* Description   :  This Controller is used to update Last Updated By and Last Updated fields on Case object
* Throws        :  <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  Test_CaseModificationUtility
* 
* Organization  :  Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
public with sharing class CaseModificationUtility {
    
    public static Boolean updateCaseModificationActivity(Set<String> caseIds, String lastUpdateBy, DateTime lastUpdated) {
        if(caseIds != null && (lastUpdateBy != null && lastUpdateBy.trim() != '') && (lastUpdated != null)){
            List<Case> caseList = [SELECT Id, Last_Updated__c, Last_Updated_By__c FROM Case WHERE Id IN :caseIdS];
            list<Case> toUpdate = new list<Case>(); 
            try {        
                for(Case c : caseList) {            
                    c.Last_Updated_By__c = lastUpdateBy;
                    c.Last_Updated__c = lastUpdated;
                    if(c.Last_Updated_By__c != lastUpdateBy && c.Last_Updated__c != lastUpdated){
                    	toUpdate.add(c);
                    }        
                }        
                update toUpdate;//caseList;  
                return true;              
            } catch(DMLException e) { throw e; }catch(Exception e) { throw e;}    
    	}return false;
    }
    
    public static Boolean modifyCaseFromCR(Set<String> caseIds, String lastUpdateBy, DateTime lastUpdated) {
       if(caseIds != null && (lastUpdateBy != null && lastUpdateBy.trim() != '') && (lastUpdated != null)){
            List<Case> caseList = [SELECT Id, Last_Updated__c, Last_Updated_By__c FROM Case WHERE Id IN :caseIdS];
            
            try {        
                for(Case c : caseList) {            
                    c.Last_Updated_By__c = lastUpdateBy;
                    c.Last_Updated__c = lastUpdated;
                    /*************************************************************************
                    	JGP 6/4/13 Removed the changing of the Case status on Change Requests
                    	Task# 1265
                    **************************************************************************/ 
                    /* 
                    c.Status = 'Change Request Open';
                    c.Sub_Status__c ='Defect';
                    */     
                }        
                update caseList;  
                return true;              
            } catch(DMLException e){throw e;}catch(Exception e) { throw e;}   
       } 
       return false;
    }
    
    
    /** Complete all Case Milestones on Case if Status of Case is Closed Close
    @param1 : Set of Ids of Closed Cases **/
    public static void completeCaseMilestones(Set<ID> caseIds) {
        List<CaseMilestone> toUpdate = new List<CaseMilestone>();
        //Get the Case Milestones for all Cases found
        Map<Id,CaseMilestone> milestones = new Map<Id,CaseMilestone>([SELECT
        CaseMilestone.Id,
        CaseMilestone.CaseId,
        CaseMilestone.CompletionDate
        FROM CaseMilestone
        WHERE CaseMilestone.CaseId IN: caseIds
        and Case.Completion_Date__c = null]);
        
        for(CaseMilestone cm:milestones.values())
        {
            if (cm.CompletionDate == null)
            {
                cm.CompletionDate = Datetime.now();
                toUpdate.add(cm);
            }
        }   
         if (!toUpdate.isEmpty()) { 
            try {
                update(toUpdate);
            } 
            // return the error back to calling class or trigger
            catch(DMLException e) { throw e; }catch(Exception e) { throw e;}
        }
    }
    
    /** return Case Comment for case priority change
    @param1 : parent Case Id **/
    public static CaseComment retPriorityComment(String caseId) {
         CaseComment cc = new CaseComment();
         cc.ParentId = caseId;
         cc.CommentBody = 'Case priority has changed';
         return cc;
     }
    
    
    /* Test Method for CaseModificationUtility Class */
    
}