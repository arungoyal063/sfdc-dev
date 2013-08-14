trigger Case_MilestoneComplete_OnEmail on EmailMessage (before insert, before update) {

boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
	
	if (ignoreTriggers==false)
	{
	    //#Requirement 1
	    //JGP
	    // Populate the Case's Milestone with a completion date if the milestone has not been populated with a completion time
	    // If the Emailmessage mets it's requirements
	    
	    //#Requirement 2 - Create a task for the Case Owner to review the Inbound Email, When Case has been closed for more than 30 days
	    
	    Set<Id> relatedObject = new Set<Id>();
	    Map<Id,Task> isTask = new Map<Id,Task>();
	    Map<Id,Case> isCase = new Map<Id,Case>();
	    Set<String> commSet = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
	    Map<Id,CaseMilestone> milestones = new Map<Id,CaseMilestone>();
	    Map<String, EmailMessage> caseMailMessageMap = new Map<String, EmailMessage>();
	    
	    // Req#2
	    Set<ID> caseIds = new Set<ID>();
	    
	    for (EmailMessage em :trigger.new)
	    {
	        if (!em.Incoming)
	        {
	            caseMailMessageMap.put(em.ParentId, em);
	            if (em.ActivityId != null)
	            {
	                relatedObject.add(em.ActivityId); //The Activity relates to a Task
	            }
	            
	        } //Outgoing message that's related to an activity only
	        
	        // #Req -2 Inbound Mail -block1 
	        if(em.Incoming && em.ParentId != null) {
	            caseIds.add(em.ParentId);
	        }
	        // #Req -2 Inbound Mail  -block1  
	    }
	    
	    
	   // Req#2- block2
	   List<Task> reviewTaskList = new List<Task>();
	   if(!caseIds.isEmpty()) {
	       List<Case> mailCaseList = [SELECT Id, OwnerId, CaseNumber, Total_Billable_Minutes2__c, IsClosed, ClosedDate FROM Case WHERE Id IN :caseIds]; 
	       for(Case mc : mailCaseList) {
	           if(mc.IsClosed && 
	               (mc.Total_Billable_Minutes2__c == null || mc.Total_Billable_Minutes2__c < 1) &&
	                (mc.ClosedDate.date().daysBetween(Date.today())> 30)) {
	                Task t = new Task();
	                t.Subject = 'Review Case ' + mc.CaseNumber;
	                t.Status = 'In Progress';
	                t.Priority = 'Normal';
	                t.WhatId = mc.Id;
	                t.Description = 'Test';
	                t.OwnerId = mc.OwnerId;
	                t.ActivityDate = Date.today();
	                reviewTaskList.add(t);
	           }
	       }
	   }   
	   
	   if(!reviewTaskList.isEmpty()) {
	       try {
	           insert reviewTaskList;  
	       }  catch(Exception e) {Trigger.new[0].addError(e);}
	   }
	   // Req#2- block2
	    //Populate isTask to determine if the relatedObject is associated with a task
	    isTask = new Map<Id,Task>([SELECT
	    Task.Id,
	    Task.WhatId
	    FROM Task
	    WHERE Task.Id IN :relatedObject]);
	    
	    //Now that we have a Map of Tasks, determine if that task is related to a case
	    relatedObject = new Set<Id>();
	    for (Task t:isTask.values())
	    {
	        if (t.WhatId != null && !relatedObject.contains(t.WhatId))
	            relatedObject.add(t.WhatId);
	    }
	    
	    //Populate isCase to determine if the relatedObject associated with this email is a Case
	    isCase = new Map<Id,Case>([SELECT
	    Case.Id,
	    Total_Billable_Minutes2__c, 
	    isClosed, 
	    ClosedDate 
	    FROM Case WHERE Case.Id IN: relatedObject]);
	    
	    for(Case c :isCase.values()) {
	         if((c.Total_Billable_Minutes2__c > 0) && (c.isClosed) && (c.ClosedDate != null)) {                                                                 
	            if((dateTime.now().year() > c.ClosedDate.year()) || ((dateTime.now().year() == c.ClosedDate.year()) && (dateTime.now().month() > c.ClosedDate.month()))) {
	                caseMailMessageMap.get(c.Id).addError('This case has been closed before this month, you cannot Send an Email. Please submit a new case.');
	                isCase.remove(c.Id);
	            }
	        } else if((c.Total_Billable_Minutes2__c == null || c.Total_Billable_Minutes2__c == 0) && (c.isClosed) && (c.ClosedDate != null)){  
	            if(c.ClosedDate.date().daysBetween(Date.Today()) > 30) {
	                 caseMailMessageMap.get(c.Id).addError('This case has been closed greater than 30 days ago, you cannot Send an Email. Please submit a new case.');
	                 isCase.remove(c.Id);
	            }
	        }            
	    }
	    
	    
	    // only internal user can update case milestone
	    if(!commSet.contains(UserInfo.getUserType())) { 
	        List<CaseMilestone> toUpdate = new List<CaseMilestone>();
	        //Get the Case Milestones for all Cases found
	        milestones = new Map<Id,CaseMilestone>([SELECT
	        CaseMilestone.Id,
	        CaseMilestone.CaseId,
	        CaseMilestone.CompletionDate
	        FROM CaseMilestone
	        WHERE CaseMilestone.CaseId IN: isCase.keySet()
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
	            } catch(DMLException e) {
	                Trigger.new[0].addError(e.getDMLMessage(0));    
	            } catch(Exception e) {
	                Trigger.new[0].addError(e.getMessage());
	            }
	        }
	        
	        List<Case> caseList = [SELECT Id, Completion_Date__c FROM Case WHERE Id IN: isCase.keySet()];
	        List<Case> toUpdateCaseList = new List<Case>();
	        for(Case caseObj:caseList)
	        {
                caseObj.Completion_Date__c = system.now();
                toUpdateCaseList.add(caseObj);
	        }	        
	        if (!toUpdateCaseList.isEmpty()) { 
	            try {
	                update(toUpdateCaseList);
	            } catch(DMLException e) {
	                Trigger.new[0].addError(e.getDMLMessage(0));    
	            } catch(Exception e) {
	                Trigger.new[0].addError(e.getMessage());
	            }
	        }
	    }
	}
}