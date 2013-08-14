trigger Case_MilestoneComplete_OnCaseComment on CaseComment (before insert, before update) {

boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    //JGP
    // Populate the Case's Milestone with a completion date if the milestone has not been populated with a completion time
    // If the CaseComment mets it's requirements
    
    Set<Id> validCaseIds = new Set<Id>();
    Map<Id,CaseMilestone> milestones = new Map<Id,CaseMilestone>();
    Map<String, CaseComment> caseCommentMap = new Map<String, CaseComment>();
    Set<String> commSet = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
    
    for (CaseComment cc: trigger.new)
    {
            if(cc.IsPublished || (''+ URL.getCurrentRequestUrl()).contains('clients')){
            //Add in comment criteria
            validCaseIds.add(cc.ParentId);
            caseCommentMap.put(cc.ParentId,cc);    
            }
    }
    system.debug(commSet.contains(UserInfo.getUserType())+'>>>>>>>>>>>>>'+caseCommentMap);
    if(!commSet.contains(UserInfo.getUserType()) || (''+ URL.getCurrentRequestUrl()).contains('clients')) { 
        if(!caseCommentMap.isEmpty()) {
                List<Case> caseList = [SELECT Id, Total_Billable_Minutes2__c, Status,isClosed, ClosedDate FROM Case WHERE Id IN :caseCommentMap.keySet()];
                for(Case c :caseList) {             
                    if((c.Total_Billable_Minutes2__c > 0) && (c.isClosed) && (c.ClosedDate != null)){                                                                 
                        if((dateTime.now().year() > c.ClosedDate.year()) || ((dateTime.now().year() == c.ClosedDate.year()) && (dateTime.now().month() > c.ClosedDate.month()))) {
                            caseCommentMap.get(c.Id).addError('Case was closed in a previous month with billable time and cannot be reopened.  Please submit a new case.');                            
                            //caseCommentMap.get(c.Id).addError('This case has been closed before current month, you cannot add additional comments.  Please submit a new case.');
                            validCaseIds.remove(c.Id);
                        }
                    } else if((c.Total_Billable_Minutes2__c == null || c.Total_Billable_Minutes2__c == 0) && (c.isClosed) && (c.ClosedDate != null)){  
                     	 if(c.ClosedDate.date().daysBetween(Date.Today()) > 30) {
                             caseCommentMap.get(c.Id).addError('This case has been closed greater than 30 days ago, you cannot add additional comments.  Please submit a new case.');
                             validCaseIds.remove(c.Id);
                     	 }
                    }         
               }            
       }
        
        
        List<CaseMilestone> toUpdate = new List<CaseMilestone>();
        milestones = new Map<Id,CaseMilestone>([SELECT
        CaseMilestone.Id,
        CaseMilestone.CaseId,
        CaseMilestone.CompletionDate
        FROM CaseMilestone
        WHERE CaseMilestone.CaseId IN: validCaseIds
        and Case.Completion_Date__c = null]);
        
        for(CaseMilestone cm:milestones.values())
        {
            if (cm.CompletionDate == null)
            {
                cm.CompletionDate = Datetime.now();
                toUpdate.add(cm);
            }
        }   
        if (!toUpdate.isEmpty()) { try {update(toUpdate);} catch(DMLException e) {Trigger.New[0].addError(e.getDMLMessage(0));} catch(Exception e) { Trigger.New[0].addError(e.getMessage());} } } 
    }
}