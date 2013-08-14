global class ChatterSyncService implements Database.Batchable<SObject>{ 

	global final String Query;
	global final String Entity;
	global final String Field;
	global final String Value;
	global final static  String log;

	global void execute(Database.batchableContext BC, List<EntitySubscription> scope){
		List<Change_Request_Follower__c> CRFrecordsToInsert = new List<Change_Request_Follower__c>();
		List<Case_Follower__c> CFrecordsToInsert = new List<Case_Follower__c>();
		
		/* JGP 7/18/2013 Modification */
		
		Schema.DescribeSObjectResult defineCase = Case.SObjectType.getDescribe();
		Schema.DescribeSObjectResult defineChangeRequest = Change_Request__c.SObjectType.getDescribe();
		system.debug('Case Prefix: '+defineCase.getKeyPrefix());
		system.debug('ChangeRequest Prefix: '+defineChangeRequest.getKeyPrefix());
		Set<Id> CRsubscriptionIds = new Set<Id>(); //for Change Requests
		Set<Id> CsubscriptionIds = new Set<Id>(); //for Cases
		for (EntitySubscription s : scope)
		{
			if (string.valueOf(s.Id).startsWith(defineChangeRequest.getKeyPrefix()) && !CRsubscriptionIds.contains(s.Id)) //Change Request
				CRsubscriptionIds.add(s.Id);
			else if (string.valueOf(s.Id).startsWith(defineCase.getKeyPrefix()) && !CsubscriptionIds.contains(s.Id)) //Case
				CsubscriptionIds.add(s.Id);
		}
		system.debug('Working on CR subscriptions: '+CRsubscriptionIds);
		system.debug('Working on Case subscriptions: '+CsubscriptionIds);
		
		//Query for all existing CR followers at once instead of in the For loop
		Map<Id,List<Change_Request_Follower__c>> CRexisting = new Map<Id,List<Change_Request_Follower__c>>(); //Keyed off of EntitySubscriptionId
		for (Change_Request_Follower__c temp : [SELECT CR.Id, CR.EntityId__c, CR.Follower__c FROM Change_Request_Follower__c CR WHERE CR.EntityId__c IN: CRsubscriptionIds])
		{
			if (!CRexisting.containsKey(temp.EntityId__c)) //Entity Id does not exist in the Map, Initialize
			{
				List<Change_Request_Follower__c> crfs = new List<Change_Request_Follower__c>();
				crfs.add(temp);
				CRexisting.put(temp.EntityId__c,crfs);
			}
			else //EntityId exists, add this follower to it's listing within the Map
			{
				List<Change_Request_Follower__c> crfs = CRexisting.get(temp.EntityId__c);
				crfs.add(temp);
				CRexisting.remove(temp.EntityId__c); //remove and readd with the updated listing
				CRexisting.put(temp.EntityId__c,crfs);
			}
		}
		
		//Query for all existing Case followers at once instead of in the For loop
		Map<Id,List<Case_Follower__c>> Cexisting = new Map<Id,List<Case_Follower__c>>(); //Keyed off of EntitySubscriptionId
		for (Case_Follower__c temp : [SELECT C.Id, C.EntityId__c, C.Follower__c FROM Case_Follower__c C WHERE C.EntityId__c IN: CsubscriptionIds])
		{
			if (!Cexisting.containsKey(temp.EntityId__c)) //Entity Id does not exist in the Map, Initialize
			{
				List<Case_Follower__c> cfs = new List<Case_Follower__c>();
				cfs.add(temp);
				Cexisting.put(temp.EntityId__c,cfs);
			}
			else //EntityId exists, add this follower to it's listing within the Map
			{
				List<Case_Follower__c> cfs = Cexisting.get(temp.EntityId__c);
				cfs.add(temp);
				Cexisting.remove(temp.EntityId__c); //remove and readd with the updated listing
				Cexisting.put(temp.EntityId__c,cfs);
			}
		}		
		
		//Now that all existing Change Request and Case Followers are populated, see if we need to create a new one
		for (EntitySubscription s : scope)
		{
			system.debug('Working on EntitySubscription: '+s.Id);
			//Get the existing listing of current subscribers
			Set<Id> currentCRSubscribers = new Set<Id>();
			Set<Id> currentCSubscribers = new Set<Id>();
			
			
			if (string.valueOf(s.ParentId).startsWith(defineChangeRequest.getKeyPrefix())) //Working on Change Request
			{
				if (CRexisting.get(s.Id) != null)
				{
					for (Change_Request_Follower__c currentCRF : CRexisting.get(s.Id))
					{		
						if (!currentCRSubscribers.contains(currentCRF.Follower__c))
							currentCRSubscribers.add(currentCRF.Follower__c);
					}
				}
				if (!currentCRSubscribers.contains(s.SubscriberId)) //Record does not already exist, create it
				{
					System.debug('Creating New Change Request Follower Record for: ' + s.SubscriberId);
					Change_Request_Follower__c follower = new Change_Request_Follower__c();
					follower.Change_Request__c = s.ParentId;
					follower.Follower__c = s.SubscriberId;
					follower.EntityId__c = s.Id;
					if(s.NetworkId != null){	
					}
					CRFrecordsToInsert.add(follower);
				}
			}
			
			if (string.valueOf(s.ParentId).startsWith(defineCase.getKeyPrefix())) //Working on Case
			{
				if (Cexisting.get(s.Id) != null)
				{
					for (Case_Follower__c currentCF : Cexisting.get(s.Id))
					{		
						if (!currentCSubscribers.contains(currentCF.Follower__c))
							currentCSubscribers.add(currentCF.Follower__c);
					}
				}
				if (!currentCSubscribers.contains(s.SubscriberId)) //Record does not already exist, create it
				{
					System.debug('Creating New Case Follower Record for: ' + s.SubscriberId);
					Case_Follower__c follower = new Case_Follower__c();
					follower.Case__c = s.ParentId;
					follower.Follower__c = s.SubscriberId;
					follower.EntityId__c = s.Id;
					if(s.NetworkId != null){	
					}
					CFrecordsToInsert.add(follower);
				}
			}
		}
		
		/* JGP 7/12/2013 Modification END */
		
		
		/*
		for(EntitySubscription s : scope){
			//Get a listing of existing Change_Request_Follower__c so we don't duplicate them
			System.debug('***** subscription id: ' + s.Id);
			System.debug('***** subscription parent id: ' + s.ParentId);
			List<Change_Request_Follower__c> existing = new List<Change_Request_Follower__c>([SELECT CR.Id, CR.EntityId__c, CR.Follower__c FROM Change_Request_Follower__c CR WHERE CR.EntityId__c =: s.Id]);
			Set<Id> currentSubscribers = new Set<Id>();
			for (Change_Request_Follower__c cr:existing)
			{
				if (!currentSubscribers.contains(cr.Follower__c))
					currentSubscribers.add(cr.Follower__c);
					System.debug('***** follower found: ' + cr.Follower__c);
			}
			if (!currentSubscribers.contains(s.SubscriberId))
			{	
				System.debug('***** adding follower not found: ' + s.SubscriberId);
				Change_Request_Follower__c follower = new Change_Request_Follower__c();
				follower.Change_Request__c = s.ParentId;
				follower.Follower__c = s.SubscriberId;
				follower.EntityId__c = s.Id;
				if(s.NetworkId != null){	
				}
				recordsToUpdate.add(follower);
			}
		}
		*/
		//insert recordsToUpdate;
		if (!CRFrecordsToInsert.isEmpty())
		{
			Database.SaveResult[] lsr = Database.insert(CRFrecordsToInsert, false);
			for(Database.SaveResult sr:lsr){
				if(!sr.isSuccess()){
					Database.Error err = sr.getErrors()[0];
				   	System.debug('***** CR Follower insert Error: ' + err.getMessage());
			   }else{
				   System.debug('***** CR Follower insert Success: ' + sr.getId());
			   }
			}
		}
		if (!CFrecordsToInsert.isEmpty())
		{
			Database.SaveResult[] lsr = Database.insert(CFrecordsToInsert, false);
			for(Database.SaveResult sr:lsr){
				if(!sr.isSuccess()){
					Database.Error err = sr.getErrors()[0];
				   	System.debug('***** Case Follower insert Error: ' + err.getMessage());
			   }else{
				   System.debug('***** Case Follower insert Success: ' + sr.getId());
			   }
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
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Chatter Sync Service: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + ' With an extended status of: ' + a.ExtendedStatus);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		//SM Added Code to run CRUniqueAccountBatch
		/*CRUniqueAccountBatch  BatchRun =  new  CRUniqueAccountBatch ();
		ID batchprocessid  =  Database.executeBatch(BatchRun ); */
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('***** searchDate: ' + Datetime.now());
		Datetime searchDate =  Datetime.now().addMinutes(-15);
		System.debug('***** searchDate: ' + searchDate);
		return Database.getQueryLocator([Select E.CreatedById, E.CreatedBy.Name, E.CreatedDate, E.Id, E.NetworkId, E.Network.Name, E.ParentId, E.SubscriberId, E.Subscriber.Name from EntitySubscription E 
										where CreatedDate >: searchDate]);
		
	}	
}