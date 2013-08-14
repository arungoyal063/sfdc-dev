global class CasesSyncService implements Database.Batchable<SObject>{ 

	global final String Query;
	global final String Entity;
	global final String Field;
	global final String Value;

	global void execute(Database.batchableContext BC, List<EntitySubscription> scope){
		List<Case_Follower__c> recordsToUpdate = new List<Case_Follower__c>();
		for(EntitySubscription s : scope){
			//Get a listing of existing Change_Request_Follower__c so we don't duplicate them
			System.debug('***** subscription id: ' + s.Id);
			System.debug('***** subscription parent id: ' + s.ParentId);
			List<Case_Follower__c> existing = new List<Case_Follower__c>([SELECT CR.Id, CR.EntityId__c, CR.Follower__c FROM Case_Follower__c CR WHERE CR.EntityId__c =: s.Id]);
			Set<Id> currentSubscribers = new Set<Id>();
			for (Case_Follower__c cr:existing)
			{
				if (!currentSubscribers.contains(cr.Follower__c))
					currentSubscribers.add(cr.Follower__c);
					System.debug('***** follower found: ' + cr.Follower__c);
			}
			if (!currentSubscribers.contains(s.SubscriberId))
			{	
				System.debug('***** adding follower not found: ' + s.SubscriberId);
				Case_Follower__c follower = new Case_Follower__c();
				follower.Case__c = s.ParentId;
				follower.Follower__c = s.SubscriberId;
				follower.EntityId__c = s.Id;
				/*if(s.NetworkId != null){	
				}*/
				recordsToUpdate.add(follower);
			}
		}
 
		/*for(EntitySubscription s : scope){
			Case_Follower__c follower = new Case_Follower__c();
			follower.Case__c = s.ParentId;
			follower.Follower__c = s.SubscriberId;
			follower.EntityId__c = s.Id;
			
			recordsToUpdate.add(follower);
		}*/
		
		//insert recordsToUpdate;
		Database.SaveResult[] lsr = Database.insert(recordsToUpdate, false);
		for(Database.SaveResult sr:lsr){
			if(!sr.isSuccess()){
				Database.Error err = sr.getErrors()[0];
			   	System.debug('***** insert Error: ' + err.getMessage());
		   }else{
			   System.debug('***** insert Success: ' + sr.getId());
		   }
		}
	}

	global void finish(Database.batchableContext BC){
		// Get the ID of the AsyncApexJob representing this batch job  
	  	// from Database.BatchableContext.    
	  	// Query the AsyncApexJob object to retrieve the current job's information.  

	 	AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  ExtendedStatus,
	   	TotalJobItems, CreatedBy.Email
	   	from AsyncApexJob where Id =:BC.getJobId()];

		// Send an email to the Apex job's submitter notifying of job completion.  
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email, 'bmatthews@rainmaker-llc.com'};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Case Sync Service: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + ' With an extended status of: ' + a.ExtendedStatus);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
	}
	 
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('***** searchDate: ' + Datetime.now());
		Datetime searchDate =  Datetime.now().addMinutes(-30);
		System.debug('***** searchDate: ' + searchDate);
		/*return Database.getQueryLocator([Select E.CreatedById, E.CreatedBy.Name, E.CreatedDate, E.Id,   E.ParentId, E.SubscriberId, E.Subscriber.Name from EntitySubscription E 
										where ParentId in (
													Select Id from Case C
													where LastModifiedDate >=: searchDate)]);*/
		
		return Database.getQueryLocator([Select E.CreatedById, E.CreatedBy.Name, E.CreatedDate, E.Id, E.ParentId, E.SubscriberId, E.Subscriber.Name from EntitySubscription E 
										where CreatedDate >: searchDate]);
	}
	
	
}