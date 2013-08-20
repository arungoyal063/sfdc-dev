// ==================================================================================
//   Object: accountBeforeInsertUpdate 
//  Company: Mannington
//   Author: John Westenhaver (Sales Optimizer)
// Comments: Looks up Sales Office for Account Owner. 
// ==================================================================================
//  Changes: 2011-11-08 Initial version.
// ==================================================================================

trigger accountBeforeInsertUpdate on Account (before insert, before update)
{
	// Get a list of owner IDs.
	set<Id> userIds = new set<Id>();
	for (Account a : system.trigger.new)
	{
		userIds.add(a.OwnerId);
	}

	// Map owners to user records.
	map<Id, User> userMap = new map<Id, User>( 
		[SELECT Id, Name, Sales_Office__c FROM User WHERE Id IN :userIds]);
		
	// Set the Sales Office on these records automatically.
	for (Account a : system.trigger.new)
	{
		// May be null.
		a.Sales_Office__c = userMap.get(a.OwnerId).Sales_Office__c;
	}
}