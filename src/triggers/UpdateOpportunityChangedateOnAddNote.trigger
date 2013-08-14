trigger UpdateOpportunityChangedateOnAddNote on Note (before insert, before update) {
	
	Set<id> oppIds = new Set<id>();
	String nid;
	
	//Map<id, User> changeusers = new Map<id, User>();
	
	for (Note n : Trigger.new)
	{
		nid = n.ParentId;
		If (nid.startswith('006'))
		{ 
			oppIds.add(n.ParentId);
			//changeusers.put(n.ParentId,n.LastModifiedBy);
		}
	}
	
	List<Opportunity> opportunities = new List<Opportunity>();
	opportunities = [select Id,Summary__c from Opportunity where Id in :oppIds];
	
	for (Opportunity o : opportunities)
	{
		//o.LastModifiedBy = changeusers.get(o.Id);
		o.Summary__c = o.Summary__c;
	}
	
	update opportunities;
}