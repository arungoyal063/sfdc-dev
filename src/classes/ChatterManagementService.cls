public class ChatterManagementService{
	
	//method to remove change request followers
	public static void RemoveUsers(List<Change_Request_Follower__c> users) {
		
		set<Id> theIds = new set<id>();
		for (Change_Request_Follower__c user :users){
			if(!theIds.contains(user.EntityId__c)){
			  	theIds.add(user.EntityId__c);
			}
	   	}
		
		if(theIds.size() > 0){
			List<EntitySubscription> recordToDelete = [Select Id from EntitySubscription 
															where Id in : theIds]; 
			
			if(recordToDelete.size() > 0){
				Database.DeleteResult[] lsr = Database.delete(recordToDelete);
			}
		}
		
	}
	
	//method to remove case followers
	public static void RemoveUsers(List<Case_Follower__c> users) {
		
		set<Id> theIds = new set<id>();
		for (Case_Follower__c user :users){
			if(!theIds.contains(user.EntityId__c)){
			  	theIds.add(user.EntityId__c);
			}
	   	}
		
		EntitySubscription[] recordToDelete = [Select Id from EntitySubscription 
												where Id in : theIds]; 
		
		Integer i = 0;
		Database.DeleteResult[] lsr = Database.delete(recordToDelete);
		
	}
	
	//method to process change request followers
	public static void AddUsers(List<Change_Request_Follower__c> users) {
		
		set<Id> theIds = new set<id>();
	   	for (Change_Request_Follower__c user :users){
			if(user.EntityId__c == null){
				if(!theIds.contains(user.Follower__c)){
				  	theIds.add(user.Follower__c);
					System.debug('***** Adding to map: ' + user.Follower__c);
				}
			}
	   	}
		
		if(theIds.size() > 0){
			
			System.debug('***** IDs found, starting process');
		
			Map<ID, NetworkMember> theUsers = new Map<ID, NetworkMember>();
			List<NetworkMember> networkMembers = [Select N.Network.Name, N.Network.Status, N.Id, N.MemberId, N.Member.ProfileId from NetworkMember N where N.MemberId in : theIds];
			for (NetworkMember member: networkMembers) {
			    theUsers.put(member.MemberId, member);
			}
			
			System.debug('***** User Map: ' + theUsers);
			
			//process the users
			List<EntitySubscription> subscriptions = new List<EntitySubscription>();
			for (Change_Request_Follower__c user :users){
				
				System.debug('***** Selected User: ' + user);
				System.debug('***** Selected CF Id: ' + user.id);
				System.debug('***** Selected CR Id: ' + user.Change_Request__c);
				
				//crete a new entity subscription
				EntitySubscription follow = new EntitySubscription();
	            follow.parentId = user.Change_Request__c;
				follow.subscriberid = user.Follower__c;
				
				if(theUsers.containsKey(user.Follower__c)){
					if(theUsers.get(user.Follower__c).NetworkId != null){
						System.debug('***** Selected CR Id: ' + theUsers.get(user.Follower__c).NetworkId);
						follow.NetworkId = theUsers.get(user.Follower__c).NetworkId;
					}
				}
				System.debug('***** Add Follower: ' + follow);
				subscriptions.add(follow);
			}
			
			if(subscriptions.size() > 0){
				try{
					//insert subscriptions;
					System.debug('***** Saving new subscriptions');
					
					Integer i = 0;	
					Database.SaveResult[] lsr = Database.insert(subscriptions, false);
					for(Database.SaveResult sr:lsr){
						if(!sr.isSuccess()){
							Database.Error err = sr.getErrors()[0];
						   	System.debug('***** insert Error: ' + err.getMessage());
						   	users.get(i).addError(err.getMessage());
					   }else{
						   System.debug('***** Entity Id: ' + sr.getId());
						   System.debug('***** Entity Id: ' + subscriptions.get(i).Id);
						   users.get(i).EntityId__c = subscriptions.get(i).Id;
					   }
					   i += 1;
					}
				}catch(DmlException ex){
					System.debug('***** insert proces error: ' + ex.getMessage());
				}
			}		
		}else{
			System.debug('***** No IDs found, by passing process');	
		}
	}
	
	//method to process case followers
	public static void AddUsers(List<Case_Follower__c> users) {
		
		set<Id> theIds = new set<id>();
	   	for (Case_Follower__c user :users){
			if(user.EntityId__c == null){
				if(!theIds.contains(user.Follower__c)){
				  	theIds.add(user.Follower__c);
					System.debug('***** Adding to map: ' + user.Follower__c);
				}
			}
	   	}
		
		Map<ID, NetworkMember> theUsers = new Map<ID, NetworkMember>();
		List<NetworkMember> networkMembers = [Select N.Network.Name, N.Network.Status, N.Id, N.MemberId, N.Member.ProfileId from NetworkMember N where N.MemberId in : theIds];
		for (NetworkMember member: networkMembers) {
		    theUsers.put(member.MemberId, member);
		}
		
		if(theIds.size() > 0){
			
			System.debug('***** IDs found, starting process');
			System.debug('***** User Map: ' + theUsers);
		
		//process the users
		List<EntitySubscription> subscriptions = new List<EntitySubscription>();
		for (Case_Follower__c user :users){
			
			System.debug('***** Selected User: ' + user);
			System.debug('***** Selected CF Id: ' + user.id);
			System.debug('***** Selected CR Id: ' + user.Case__c);
			
			//crete a new entity subscription
			EntitySubscription follow = new EntitySubscription();
            follow.parentId = user.Case__c;
			follow.subscriberid = user.Follower__c;
			
			if(theUsers.containsKey(user.Follower__c)){
				if(theUsers.get(user.Follower__c).NetworkId != null){
					System.debug('***** Selected CR Id: ' + theUsers.get(user.Follower__c).NetworkId);
					follow.NetworkId = theUsers.get(user.Follower__c).NetworkId;
				}
			}
			System.debug('***** Add Follower: ' + follow);
			subscriptions.add(follow);
		}
		
		if(subscriptions.size() > 0){
			try{
				//insert subscriptions;
				System.debug('***** Saving new subscriptions');
				
				Integer i = 0;	
				Database.SaveResult[] lsr = Database.insert(subscriptions, false);
				for(Database.SaveResult sr:lsr){
					if(!sr.isSuccess()){
						Database.Error err = sr.getErrors()[0];
					   	System.debug('***** insert Error: ' + err.getMessage());
					   	users.get(i).addError(err.getMessage());
				   }else{
					   System.debug('***** Entity Id: ' + sr.getId());
					   System.debug('***** Entity Id: ' + subscriptions.get(i).Id);
					   users.get(i).EntityId__c = subscriptions.get(i).Id;
				   }
				   i += 1;
				}
			}catch(DmlException ex){
				System.debug('***** insert proces error: ' + ex.getMessage());
			}
		}		
	}else{
			System.debug('***** No IDs found, by passing process');	
		}
	}
	
	//method to copy case followers over to change requests
	public static void CreateFollowers(Associated_Case_Change_Request__c[] items) {
		System.debug('*** Processing CRs');
		try{
			//process the case ids
			set<Id> theIds = new set<id>();
		   	for (Associated_Case_Change_Request__c item :items){
				if (item.Case__c != null){
					if(theIds.contains(item.Case__c) != null){
				  		theIds.add(item.Case__c);
					}
				}
		   	}
			
			//process the change request ids
			set<Id> crIds = new set<id>();
			for (Associated_Case_Change_Request__c item :items){
				if (item.Change_Request__c != null){
					if(crIds.contains(item.Change_Request__c) != null){
				  		crIds.add(item.Change_Request__c);
					}
				}
		   	}
			
			//need to go get all the follower records
			/*List<Change_Request_Follower__c> recordsToDelete = [Select C.Change_Request__c, C.Id from Change_Request_Follower__c C where Change_Request__c in : crIds];
			if(recordsToDelete.size() > 0){
				System.debug('*** Deleting records');
				delete recordsToDelete;	
				System.debug('*** Records deleted');
			}*/
			
			System.debug('*** Processing Set: ' + theIds);
			
			//now query the entity subscription table for related followers
			List<EntitySubscription> followers = [select id, subscriberid, NetworkId, subscriber.name, subscriber.email, subscriber.Profile.Name, parentid from EntitySubscription where parentid in :theIds];
			List<Change_Request_Follower__c> existing = new List<Change_Request_Follower__c>([SELECT CR.Id, CR.EntityId__c, CR.Follower__c FROM Change_Request_Follower__c CR WHERE CR.Change_Request__c =: crIds]);
			Set<Id> currentSubscribers = new Set<Id>();
			
			List<Change_Request_Follower__c> crFollowers = new List<Change_Request_Follower__c>();
			for (EntitySubscription follower :followers){
				
				for (Change_Request_Follower__c cr:existing)
				{
					if(cr.Follower__c == follower.subscriberid){
						if (!currentSubscribers.contains(follower.subscriberid)){
							currentSubscribers.add(follower.subscriberid);
							System.debug('***** follower found: ' + follower.subscriberid);
							}
					}
				}
				
				if (!currentSubscribers.contains(follower.SubscriberId)){
					Change_Request_Follower__c newCRFollower = new Change_Request_Follower__c();
					
					//let's loop through to find our cr#
					for (Associated_Case_Change_Request__c cr :items){
						if(cr.Case__c == follower.ParentId){
							newCRFollower.Change_Request__c = cr.Change_Request__c;
						}
					}
					
				   	newCRFollower.Follower__c = follower.SubscriberId;
					newCRFollower.EntityId__c = follower.Id;
					System.debug('*** Added new CR Follower: ' + newCRFollower);
					crFollowers.add(newCRFollower);
				}
			}
				
			//create Change Request followers will create the associated Entitiy Subscription link as well
			if(crFollowers.size() >0){
				System.debug('*** INSERTING FOLLOWERS: ' + crFollowers);
				insert crFollowers;	
			}
				
		}catch(Exception ex){
			System.debug('***** processing error: ' + ex.getMessage());
		}
	}

}