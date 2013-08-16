trigger CreateOutreachTasks on Account bulk (after insert,after update) {
	
	Set<String> accntIds = new Set<String>();
	Set<String> cleanupIds = new Set<String>();
	
	List<Agreements__c> agreements;
	List<AccountTeamMember> teamMembers;
	
	Integer index = 0;
	for(Account accnt: Trigger.New){
		if(trigger.old != null){
			
			System.debug('*** old value: ' + trigger.old[index].Company_Tier__c);
			System.debug('*** new value: ' + accnt.Company_Tier__c);
			
			if(trigger.old[index].Company_Tier__c != accnt.Company_Tier__c){
				cleanupIds.add(accnt.Id);
			}
			
		}
		
		System.debug('*** accnt.Account_Status__c: ' + accnt.Account_Status__c);
		//RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND Name = 'Renewal' LIMIT 1];
		if((accnt.Account_Status__c == 'biNOW Former Customer') || (accnt.Account_Status__c == 'OAN Former Customer')){
			if(!cleanupIds.contains(accnt.Id)){
				cleanupIds.add(accnt.Id);
			}
		}
		
		if((trigger.old == null) || (trigger.old[index].Company_Tier__c != accnt.Company_Tier__c)){
			accntIds.add(accnt.Id);
		}
		
		index =+ 1;
	}
	
	//delete any open tasks if there are any
	System.debug('*** cleanup count: ' + cleanupIds.size());
	if(cleanupIds.size() > 0){
		Task[] tasksToDelete = [Select T.AccountId, T.Status, T.Subject from Task T WHERE T.Status != 'Completed' AND T.Subject = 'Outreach' AND T.AccountId IN: cleanupIds];
		/*List<Task> toDelete = new List<Task>();  // code by Justin
		for (Task t: tasksToDelete)
		{
		if (T.Subject.contains('Outreach'))
			toDelete.add(t);
		}
		if (!toDelete.isEmpty())
			delete(toDelete);*/
		delete tasksToDelete;
	}
	
	//retrieve the account team members and subscriptions
	if(accntIds.size() > 0){
		
		teamMembers = [Select Id, AccountId, UserId from AccountTeamMember where AccountId IN: accntIds];
		
		agreements = [Select A.Name, A.Account_Name__c, A.Id, A.Subscription_Start_Date__c from Agreements__c A WHERE Subscription_Start_Date__c <= today AND Account_Name__c IN: accntIds ORDER BY Account_Name__c, Subscription_Start_Date__c DESC];
	}
	
	//create the new tasks
	index = 0;
	List<Task> newTasks = new List<Task>();
	for(Account accnt: Trigger.New){
	
		//if((trigger.old == null) || (trigger.old[index].Company_Tier__c != accnt.Company_Tier__c)){
		if((trigger.old == null && accnt.Company_Tier__c != null && accnt.Company_Tier__c != '') || (trigger.old != null && trigger.old[index].Company_Tier__c != accnt.Company_Tier__c)){
			
			System.debug('*** process account');
			Task newTask = new Task();
			newTask.Subject = 'Outreach';
			newTask.WhatId = accnt.Id;
			
			Date dueDate = Date.today();
			
			if(accnt.Company_Tier__c == '1'){
				newTask.ActivityDate = dueDate.addMonths(1);
				for(Agreements__c agreement: agreements){
					if(agreement.Account_Name__c == accnt.Id){
						dueDate = agreement.Subscription_Start_Date__c;
						newTask.ActivityDate = dueDate.addMonths(1);
						break;
					}
				}
				
				for(AccountTeamMember member: teamMembers){
					if(member.AccountId == accnt.Id){
						newTask.OwnerId = member.UserId;
						break;
					}
				}

			}
			
			if(accnt.Company_Tier__c == '2'){
				newTask.ActivityDate = dueDate.addMonths(3);
				for(Agreements__c agreement: agreements){
					if(agreement.Account_Name__c == accnt.Id){
						dueDate = agreement.Subscription_Start_Date__c;
						newTask.ActivityDate = dueDate.addMonths(3);
						break;
					}
				}
				
				for(AccountTeamMember member: teamMembers){
					if(member.AccountId == accnt.Id){
						newTask.OwnerId = member.UserId;
						break;
					}
				}
			}
			
			if(accnt.Company_Tier__c == '3'){
				newTask.ActivityDate = dueDate.addMonths(6);
				for(Agreements__c agreement: agreements){
					if(agreement.Account_Name__c == accnt.Id){
						dueDate = agreement.Subscription_Start_Date__c;
						newTask.ActivityDate = dueDate.addMonths(6);
						break;
					}
				}
				
				for(AccountTeamMember member: teamMembers){
					if(member.AccountId == accnt.Id){
						newTask.OwnerId = member.UserId;
						break;
					}
				}
			}
			
			newTasks.add(newTask);
		
		}
		
		index =+ 1;
	}
	
	if(newTasks.size() > 0){
		insert newTasks;	
	}
}