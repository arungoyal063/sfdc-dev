trigger UpdateOpportunityProductServicesDatesOnInsert on OpportunityLineItem (before insert) {

    Set<id> opportunities = new Set<id>();
        
    for (OpportunityLineItem o : Trigger.new)
    {
        opportunities.add(o.OpportunityId); 
    }
    
    Map<id,Opportunity> m = new Map<id,Opportunity>([select Id,Services_Planned_Start_Date__c,Services_Planned_End_Date__c from Opportunity where Id in :opportunities]);
    
    for (OpportunityLineItem o : Trigger.new)
    {
        o.Services_Planned_Start_Date__c = m.get(o.opportunityId).Services_Planned_Start_Date__c;
        o.Services_Planned_End_Date__c = m.get(o.opportunityId).Services_Planned_End_Date__c;
    }

}