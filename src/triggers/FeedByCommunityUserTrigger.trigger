/********************************************************************************************************************
* Module Name   :  FeedByCommunityTrigger Trigger
* Description   :  This Trigger is used to create Comment on Case and update status to client update on Case feed insert by Community user
* Throws        :  <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  Test_FeedByCommunityUser
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
trigger FeedByCommunityUserTrigger on FeedItem (after insert) {
 boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    List<CaseComment> commentList = new List<CaseComment>();
    Set<String> portalUser = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
    
    if(portalUser.contains(UserInfo.getUserType())) {        
        for(FeedItem fi :Trigger.New) {
            String parentId = fi.ParentId;            
            
            if(parentId != null && parentId.startsWith('500')) {               
                CaseComment cc = new CaseComment();
                
                if(fi.Type == 'TextPost') {
                    cc.ParentId = fi.ParentId;
                    cc.CommentBody = fi.Body;
                    commentList.add(cc);
                } else if(fi.Type == 'ContentPost') {
                    cc.ParentId = fi.ParentId;
                    cc.CommentBody = 'New File ' + fi.ContentFileName + ' Uploaded';
                    commentList.add(cc);
                } else if(fi.Type == 'LinkPost') {
                    cc.ParentId = fi.ParentId;
                    cc.CommentBody = 'New Link ' + fi.Title + ' Posted';
                    commentList.add(cc);
                } 
            }     
        }
        
        if(!commentList.isEmpty()) {
            try {
                insert commentList;
            } catch(DMLException e) {
                System.debug('Error' + e.getDMLMessage(0));
            } catch(Exception e) {
                System.debug('Error' + e.getMessage());
            }    
        }
    } 
}
}