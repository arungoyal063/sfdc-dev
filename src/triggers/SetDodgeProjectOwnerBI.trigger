// ==================================================================================
//   Object: SetDodgeProjectOwnerBI 
//  Company: ManningTon
//   Author: Mohan (Sales Optimizer)
// Comments: Sets the Dodge Project(Lead) ownership to Queue based on the Zipcode entered.
//			 To which Queue does the Dodge Project is belonged is identified by Dodge_Queue__c custom object.
// ==================================================================================
//  Changes: 2012-03-09 Initial version.
// ==================================================================================

trigger SetDodgeProjectOwnerBI on Dodge_Project__c (before insert) {
	Set<Id> dodgeProjectIds = new Set<Id>();
	Set<String> zipCodes = new Set<String>();
	for(Dodge_Project__c dp : Trigger.new) {
		if(dp.ZipCode__c != null && dp.ZipCode__c  != '') {
			zipCodes.add(dp.ZipCode__c );
		}
	}
	List<Dodge_Queue__c> dodgeQueues = [Select d.ZipCode__c, d.Queue_Name__c, d.Name From Dodge_Queue__c d Where d.ZipCode__c IN :zipCodes and d.ZipCode__c != null and d.Queue_Name__c != null];
	Set<String> queueNames = new Set<String>();
	Map<String, String> zipCodeQueueNameMap = new Map<String, String>();
	for(Dodge_Queue__c dq : dodgeQueues){
		queueNames.add(dq.Queue_Name__c);
		zipCodeQueueNameMap.put(dq.ZipCode__c, dq.Queue_Name__c);
	}
	System.debug('queueNames: ' + queueNames);
	List<QueueSobject> dodgeQueueList = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q Where q.Queue.Name IN :queueNames and q.SobjectType = 'Dodge_Project__c'];
	Map<String, String> queueIdMap = new Map<String, String>();
	for(QueueSobject qObj : dodgeQueueList) {
		queueIdMap.put(qObj.Queue.Name, qObj.QueueId);
	}
	for(Dodge_Project__c dp : Trigger.new) {
		if(dp.ZipCode__c != null && dp.ZipCode__c  != '') {
			if(zipCodeQueueNameMap.get(dp.ZipCode__c) != null) {
				String queName = zipCodeQueueNameMap.get(dp.ZipCode__c);
				if(queueIdMap.get(queName) != null) {
					dp.OwnerId = queueIdMap.get(queName);
				}
			}
		}
	}
}