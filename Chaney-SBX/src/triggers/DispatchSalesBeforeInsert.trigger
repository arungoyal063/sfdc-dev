trigger DispatchSalesBeforeInsert on Dispatch_Sale__c (before insert) {

	//MapRecordsForDispatchBatch.process(Trigger.new);
	InsertDispatchDetails.process(Trigger.new);
}