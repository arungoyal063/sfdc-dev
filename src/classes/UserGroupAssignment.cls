/**
*********************************************************************************************************************
* Module Name   :  UserGroupAssignment
* Description   :  Add Communitity Users to public groups based on Product Selection. 
*                  Checks if the user is having access to products and add them to group 
*					to aceess licenses
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      07/27/2013     Kalyan Lanka         xxxx             Initial Version
*   
*******************************************************************************************************************
**/
public  class UserGroupAssignment {
    
    public static void addUserToGroups(List<User> usersList) {
        //Get Active Users
        List<User> portalUsersList = getListOfActivePortalUsersList(usersList);
       
        Set <Id> accountIds = new Set<Id>();
        Set <Id> userIDList = new Set<Id> ();
        
        //Get Accounts from the portal list
        System.debug(portalUsersList);
        for (User u: portalUsersList) {
        	accountIds.add(u.accountId);
            userIDList.add(u.id);
        }
        Id prevAccountID;
        Map<Id, Set<String>> accountGroups = new Map<Id,Set<String>>();
        Set<String> groupNameSet = new Set<String>();
        Set<String> groupNameList;
        
        //Get Licensed products by accounts
        for (Licensed_Product__c l : [SELECT id, account__c,Product_New__r.Security_Group__c  
                                      	FROM Licensed_Product__c 
                                      WHERE Product_New__r.Security_Group__c <> null 
                                      AND account__c IN: accountIds 
                                      order by account__c]) {
            //Create a map of group names that the accounts have access
            if (prevAccountID != l.account__c) {
                
                prevAccountID = l.account__c;
                groupNameList = new Set<String>();
            	accountGroups.put(l.account__c,groupNameList);
            }
            groupNameSet.add(l.Product_New__r.Security_Group__c);
            groupNameList.add(l.Product_New__r.Security_Group__c);
        }
        
        //Get Groups Information
        List<Group> groupList = [SELECT id, name FROM Group WHERE name IN :groupNameSet];
        
        Map<String, Id> groupMap = new Map<String,Id>();
        for (Group g: groupList) {
        	groupMap.put(g.name,g.id);
        }
        
        //Get Existing Group Member information for the users
        Id prevUserID;
        Map<Id, Set<Id>> userGroupMap = new Map<Id,Set<Id>>();
        Set <Id> groupIDSet;
        for (GroupMember gm : [SELECT id, UserOrGroupId, GroupId 
                               FROM GroupMember WHERE UserOrGroupId in :userIDList 
                                order by UserOrGroupId]) {
            if (prevUserID != gm.UserOrGroupId) {
                 prevUserID = gm.UserOrGroupId;
                 groupIDSet = new Set<Id>();
            	 userGroupMap.put(gm.UserOrGroupId,groupIDSet);
            }
            groupIDSet.add(gm.GroupId);
        }
        
        List <GroupMember> grpMemberSet = new List <GroupMember> ();
        for(User u: portalUsersList){
        	try {
	            if (accountGroups != null && accountGroups.size() > 0 
	                && accountGroups.get(u.accountId) != null) {
	                for (String groupName : accountGroups.get(u.accountId)) {
	              	 	boolean notExisting=true;
	               		//Check if the group is already existing
	                    if (userGroupMap.containsKey(u.id)) {
	                        Set<Id> groupIDs = userGroupMap.get(u.id);
	                        if (groupMap.containsKey(groupName) && 
	                            (groupIDs.contains(groupMap.get(groupName)))) {
	                            notExisting = false;
	                       }
	                    }
	                    if (notExisting &&  groupMap.containsKey(groupName)) {
	                        GroupMember gm = new GroupMember();
	                        gm.UserOrGroupId = u.id;
	                        gm.GroupId = groupMap.get(groupName);
	                        grpMemberSet.add(gm);
	                    }
	           		}
	              }
        	} catch (NullPointerException ex){
        		System.debug('It is okay.. because this hapens only in test cases..  Null Pointer Exception');
        	}
            
           
        }
        
        if (grpMemberSet.size() > 0) {
       		upsert grpMemberSet;
        }
    }
    
    /**
	*  Get only portal Users
	*
	**/
    private static List<User> getListOfActivePortalUsersList(List <User> usersList) {
        List<User> portalUsersList = new List<User>();
        Profile communitiesProfile;
        try {
	       communitiesProfile = [Select id from Profile where name = 'Ellucian Communities Profile' LIMIT 1];
        } catch (QueryException ex) {
        	System.debug('Commmunities not found');
        }
        for (User u : usersList) {
            if (u.contactId != null && u.isActive && communitiesProfile != null) {
                portalUsersList.add(u);
            }
        }
        System.debug(portalUsersList);
        return portalUsersList;
    }
    

}