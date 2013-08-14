/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<ChangeRequest_Trigger>> 
// Version................: <<1.0>>
// Created by.............: <<agoyal@rainmaker-llc.com>>
// Created Date...........: <<06-08-2013>>
// Last Modified Date.....: <<06-08-2013>>
// Description/Requirement: 
//---------------------------------------------------------------------------------------------------------------------------*/
trigger ChangeRequest_Trigger on Change_Request__c (after insert, after update) {
	Map<Id, Id> CaseVsCrMap = new Map<Id, Id>();	
	List<Change_Request_Follower__c> CRFrecordsToInsert = new List<Change_Request_Follower__c>();
	for(Change_Request__C crObj :trigger.new){
		if(crObj.Originating_Case__c != null){
			if(Trigger.isInsert){
				CaseVsCrMap.put(crObj.Originating_Case__c, crObj.Id);
			}
			else if(Trigger.isUpdate){
				Change_Request__C oldCRObj = trigger.oldMap.get(crObj.Id);
				if(oldCRObj.Originating_Case__c != crObj.Originating_Case__c){
					CaseVsCrMap.put(crObj.Originating_Case__c, crObj.Id);
				}
			}
		}		
	}
	//Issue #194 enhancment
	if(!CaseVsCrMap.isEmpty()){
	//	list<Change_Request__C> cr =[Select Id, (Select Id, Case__c From Associated_Records__r) From Change_Request__c];
		list<Associated_Case_Change_Request__c> objAssociated_Case_Change_Request = new list<Associated_Case_Change_Request__c>();
		
		for(Change_Request__C cr:trigger.new){
			Associated_Case_Change_Request__c accr = new Associated_Case_Change_Request__c();
			accr.case__c = cr.Originating_Case__c;
			accr.change_request__c = cr.Id;
			accr.Relationship__c = 'Direct';
			objAssociated_Case_Change_Request.add(accr);
		}		
		
		if(!objAssociated_Case_Change_Request.isEmpty()){
			insert objAssociated_Case_Change_Request;}
	}
	
	
	system.debug('<<<<<<<<<<<CaseVsCrMap<<<<<<<>'+ CaseVsCrMap);
	
	List<Id> contactIdList = new List<Id>();
	List<Case> caseList = [SELECT Id, ContactId FROM Case WHERE Id IN: CaseVsCrMap.keySet()];
	for(Case caseObj: caseList){
		contactIdList.add(caseObj.ContactId);		
	}
	system.debug('<<<<<<<<<<<contactIdList<<<<<<<>'+ contactIdList);
	system.debug('<<<<<<<<<<<caseList<<<<<<<>'+ caseList);
	
	Map<Id, Id> contactVsUserMap = new Map<Id, ID>();
	List<User> UserList = [SELECT Id, ContactId FROM User WHERE ContactId IN: contactIdList AND IsActive = true];	
	for(User userObj:UserList){		
		contactVsUserMap.put(userObj.ContactId, userObj.Id);
	}
	system.debug('<<<<<<<<<<<contactVsUserMap<<<<<<<>'+ contactVsUserMap);
	
	/*List<EntitySubscription> entitySubscriptionList = [SELECT ParentId, SubscriberId FROM EntitySubscription WHERE SubscriberId IN: contactVsUserMap.values()];
	Map<Id, Id> subscriberVsparentIdMap = new Map<Id, Id>();
	for(EntitySubscription entitySubObj: entitySubscriptionList){
		subscriberVsparentIdMap.put(entitySubObj.SubscriberId, entitySubObj.ParentId);	
	}*/
	
	Set<Id> caseIdList = new Set<Id>();
	if(!contactVsUserMap.isEmpty()){
		for(Case caseObj: caseList){
			if(caseObj.ContactId != null && contactVsUserMap.get(caseObj.ContactId) != null){				
				system.debug('<<<<<<<<<<<contactVsUserMap.get(caseObj.ContactId)'+ contactVsUserMap.get(caseObj.ContactId));
				Change_Request_Follower__c follower = new Change_Request_Follower__c();
				follower.Change_Request__c = CaseVsCrMap.get(caseObj.Id);
				follower.Follower__c = contactVsUserMap.get(caseObj.ContactId);			
				CRFrecordsToInsert.add(follower);			
			}
			caseIdList.add(caseObj.Id);
		}									
		/*//if(subscriberVsparentIdMap.get(contactVsUserMap.get(caseObj.ContactId)) != CaseVsCrMap.get(caseObj.Id)){
			EntitySubscription es = new EntitySubscription();
			es.NetworkId = Network.getNetworkId();
		    es.ParentId = CaseVsCrMap.get(caseObj.Id);
		    es.SubscriberId = contactVsUserMap.get(caseObj.ContactId);		   
		//}*/	
	
		//Query for all existing Case followers at once instead of in the For loop
		Map<Id,List<Case_Follower__c>> Cexisting = new Map<Id,List<Case_Follower__c>>(); //Keyed off of EntitySubscriptionId
		for (Case_Follower__c temp : [SELECT C.Id, C.Follower__c, C.Case__c FROM Case_Follower__c C WHERE C.Case__c IN: caseIdList])
		{
			if (!Cexisting.containsKey(temp.Case__c)) //Entity Id does not exist in the Map, Initialize
			{
				List<Case_Follower__c> cfs = new List<Case_Follower__c>();
				cfs.add(temp);
				Cexisting.put(temp.Case__c,cfs);
			}
			else //EntityId exists, add this follower to it's listing within the Map
			{
				List<Case_Follower__c> cfs = Cexisting.get(temp.Case__c);
				cfs.add(temp);
				Cexisting.remove(temp.Case__c); //remove and readd with the updated listing
				Cexisting.put(temp.Case__c,cfs);
			}
		}
		
		for(Case caseObj: caseList){
			if (Cexisting.get(caseObj.Id) != null){
				for (Case_Follower__c currentCRF : Cexisting.get(caseObj.Id)){
					Change_Request_Follower__c follower = new Change_Request_Follower__c();
					follower.Change_Request__c = CaseVsCrMap.get(caseObj.Id);
					follower.Follower__c = currentCRF.Follower__c;		
					CRFrecordsToInsert.add(follower);		
				}
			}
		}
	}		
	
		
	//insert recordsToUpdate;
	if (!CRFrecordsToInsert.isEmpty())
	{
		Database.SaveResult[] lsr = Database.insert(CRFrecordsToInsert, false);
		for(Database.SaveResult sr:lsr){
			if(!sr.isSuccess()){
				Database.Error err = sr.getErrors()[0];
			   	System.debug('***** CR Follower insert Error: ' + err.getMessage());
		   }else{
			   System.debug('***** CR Follower insert Success: ' + sr.getId());
		   }
		}
	}	
}