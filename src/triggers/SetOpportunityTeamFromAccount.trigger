trigger SetOpportunityTeamFromAccount on Opportunity (before insert, before update) {
  // create a set of all the unique opportunityIDs
    Set<id> AccountIds = new Set<id>();
    for (Opportunity o : Trigger.new)
        AccountIds.add(o.AccountId);   
 
    // query for all the OwnerID for the unique AccountIds in the records
    // create a map for a lookup / hash table for the owners
    Map<id, Account> reps = new Map<id, Account>([Select Id,OwnerId,BAS_Territory__c,SEM_Territory__c, Epicor_GM__c, ISR_Territory__c, Sales_Rep__c, Account_Executive__c, Advance_Solutions_Account_Executive__c, Customer_Relationship_Manager__c, VP_Customer_Relationship_Management__c, Customer_Relationship_GM__c,  Inside_Account_Executive__c, MS_Account_Executive__c, VP_Services__c, Cloud_Account_Executive__c,  TM_Account_Executive__c , MS_VP__c from Account Where Id in :AccountIds]);  
    Map<Id, RecordType> rMap = new Map<Id, RecordType>([Select Id, DeveloperName from RecordType]);        
    // iterate over the list of records being processed in the trigger and
    // set the owner after being inserted
    for(Opportunity o: Trigger.new)
    {
        // o.RecordTypeId != '012Z00000004Ogi'
       // if ((o.RecordTypeId == '012G0000000yBn3IAE' || o.RecordTypeId == '012G0000000yBn8IAE') && o.Is_Siebel_Opportunity__c != TRUE)
       if (rMap.get(o.RecordTypeId).DeveloperName != 'Partner_Portal_Datatel' )
        {
               
                if (o.OwnerId != null)
                        o.Owner_Info__c = o.OwnerId;
                if (o.Amount == null)
                        o.Amount = 0;
                //Set HD Business Advisor from Account              
                if (reps.get(o.AccountId).BAS_Territory__c != null)
                {
                    o.BAS_Territory__c = reps.get(o.AccountId).BAS_Territory__c; 
                }
                 //Set HD GM from Account              
                if (reps.get(o.AccountId).Epicor_GM__c != null)
                {
                    o.HD_GM__c = reps.get(o.AccountId).Epicor_GM__c; 
                }      
                 //Set HD Inside Account Executive from Account              
                if (reps.get(o.AccountId).ISR_Territory__c != null)
                {
                    o.ISR_Territory__c = reps.get(o.AccountId).ISR_Territory__c; 
                }                              
                //Set HD Sales Rep from Account              
                if (reps.get(o.AccountId).Sales_Rep__c != null)
                {
                    o.HD_Sales_Rep__c = reps.get(o.AccountId).Sales_Rep__c; 
                }                          
                //Set HD SEM Account Executive from Account              
                if (reps.get(o.AccountId).SEM_Territory__c != null)
                {
                    o.SEM_Territory__c = reps.get(o.AccountId).SEM_Territory__c; 
                }                           
                //Set HSGHE Account Executive from Account              
                if (reps.get(o.AccountId).Account_Executive__c != null)
                {
                    o.HSGHE_Account_Executive__c = reps.get(o.AccountId).Account_Executive__c; 
                }    
                //Set HSGHE Adv Solutions Account Executive from Account              
                if (reps.get(o.AccountId).Advance_Solutions_Account_Executive__c != null)
                {
                    o.Advance_Solutions_Account_Executive__c = reps.get(o.AccountId).Advance_Solutions_Account_Executive__c; 
                }       
                //Set HSGHE CRM from Account              
                if (reps.get(o.AccountId).Customer_Relationship_Manager__c != null)
                {
                    o.HSGHE_CRM__c = reps.get(o.AccountId).Customer_Relationship_Manager__c; 
                }     
                //Set HSGHE Customer Rel VP from Account              
                if (reps.get(o.AccountId).VP_Customer_Relationship_Management__c != null)
                {
                    o.HSGHE_Customer_Rel_VP__c = reps.get(o.AccountId).VP_Customer_Relationship_Management__c; 
                } 
                //Set HSGHE Customer Rel GM from Account              
                if (reps.get(o.AccountId).Customer_Relationship_GM__c != null)
                {
                    o.HSGHE_Customer_Rel_GM__c = reps.get(o.AccountId).Customer_Relationship_GM__c; 
                }               
                 //Set HSGHE Inside Account Executive from Account              
                if (reps.get(o.AccountId).Inside_Account_Executive__c != null)
                {
                    o.HSGHE_Inside_Account_Executive__c = reps.get(o.AccountId).Inside_Account_Executive__c; 
                }                 
                 //Set HSGHE Managed Services Account Executive from Account              
                if (reps.get(o.AccountId).MS_Account_Executive__c != null)
                {
                    o.HSGHE_Managed_Services_Account_Executive__c = reps.get(o.AccountId).MS_Account_Executive__c; 
                }              
                //Set HSGHE Services VP from Account              
                if (reps.get(o.AccountId).VP_Services__c != null)
                {
                    o.HSGHE_Services_VP__c = reps.get(o.AccountId).VP_Services__c; 
                }   
                //Set Cloud_Account_Executive__cP from Account              
                if (reps.get(o.AccountId).Cloud_Account_Executive__c != null)
                {
                    o.Cloud_Account_Executive__c = reps.get(o.AccountId).Cloud_Account_Executive__c; 
                }   
               //Set TM_Account_Executive__c              
                if (reps.get(o.AccountId).TM_Account_Executive__c != null)
                {
                    o.TM_Account_Executive__c = reps.get(o.AccountId).TM_Account_Executive__c; 
                }   
                //Set MS_VP__c              
                if (reps.get(o.AccountId).MS_VP__c != null)
                {
                    o.MS_VP__c = reps.get(o.AccountId).MS_VP__c; 
                }   
               
                                             
         }
                
      //System.Debug('Opportunity:'+o.Opportunity_number__c+' Owner:'+o.OwnerId) ;   
    }
}