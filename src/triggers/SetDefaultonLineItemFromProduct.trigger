trigger SetDefaultonLineItemFromProduct on OpportunityLineItem (before insert, before update) {
 Set<id> ProductIds = new Set<id>();
    for (OpportunityLineItem ol : Trigger.new)
    {
	    if(ol.Unit_Of_Measure__c == null || ol.Unit_Of_Measure__c =='' || ol.UOM__c == null || ol.UOM__c == '')
	    {
	        ProductIds.add(ol.PricebookEntryId);   
	    }
    }
    // query for all the Products for the unique ProductIds in the records
    // create a map for a lookup / hash table for the products

    Map<id, PricebookEntry> productMap = new Map<id, PricebookEntry>([Select Id,  Product2.Item_Type__c,  Product2.Unit_of_Measure__c from PricebookEntry Where Id in :ProductIds]);  
 
    // iterate over the list of records being processed in the trigger and set blank records
   
    for(OpportunityLineItem ol: Trigger.new)
    {
       //One Opportunity Products Unit_of_Measure__c is really Item Type.  Couldn't change b/c of Contract integration
       if(ol.Unit_of_Measure__c == null || ol.Unit_Of_Measure__c =='' )
        {
            ol.Unit_of_Measure__c = productMap.get(ol.PricebookEntryId).Product2.Item_Type__c ;                               
        }
       //Set the real Unit of Measure if it is blank
       if(ol.UOM__c == null || ol.UOM__c =='' )
        {
            ol.UOM__c = productMap.get(ol.PricebookEntryId).Product2.Unit_of_Measure__c ;                               
        }
                
      //System.Debug('Opportunity:'+o.Opportunity_number__c+' Owner:'+o.OwnerId) ;   
    }
}