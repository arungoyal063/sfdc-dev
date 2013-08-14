trigger SetOpportunityOwnerAndBAS on Opportunity (before insert, before update) 
{    
    
    // create a set of all the unique opportunityIDs
    Set<id> AccountIds = new Set<id>();
    for (Opportunity o : Trigger.new)
        AccountIds.add(o.AccountId);   
 
    // query for all the OwnerID for the unique AccountIds in the records
    // create a map for a lookup / hash table for the owners
    Map<id, Account> reps = new Map<id, Account>([Select Id,OwnerId,BAS_Territory__c,SEM_Territory__c from Account Where Id in :AccountIds]);  
            
    // iterate over the list of records being processed in the trigger and
    // set the owner after being inserted
    for(Opportunity o: Trigger.new)
    {
        // o.RecordTypeId != '012Z00000004Ogi'
        if ((o.RecordTypeId == '012G0000000yBn3IAE' || o.RecordTypeId == '012G0000000yBn8IAE') && o.Is_Siebel_Opportunity__c != TRUE)
        {
                if (Trigger.IsInsert)
                {
                    // Set Opportunity Owner to the Account Owner
                    if (reps.get(o.AccountId).OwnerId != null)
                    {
                        o.OwnerId = reps.get(o.AccountId).OwnerId;
                        o.Owner_Info__c = reps.get(o.AccountId).OwnerId;
                    }
                    // If type is SEM-SGHE, the SEM rep on account should be the opportunity owner
                    if (o.Type == 'SEM-SGHE' && reps.get(o.AccountId).SEM_Territory__c != null)
                    {
                        o.OwnerId = reps.get(o.AccountId).SEM_Territory__c;
                        o.Owner_Info__c = o.OwnerId;
                        o.SEM_Territory__c = o.OwnerId;
                    }
                    if (reps.get(o.AccountId).BAS_Territory__c != null)
                    {
                        o.BAS_Territory__c = reps.get(o.AccountId).BAS_Territory__c; 
                    }
                    if (o.Amount == null)
                        o.Amount = 0;
                 }
                 else
                 {
                    if (o.OwnerId != null)
                    {
                        o.Owner_Info__c = o.OwnerId;
                    }
                    if (reps.get(o.AccountId).BAS_Territory__c != null && o.BAS_Territory__c == null )
                    {
                        o.BAS_Territory__c = reps.get(o.AccountId).BAS_Territory__c;
                    }
                 }
        }
        else
        {
         o.Owner_Info__c = o.OwnerId;
         }
                
      //System.Debug('Opportunity:'+o.Opportunity_number__c+' Owner:'+o.OwnerId) ;   
    }
    
}