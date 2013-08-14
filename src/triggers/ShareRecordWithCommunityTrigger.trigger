/*********************************************************************************************************************
* Module Name   :  ShareRecordWithCommunityTrigger Trigger
* Description   :  This Trigger is Used to Share Community User Record with Account's Community User
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : Test_ShareRecordWithCommunity
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
trigger ShareRecordWithCommunityTrigger on Community_User__c(after insert) {
 boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{   
    Set<ID> accountIds = new Set<ID>();
    Set<ID> relatedIds = new Set<ID>(); 
    Map<String,String> accountRoleMap = new Map<String,String>();
    Map<String,String> accountGroupMap = new Map<String,String>();
    
    List<Community_User__Share> commShareList = new List<Community_User__Share>();
    
    for(Community_User__c cu :Trigger.New) {
        if(cu.Account__c != null) {
            accountIds.add(cu.Account__c);       
        }    
    }  
    
    List<UserRole> roleList = [Select u.Id, u.PortalType, u.PortalRole, u.PortalAccountId from UserRole u where PortalAccountId in :accountIds and PortalType = 'CustomerPortal' and PortalRole='Executive'];
   
    
    for(UserRole ur :roleList) {
        relatedIds.add(ur.Id);
        accountRoleMap.put(ur.id,ur.PortalAccountId);    
    }
    
    List<Group> groupList = [Select Id,RelatedId From Group g where type = 'RoleAndSubordinates' and RelatedId in :relatedIds];
    
    for(Group g :groupList) {
        accountGroupMap.put(accountRoleMap.get(g.RelatedId), g.Id);        
    }
    
    if(!accountRoleMap.isEmpty()) {
        for(Community_User__c cu :Trigger.New) {
            if(cu.Account__c != null && accountGroupMap.containsKey(cu.Account__c)) {
                Community_User__Share shareObj = new Community_User__Share(); 
                shareObj.UserOrGroupId = accountGroupMap.get(cu.Account__c);
                shareObj.ParentId = cu.Id;
                shareObj.RowCause = Schema.Community_User__Share.RowCause.Manual;
                shareObj.AccessLevel = 'Read';
                commShareList.add(shareObj);       
            }    
        }          
    }
    
    
    if(!commShareList.isEmpty()) {
            Database.SaveResult[] lsr = Database.insert(commShareList,false);
           
            Integer i=0;
            for(Database.SaveResult sr : lsr) {
                if(!sr.isSuccess()) {
                    // Get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    trigger.newMap.get(commShareList[i].ParentId).
                          addError(
                           'Unable to grant sharing access due to following exception: '
                           + err.getMessage());
                   
                }
                i++;
            }           
     }
    
}
}