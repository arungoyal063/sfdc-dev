/**
*********************************************************************************************************************
* Module Name   :  CRUniqueAccountBatch
* Description   :     
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :  
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      06/6/2013      Milligan         362         Initial Version
*    
*******************************************************************************************************************
**/
global class CRUniqueAccountBatch  implements Database.Batchable<sObject>, Database.Stateful{   
    
    global String query = ''; 
    
    
    global  Database.Querylocator start(Database.BatchableContext bc) 
    {
         
        //Total_Unique_Accounts_Following__c,  Account_Name__c 
        System.debug('***** searchDate: ' + Datetime.now());
		Datetime searchDate =  Datetime.now().addMinutes(-60);
		System.debug('***** searchDate: ' + searchDate);
        query = 'SELECT id, Name, LastModifiedDate, Change_Request__c, Follower__c,follower_account__c FROM '+
        'Change_Request_Follower__c where CreatedDate >' + searchDate;
        
        System.debug('CRUniqueAccountBatch--> Change_Request_Follower__c Query --->' + query);
        return Database.getQueryLocator([SELECT id, Name, LastModifiedDate, Change_Request__c, 
        								Follower__c,follower_account__c FROM 
       								Change_Request_Follower__c where CreatedDate > :searchDate]); 
       
    }    
    
   global void execute(Database.BatchableContext BC, List<Change_Request_Follower__c> crf)
   {
    
        Set<String> crIds = new  Set<String>();
        Set<String> userIds = new  Set<String>();
        Map<id, User> acctMap = new Map<id, User>();
        
        
        Map<id, Change_Request__c> crMap;
        List<Change_Request__c> crList = new List<Change_Request__c>();
        
        
        Map<id, Set<String>> crAcctMap = new Map<id, Set<String>>();
        
        //List<Change_Request__c> updCR = new List<Change_Request__c>();
        
        List<Change_Request_Follower__c> allCRF = new List<Change_Request_Follower__c>();
        
        for(Change_Request_Follower__c c: crf)
        {
            crIds.add(c.Change_Request__c);
            userIds.add(c.Follower__c);
        }
        
        // get all CRs that will be updated
        ///maynot need a map
        crMap = new Map<id, Change_Request__c>([SELECT id,Total_Unique_Accounts_Following__c FROM  Change_Request__c WHERE id IN: crIds]);
        crList = [SELECT id,Total_Unique_Accounts_Following__c FROM  Change_Request__c WHERE id IN: crIds];
        
        
        // get all entire CRFs object instances to loop through to find accts
        allCRF = [SELECT id, Change_Request__c, Follower__c, follower_account__c  FROM Change_Request_Follower__c WHERE Change_Request__c IN: crIds];
        
        
        for(Change_Request__c cr: crList ){
            
            Set<String> crAccts = new Set<String>();
            
            // loop thur the CRFs to find all for that CR
            for(Change_Request_Follower__c crfol: allCRF )
            {
                if(cr.id == crfol.change_request__c)
                {
                    // find the user account for that CRF
                    //a SET will not hold duplicate
                    if(crfol.follower_account__c <> null)
                    {
                        crAccts.add(crfol.follower_account__c);
                        System.debug('CRUniqueAccountBatch--> Adding Account to Set ---> ' + cr.id + ' Account--> ' + crfol.follower_account__c);
                        
                    }
                }
            }
            
            if(!crAccts.IsEmpty())
            {
                crAcctMap.put(cr.id, crAccts);
                System.debug('CRUniqueAccountBatch--> Putting CR and Set into Map ---> ' + cr.id + ' Size--> ' + crAccts.size());
                
            }
        }
        
        //If there ar CRs to Update
        if(!crList.IsEmpty())
        {
            for(Change_Request__c cr: crList){
                //updCR
                if(crAcctMap.containsKey(cr.Id))
                {
                    Set<String> accts = crAcctMap.get(cr.Id);
                    Integer acctCount = accts.size();
                    cr.Total_Unique_Accounts_Following__c = acctCount;
                    System.debug('CRUniqueAccountBatch--> UPDATING CR  --> '  + cr.id + ' Total--> ' +  cr.Total_Unique_Accounts_Following__c  );
                }
                
            }
            System.debug('CRUniqueAccountBatch--> UPDATING CRLIST --> '  +  crList.size());
            update(crList);
            
        }
    
   }    
   global void finish(Database.BatchableContext BC)
   {
        // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.  

        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];
 
    
   }  
    
}