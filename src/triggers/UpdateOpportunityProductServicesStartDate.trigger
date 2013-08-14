trigger UpdateOpportunityProductServicesStartDate on Opportunity (after update) {

    Opportunity old_opp;
    Date startdate;
    Date enddate;
    
    Set<id > oppIds = new Set<id>();
    
    Map<Id, Opportunity> Opps =  new Map<Id, Opportunity>();
    
    for (Opportunity o : Trigger.new)
    {
        old_opp = Trigger.oldMap.get(o.Id);
        if (o.CloseDate <> old_opp.CloseDate || o.Services_Planned_Start_Date__c <> old_opp.Services_Planned_Start_Date__c || o.Services_Planned_End_Date__c <> old_opp.Services_Planned_End_Date__c || o.MS_Projected_Start_Date__c <> old_opp.MS_Projected_Start_Date__c)       
            {
            oppIds.add(o.Id);
            Opps.put(o.Id, o);
            }
    }
    

    //Map<id, Opportunity> m = new Map<id, Opportunity>([select id,closedate,Services_Planned_Start_Date__c,Services_Planned_End_Date__c from Opportunity where id in :oppIds]);
    
    List<OpportunityLineItem> opportunityProducts = new List<OpportunityLineItem>();
    opportunityProducts = [select Id,Services_Planned_Start_Date__c,Services_Planned_End_Date__c,  MS_Projected_Start_Date__c,  opportunityId, PricebookEntry.Product2.Type__c from OpportunityLineItem where OpportunityId in :oppIds and PricebookEntry.Product2.Type__c like '%Services%'];

    for (OpportunityLineItem ol : opportunityProducts)
    {
        if (ol.PricebookEntry.Product2.Type__c =='Professional Services')
        {
            if (Opps.get(ol.opportunityId).Services_Planned_Start_Date__c == null)
            {
                startdate = Opps.get(ol.opportunityId).CloseDate + 45;
            }    
            else
            {
               startdate =Opps.get(ol.opportunityId).Services_Planned_Start_Date__c;
            }   
            
            if (Opps.get(ol.opportunityId).Services_Planned_End_Date__c == null)
            {
                enddate = startdate.addYears(1);
            }
            else
            {
                enddate = Opps.get(ol.opportunityId).Services_Planned_End_Date__c ;
            }
            
            ol.Services_Planned_Start_Date__c = startdate;
            ol.Services_Planned_End_Date__c = enddate ;
        }
        if (ol.PricebookEntry.Product2.Type__c =='Managed Services')
        {
            if (Opps.get(ol.opportunityId).MS_Projected_Start_Date__c != null)
            {
                ol.MS_Projected_Start_Date__c = Opps.get(ol.opportunityId).MS_Projected_Start_Date__c;
            }    
        }
    }
    
    update opportunityProducts;
}