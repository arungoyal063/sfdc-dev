global class ChatterCleanupService implements Database.Batchable<SObject>{ 

	global final String Query;
	global final String Entity;
	global final String Field;
	global final String Value;


	global Database.QueryLocator start(Database.BatchableContext BC){
		Datetime searchDate =  Datetime.now().addMinutes(-15);
		/*return Database.getQueryLocator([Select C.Change_Request__c, C.Id, C.IsDeleted__c from Change_Request_Follower__c C				
											where Change_Request__c in (	
												Select Id from Change_Request__c C
												where LastModifiedDate >=: searchDate)]);*/
		
		return Database.getQueryLocator([Select C.Change_Request__c, C.Id, C.IsDeleted__c from Change_Request_Follower__c C		
											where LastModifiedDate >=  :searchDate]);
	}

	global void execute(Database.batchableContext BC, List<Change_Request_Follower__c> scope){
		for(Change_Request_Follower__c cr : scope){ 
			System.debug('change value');
           cr.IsDeleted__c = true; 
       	} 
		try{
		delete scope;
		database.emptyRecycleBin(scope);
		}catch(Exception ex){
			System.debug('ERROR: ' + ex.GetMessage());	
		}
	}

	global void finish(Database.batchableContext BC){
		// Get the ID of the AsyncApexJob representing this batch job  
	  	// from Database.BatchableContext.    
	  	// Query the AsyncApexJob object to retrieve the current job's information.  

	 	AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, ExtendedStatus,
	   	TotalJobItems, CreatedBy.Email
	   	from AsyncApexJob where Id =:BC.getJobId()];

		// Send an email to the Apex job's submitter notifying of job completion.  
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Chatter Clean Up Service: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + ' With an extended status of: ' + a.ExtendedStatus);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}	
}