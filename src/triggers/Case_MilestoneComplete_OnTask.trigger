trigger Case_MilestoneComplete_OnTask on Task (before insert, before update) {
    boolean ignoreTriggers =false;
    
    if(!Test.isRunningTest())
        ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;

    if (ignoreTriggers==false)
    {
        //JGP
        // Populate the Case's Milestone with a completion date if the milestone has not been populated with a completion time
        // If the Task is associated with a Case
        // And it meets the Task's requirements
        // Change task attribute Visible in Self Service true when an Email activiy is created - AW Change
        Boolean isTaskRecordTypeSupport = true;
        list<Task> objTasks = new list<Task>();
        
        if(Trigger.isDelete){
            objTasks = Trigger.old;
        }
        
        if(Trigger.isInsert || Trigger.isUpdate){
            objTasks = Trigger.New;     
        }
        
        map<Id,RecordType> objRecordtType = new map<Id,RecordType>([SELECT SobjectType, Name FROM RecordType WHERE SobjectType ='Task']);
            
        for(Task tsk : objTasks) {
            if(tsk.RecordTypeId == null|| objRecordtType.get(tsk.RecordTypeId).Name != 'Support'){
                isTaskRecordTypeSupport = false;
            }
        }
        
        if(Trigger.isInsert && isTaskRecordTypeSupport) {
            for(Task t:Trigger.new) {
                if(t.Subject != null && t.Subject.startsWith('Email:')) {
                    t.IsVisibleInSelfService = true;
                }
            }
        }
        
        Map<String, Task> caseTaskMap = new Map<String, Task>();
        Set<Id> relatedObject = new Set<Id>();
        Map<Id,Case> isCase = new Map<Id,Case>();
        
        Map<Id,CaseMilestone> milestones = new Map<Id,CaseMilestone>();
        Set<String> commSet = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
        //Determine if the related Task Object is for a Case
        for (Task t:Trigger.new)
        {
            caseTaskMap.put(t.WhatId, t);
            if ((t.WhatId != null && !relatedObject.contains(t.WhatId)) && (t.Status == 'Completed')) // Run for all Task Types
            {
                if(t.IsVisibleInSelfService)
                relatedObject.add(t.WhatId);
            }
    }
    
    // validation for Closed Case - Start
    if(!caseTaskMap.isEmpty() && isTaskRecordTypeSupport) {
            List<Case> caseList = [SELECT Id,Total_Billable_Minutes2__c, Status,isClosed, ClosedDate FROM Case WHERE Id IN :caseTaskMap.keySet()];
            for(Case c :caseList) {              
                if((c.Total_Billable_Minutes2__c > 0) && (c.isClosed) && (c.ClosedDate != null)){                                                                 
                    if((dateTime.now().year() > c.ClosedDate.year()) || ((dateTime.now().year() == c.ClosedDate.year()) && (dateTime.now().month() > c.ClosedDate.month()))) {
                        caseTaskMap.get(c.Id).addError('This case has been closed before current month, you cannot Log a new Call or Modify a Call. Please submit a new case.');
                        relatedObject.remove(c.Id);
                    }
                } else if((c.Total_Billable_Minutes2__c == null || c.Total_Billable_Minutes2__c == 0) && (c.isClosed) && (c.ClosedDate != null)){  
                    if(c.ClosedDate.date().daysBetween(Date.Today()) > 30) {
                         caseTaskMap.get(c.Id).addError('This case has been closed greater than 30 days ago, you cannot Log a new Call or Modify a Call.  Please submit a new case.');
                         relatedObject.remove(c.Id);
                    }
                }         
            }            
     }
     // validation for Closed Case - end
    
    // only internal user can update case milestone
    if(!commSet.contains(UserInfo.getUserType()) && isTaskRecordTypeSupport) { 
        //Populate isCase to determine if the relatedObject associated with this task is a Case
        isCase = new Map<Id,Case>([SELECT
        Case.Id
        FROM Case WHERE Case.Id IN: relatedObject]);
        
       
        List<CaseMilestone> toUpdate = new List<CaseMilestone>();
        //Get the Case Milestones for all Cases found
        milestones = new Map<Id,CaseMilestone>([SELECT
        CaseMilestone.Id,
        CaseMilestone.CaseId,
        CaseMilestone.CompletionDate,
        CaseMilestone.IsViolated,
        CaseMilestone.IsCompleted
        FROM CaseMilestone
        WHERE CaseMilestone.CaseId IN: isCase.keySet()
        and Case.Completion_Date__c = null
        ]);
        
        
        for(CaseMilestone cm:milestones.values())
        {
            if (cm.CompletionDate == null && (!cm.IsCompleted))
            {
                cm.CompletionDate = Datetime.now();
                toUpdate.add(cm);
            }
        }   
        if (!toUpdate.isEmpty()) {
            try { 
                update(toUpdate);
            } catch(DMLException e) {
                Trigger.New[0].addError(e.getDMLMessage(0));    
            } 
            catch(Exception e) {
                Trigger.New[0].addError(e.getMessage());      
            }
        }
    }
}
}