trigger UpdateParentActionPlan on Opportunity (after insert, after update) {

    if (UserInfo.GetLastName() <> 'Sync')
    {
        Set<Id> APIds = new Set<Id>();
        List<Opportunity> APOpps = new List<Opportunity>();
        Object amount, amount_s, amount_v, amount_m;
        
        for (Opportunity o : Trigger.new)
        {
            If (o.Parent_Action_Plan__c != null)
                APIds.add(o.Parent_Action_Plan__c);
        }
        
        APOpps = [select Id,Amount,AP_Software_Amount__c,AP_Services_Amount__c,AP_Maintenance_Amount__c from Opportunity where Id in :APIds];
        
        Map<String, AggregateResult> ApAmount = new Map<String, AggregateResult>([Select Parent_Action_Plan__c Id,SUM(Amount) Amount,
                    SUM(Software_Amount__c) SoftwareAmount, SUM(Services_Amount__c) ServicesAmount, SUM(Maintenance_Amount__c) MaintenanceAmount
                    From Opportunity o
                    where o.Parent_Action_Plan__c in :APIds
                    group by Parent_Action_Plan__c ]);
        
        // System.debug('=== all keys in the map: ' + ApAmount.keySet()); 
        // System.debug('=== all values in the map (as a List): ' + ApAmount.values());
        
        for (Opportunity a: APOpps)
        {
            amount = ApAmount.get(a.Id).get('Amount');
            amount_s = ApAmount.get(a.Id).get('SoftwareAmount');
            amount_v = ApAmount.get(a.Id).get('ServicesAmount');
            amount_m = ApAmount.get(a.Id).get('MaintenanceAmount');
            
            if (amount == null) 
                a.Amount = 0;
            else
                a.Amount = Double.valueOf(amount);
                
            if (amount_s == null) 
                a.AP_Software_Amount__c = 0;
            else
                a.AP_Software_Amount__c = Double.valueOf(amount_s);
                
            if (amount_v == null) 
                a.AP_Services_Amount__c = 0;
            else
                a.AP_Services_Amount__c = Double.valueOf(amount_v);
            
            if (amount_m == null) 
                amount_m = 0;
            else
                a.AP_Maintenance_Amount__c = Double.valueOf(amount_m);
        }
        
        If (!APOpps.IsEmpty())
            update APOpps;
    }
}