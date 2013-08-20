// ==================================================================================
//   Object: SetDodgeProjectOwner 
//  Company: ManningTon
//   Author: Mohan (Sales Optimizer)
// Comments: Sets the Dodge Project(Lead) ownership to Queue based on the Zipcode entered.
//			 To which Queue does the Dodge Project is belonged is identified by Dodge_Queue__c custom object.
// ==================================================================================
//  Changes: 2011-12-19 Initial version.
// ==================================================================================

trigger SetDodgeProjectOwner on Dodge_Contact__c (before insert, before update) {
	
	Set<Id> dodgeProjectIds = new Set<Id>();
	Set<String> zipCodes = new Set<String>();
	Map<String, Dodge_Contact__c> dodgeContactMap = new Map<String, Dodge_Contact__c>();
	Integer i = 0;
	for(Dodge_Contact__c dc : Trigger.new) {
		if(dc.Role__c == 'Architect' && dc.Zip_Code5__c != null && dc.Zip_Code5__c != '') {
			//dodgeProjectIds.add(dc.Dodge_Project__c);
			if(trigger.isUpdate) {
				if(trigger.old.get(i).Role__c != dc.Role__c) {
					dodgeContactMap.put(dc.Zip_Code5__c, dc);
					zipCodes.add(dc.Zip_Code5__c);
				}
				if(trigger.old.get(i).Zip_Code5__c != dc.Zip_Code5__c) {
					dodgeContactMap.put(dc.Zip_Code5__c, dc);
					zipCodes.add(dc.Zip_Code5__c);
				}
			} else if(trigger.isInsert) {
				dodgeContactMap.put(dc.Zip_Code5__c, dc);
				zipCodes.add(dc.Zip_Code5__c);
			}
		}
		i++;
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
	Map<Id, String> dodgeProjectQueueMap = new Map<Id, String>();
	
	for(String dodgeZip : dodgeContactMap.keyset()) {
		String dodgeProjectId = dodgeContactMap.get(dodgeZip).Dodge_Project__c;
		String zipCode = dodgeContactMap.get(dodgeZip).Zip_Code5__c;
		if(zipCodeQueueNameMap.get(zipCode) != null) {
			String queName = zipCodeQueueNameMap.get(zipCode);
			if(queueIdMap.get(queName) != null) {
				dodgeProjectQueueMap.put(dodgeProjectId, queueIdMap.get(queName));
				//dodgeProjectIds.add(dodgeProjectId);
			}
		}
	}
	
	List<Dodge_Project__c> dodgeProjectList = [Select Id, OwnerId From Dodge_Project__c Where Id IN :dodgeProjectQueueMap.keyset()];
	List<Dodge_Project__c> dodgeList = new List<Dodge_Project__c>();
	for(Dodge_Project__c dp : dodgeProjectList) {
		if(dodgeProjectQueueMap.get(dp.Id) != null) {
			String qId = dodgeProjectQueueMap.get(dp.Id);
			dp.OwnerId = qId;
			dodgeList.add(dp);
		}
	}
	
	upsert dodgeList;
}