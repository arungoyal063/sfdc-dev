/**
*********************************************************************************************************************
* Module Name   :  TrackCRFeedItemInserts
* Description   :  Adds FeedItems associated with a Change Request to the CR_Chatter_Sent staging table for email processing
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    : CRFeedItemBatch 
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      02/10/2013     Milligan         1195             Initial Version
*   
*******************************************************************************************************************
**/
trigger TrackCRFeedItemInserts on FeedItem (after insert) {
boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
List<String> crIDs = new List<String>();
List<Change_Request__c> crList = new List<Change_Request__c>();
List<CR_Chatter_Sent__c> crSentList = new List<CR_Chatter_Sent__c>();
        
List<String> profileNames = new List<String>();        
profileNames.add('Ellucian Communities Profile');    
 
Map<id,Profile> pfMap = new Map<id,Profile>([SELECT id, name FROM Profile WHERE name IN: profileNames]);  
List<String> userIDs = new List<String>();

    for(FeedItem fi: Trigger.new){
        String pID = fi.ParentId;
        System.debug('TrackCRFeed  FeedItem ID --->' + fi.ID + ' CR ID --> '  + fi.ParentID);
        
        if(pID.startsWith('a0GZ') || pID.startsWith('a0ZZ') || pID.startsWith('a0x')){
            //&&  fi.visibility = 'AllUsers'
            crIDs.add(fi.parentID);
            System.debug('TrackCRFeed crID --->' + fi.parentID);
            //System.debug('InsertedBy User Info --->' + fi.insertedByID );
            System.debug('CreatedBy User Info --->' + fi.createdByID );         
            userIDs.add(fi.createdByID);
            
        }       
    }
    
    crList = [SELECT id, Allow_Chatter_Feed_Emails__c,Name FROM Change_Request__c WHERE Allow_Chatter_Feed_Emails__c = true AND id IN: crIDs];
    Map<id, User> userMap = new Map<Id, User>([SELECT id, profileID FROM user WHERE id IN : userIDs]);
    
    if(!crList.IsEmpty()){
        
        System.debug('TrackCRFeed crList.Size --->' + crList.Size());
        
        for(FeedItem fi: Trigger.new){

            if(userMap.containsKey(fi.createdByID)){
                //Not an Ellucian Employee Skip
                User userProfile = userMap.get(fi.createdByID);
                System.debug('Checking User Profile --->' + fi.createdByID );               
                if(pfMap.containsKey(userProfile.profileID)) continue;
                
            } else{
                //Bad User Info
                System.debug('Bad User Info --->' + fi.createdByID );
                continue;
            }
            
            for(Change_Request__c cr: crList){
                if(fi.ParentId == cr.id){
                    CR_Chatter_Sent__c crSent = new CR_Chatter_Sent__c();
                    crSent.CR_ID__c = cr.ID;
                    crSent.Feed_Item_ID__c = fi.ID;
                    crSent.Feed_Item_CreateDate__c = fi.createdDate;
                    crSent.CRName__c = cr.Name;
                    crSentList.add(crSent);     
                    System.debug('TrackCRFeed CR_Chatter_Sent__c  --->' + fi.parentID);
                            
                }
            }
    
        }
        
    }
    
    if(!crSentList.IsEmpty()){
        System.debug('TrackCRFeed  CR SentList --->' + crSentList.Size());      
        insert crSentList;
    }
}
}