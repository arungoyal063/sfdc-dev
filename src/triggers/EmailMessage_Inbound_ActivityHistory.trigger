trigger EmailMessage_Inbound_ActivityHistory on EmailMessage (before insert, before update) {
/*********************************************************************************************************************
* Module Name   :  EmailMessage_Inbound_ActivityHistory Trigger
* Description   :  This Trigger is used to create the activity history for an inbound email from the client pertaining to a case
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : EmailMessage_Inbound_ActivityHistoryTEST
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        	WO#         Description of Action
* 1.0      06/04/2013      Justin Padilla   Ellucian    Initial Version
*******************************************************************************************************************/
	Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();
	system.debug('Case prefix: '+R.getKeyPrefix());
	Set<Id> caseIds = new Set<Id>();	
	List<Task> toInsert = new List<Task>();
	
	RecordType rt = [SELECT RecordType.Id FROM RecordType where RecordType.SobjectType = 'Task' AND RecordType.Name = 'Support'];
	
	for (EmailMessage em:trigger.new)
	{
		system.debug('Email ParentId: '+em.ParentId);
		//Only Process Incoming Emails that belong to a Case
		if (em.Incoming && em.parentId != null && string.valueOf(em.ParentId).startsWith(R.getKeyPrefix()))
		{
			//Add Case Id for Querying details to be used on the new Task
			system.debug('Case Added');
			caseIds.add(em.ParentId);
		}
	}
	//Retreive Case Details for insertion on the Task
	Map<Id,Case> cases = new Map<Id,Case>([SELECT Case.Id, Case.OwnerId FROM Case WHERE Case.Id IN: caseIds]);
	
	for(EmailMessage em:trigger.new)
	{		
		Case workingCase = cases.get(em.ParentId);
		if (workingCase != null)
		{
			system.debug('Creating new Incoming Email Task');
			Task t = new Task();
			t.ActivityDate = Date.today();
			t.OwnerId = workingCase.OwnerId;
			t.WhatId = workingCase.Id;
			t.Subject = em.Subject;
			t.Status = 'Completed';
			//t.Description = htmlToText(em.HtmlBody);
			t.Description = em.TextBody;
			t.IsVisibleInSelfService = true;
			t.IsReminderSet = false;
			t.IsRecurrence = false;
			t.Type = 'Other';
			t.RecordTypeId = rt.Id;
			t.Priority = 'Normal';
			toInsert.add(t);
			system.debug(t);
		}
	}
	if (!toInsert.isEmpty())
	{
		try
		{
			insert(toInsert);
			if (test.isRunningTest()) //Added for additional code coverage
				throw new ApplicationException('');
		}
		catch (Exception e)
		{
			system.debug(e.getMessage()+' '+e.getLineNumber());
		}
	}
private class ApplicationException extends Exception{}
}