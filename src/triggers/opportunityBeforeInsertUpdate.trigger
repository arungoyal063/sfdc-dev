// ==================================================================================
//   Object: opportunityBeforeInsertUpdate 
//  Company: Mannington
//   Author: John Westenhaver (Sales Optimizer)
// Comments: Looks up Sales Office for Opportunity Owner. 
// ==================================================================================
//  Changes: 2011-11-08 Initial version.
// ==================================================================================

trigger opportunityBeforeInsertUpdate on Opportunity (before insert, before update)
{
	// Get a list of owner IDs.
	set<Id> userIds = new set<Id>();
	for (Opportunity o : system.trigger.new)
	{
		userIds.add(o.OwnerId);
	}

	// Map owners to user records.
	map<Id, User> userMap = new map<Id, User>( 
		[SELECT Id, Name, Sales_Office__c FROM User WHERE Id IN :userIds]);
		
	// Set the Sales Office on these records automatically.
	for (Opportunity o : system.trigger.new)
	{
		// May be null.
		o.Sales_Office__c = userMap.get(o.OwnerId).Sales_Office__c;
	}
}