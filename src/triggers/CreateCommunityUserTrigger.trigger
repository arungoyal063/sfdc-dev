/*********************************************************************************************************************
* Module Name   :  CreateCommunityUserTrigger Trigger
* Description   :  1. This Trigger is Used to create & update community user record on create & update of portal user
                   2. Update community user contact on update of community user profile 
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    : CommunityUserController Controller
* Test Class    : Test_CommunityUserController
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/

trigger CreateCommunityUserTrigger on User(after insert, after update) {
    if(Trigger.isAfter) { 
        if(Trigger.isInsert) {
            if(!System.isFuture()) {
                CommunityUserController.createCommunityUser(Trigger.NewMap.keySet());    
            }
        }
        else if(Trigger.isUpdate) {
             // asynchronously update community user record
             if(TriggerRunOnce.runOnce()) {
                 if(!System.isFuture()) {    
                     CommunityUserController.updateCommunityUser(Trigger.NewMap.keySet());
                 }
                 Set<ID> contactIdSet = new Set<ID>(); 
                 for(User cu :Trigger.New) {
                     User olduser = Trigger.oldMap.get(cu.Id);
                     // checks if user fields available in community changed or not
                     if(cu.ContactId != null && CommunityUserController.isUserUpdate(olduser, cu)) {
                         contactIdSet.add(cu.ContactId);   
                     } 
                 }
                 try {
                     // synchronously update contact record
                     if(!contactIdSet.isEmpty()) {
                         CommunityUserController.updateCommunityContacts(contactIdSet);
                     }
                 } catch(DMLException e){
                     Trigger.New[0].addError(e.getDMLMessage(0));
                 } catch(Exception e){
                     Trigger.New[0].addError(e.getMessage());
                 }
             }
        }
    }
}