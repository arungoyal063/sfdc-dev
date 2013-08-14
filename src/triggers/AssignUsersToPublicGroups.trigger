/**
*********************************************************************************************************************
* Module Name   :  AssignUsersToPublicGroups
* Description   :  Add Communitity Users to public groups based on Product Selection
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      02/10/2013     Milligan         1194             Initial Version
*   
*******************************************************************************************************************
**/
trigger AssignUsersToPublicGroups on User (after insert,after update) {
    //Assign Users to Groups
    List <User> users = new List<User>();
    for (User u : Trigger.new) {
        if ((u.isActive && u.contactId != null)
           && (Trigger.isInsert || 
               (Trigger.isUpdate && (u.isActive &&!Trigger.oldMap.get(u.id).isActive)))) {
        	users.add(u);
        }
    }
    
    if (users.size() > 0)  {
    	UserGroupAssignment.addUserToGroups(users);
    }

}