/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<CRSyncService>> 
// Version................: <<1.0>>
// Created by.............: <<agoyal@rainmaker-llc.com>>
// Created Date...........: <<05-08-2013>>
// Last Modified Date.....: <<05-08-2013>>
// Description/Requirement: 
//---------------------------------------------------------------------------------------------------------------------------*/
global with sharing class CRSyncService implements Database.Batchable<SObject>{

	global void execute(Database.batchableContext BC, List<EntitySubscription> scope){
		
		Schema.DescribeSObjectResult defineChangeRequest = Change_Request__c.SObjectType.getDescribe();
		Set<Id> CRsubscriptionIds = new Set<Id>(); //for Change Requests
		for (EntitySubscription s : scope)
		{
			if (string.valueOf(s.ParentId).startsWith(defineChangeRequest.getKeyPrefix()) && !CRsubscriptionIds.contains(s.Id)) //Change Request
				CRsubscriptionIds.add(s.Id);			
		}
		
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
		
		List<Change_Request_Follower__c> recordsToUpdate = new List<Change_Request_Follower__c>();
		for(EntitySubscription s : scope){
			//Get a listing of existing Change_Request_Follower__c so we don't duplicate them
			System.debug('***** subscription id: ' + s.Id);
			System.debug('***** subscription parent id: ' + s.ParentId);
			//List<Change_Request_Follower__c> existing = new List<Change_Request_Follower__c>([SELECT CR.Id, CR.EntityId__c, CR.Follower__c FROM Change_Request_Follower__c CR WHERE CR.EntityId__c =: s.Id]);
			List<Change_Request_Follower__c> existing = CRexisting.get(s.Id);
			System.debug('*****  ExistingList' + existing);
			Set<Id> currentSubscribers = new Set<Id>();
			if(existing != null){
				for (Change_Request_Follower__c cr:existing)
				{
					if (!currentSubscribers.contains(cr.Follower__c))
						currentSubscribers.add(cr.Follower__c);
						System.debug('***** follower found: ' + cr.Follower__c);
				}
			}
			
			if (!currentSubscribers.contains(s.SubscriberId))
			{	
				System.debug('***** adding follower not found: ' + s.SubscriberId);
				Change_Request_Follower__c follower = new Change_Request_Follower__c();
				follower.Change_Request__c = s.ParentId;
				follower.Follower__c = s.SubscriberId;
				follower.EntityId__c = s.Id;
				/*if(s.NetworkId != null){	
				}*/
				recordsToUpdate.add(follower);
			}
		}
		
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
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('CR Sync Service: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + ' With an extended status of: ' + a.ExtendedStatus);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
	}
	 
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('***** searchDate: ' + Datetime.now());
		Datetime searchDate =  Datetime.now().addMinutes(-15);
		System.debug('***** searchDate: ' + searchDate);
			
		return Database.getQueryLocator([Select E.CreatedById, E.CreatedBy.Name, E.CreatedDate, E.Id, E.ParentId, E.SubscriberId, E.Subscriber.Name from EntitySubscription E 
										where CreatedDate >: searchDate]);
	}
	
    @IsTest
    private  static void testCRSyncService() {
		
		Test.StartTest();        
        //Change Request
        Change_Request__c cr1 = MockTestData.createCRRecord('Test');        
        
        //EntitySubscription
        EntitySubscription es = new EntitySubscription();
        es.ParentId = cr1.Id;
        es.SubscriberId = UserInfo.getUserId();
        insert es;
        
        Change_Request_Follower__c follower = new Change_Request_Follower__c();
   		follower.Change_Request__c = es.ParentId;
	   	follower.Follower__c = es.SubscriberId;
	   	follower.EntityId__c = es.Id;
	   	insert follower;
		
		CRSyncService batchRun = new CRSyncService();
        ID batchprocessid = Database.executeBatch(batchRun);
        Test.stopTest();		
	}
}