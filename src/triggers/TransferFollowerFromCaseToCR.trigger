/**
*********************************************************************************************************************
* Module Name   :  TransferFollowerFromCaseToCR
* Description   :   
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :  
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      06/5/2013     Milligan         362               Initial Version
*    
*******************************************************************************************************************
**/
trigger TransferFollowerFromCaseToCR on Associated_Case_Change_Request__c (after insert) {
    
list<AddSubscriberUtils.SearchWrapper>  bb = new  list<AddSubscriberUtils.SearchWrapper>(); 
    
AddSubscriberUtils aa = new AddSubscriberUtils();

boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{    
    
    String NetworkId = null;
    Set<String> cIds = new Set<String>();
    Set<String> crIds = new Set<String>();
   
   List<EntitySubscription> subscribeUsers = new List<EntitySubscription>();    
    
    List<EntitySubscription> esList = new List<EntitySubscription>();
    Map<id, EntitySubscription> esMap = new Map<id, EntitySubscription>();
    Map<id, List<EntitySubscription>> caseMap = new Map<id,List<EntitySubscription>>();
 
    
    List<EntitySubscription> insertEsList = new List<EntitySubscription>();
    
    List<Case> caseList = new List<Case>();
    
    List<String> contactIDs = new List<String>();
    
    List<User> userList = new List<User>();
    Map<String, AddSubscriberUtils.SearchWrapper> cUserMap = new Map<String, AddSubscriberUtils.SearchWrapper>();
    
    for(Associated_Case_Change_Request__c a: Trigger.New)
    {   
        if( a.Relationship__c == 'Associated')
        {
            //add all case ids to set to find subscribers
            cIds.add(a.Case__c);
            system.debug(' Adding Case IDs ---> ' + a.Case__c);
        }
    
    }
    
    if(!cIds.IsEmpty())
    {
        //find all followers of the Cases using Parentid
        //esList = [SELECT SubscriberId, ParentId, Id, CreatedDate FROM EntitySubscription WHERE parentid IN : cIds]; 
        caseList = [SELECT id, contactId FROM Case WHERE id IN: cIds];
        
        
    }
    
    //Find User Records for the Contacts of the Case
    if(!caseList.IsEmpty())
    {
        for(Case c: caseList)
        {
            contactIDs.add(c.contactId);
            system.debug(' Adding Contact IDs ---> ' + c.contactId);
        }
        
        ///  **********    Get Users  
        bb = aa.getSearchResults(contactIDs);
        
        if(!bb.IsEmpty()){
            System.debug('TransferFollowersFromCaseToCR -- Contact Users Size from AddSubscriber ---> ' + bb.size());
        }else
        {
        	 System.debug('TransferFollowersFromCaseToCR -- Contact Users Size from AddSubscriber  is Zero---> ');
        	
        }
        
        //Loop thru User list and add to map containing case id and user to find contact later
        for(AddSubscriberUtils.SearchWrapper u: bb) 
        {
            
            for(Case c: caseList)
            {
                if(u.usr.contactid == c.contactId)
                {
                    //put case ID, user ID in Map
                    cUserMap.put(c.id ,u);
                    system.debug('TransferFollowersFromCaseToCR Found User Add To Map User---> ' + u.usr.Id + ' Case ID--> ' + c.id + ' Contact ID --> ' + c.contactId);
                }
            }
        }
    }
    
    //loop thru all and see if its in the map
    if(!bb.IsEmpty())
    {
             
        for(Associated_Case_Change_Request__c a: Trigger.New)
        {
                    
           System.debug('TransferFollowersFromCaseToCR Look for ALL ES for Case ---> ' + a.case__c);

           if(cUserMap.containsKey(a.Case__c))
           {
                System.Debug(' Found Contact User In Loop ---> ');
                AddSubscriberUtils.SearchWrapper uid  = cUserMap.get(a.Case__c);
                if(uid <> null){
                    System.Debug(' Adding User as follower ---> ' + uid.usr.id + ' for CR --> ' + a.Change_Request__c);
                    EntitySubscription eIns2 = new EntitySubscription();
                    eIns2.SubscriberId = uid.usr.id;
                    eIns2.ParentId = a.Change_Request__c;
                     
                    if(uid.NetworkId != null){
                        eIns2.NetworkId = uid.NetworkId;
                    }                   
                    subscribeUsers.add(eIns2);   
                    System.Debug(' ES Network Id---> ' + NetworkId);                     
                            
                }
            }                       
                                                       
        }
                    
    }
    if(subscribeUsers.size() > 0){
        try{
                    //insert subscriptions;
            System.debug('--> ***** Saving new user subscriptions');
                    
            Integer i = 0;  
            Database.SaveResult[] lsr = Database.insert(subscribeUsers, false);
            for(Database.SaveResult sr:lsr){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    System.debug('-->***** insert subscribeUsers Error: ' + err.getMessage());
                }else{
                     System.debug('--> ***** Entity subscribeUsers Id: ' + sr.getId());
                     //System.debug('--> ***** Entity subscribeUsers Id: ' + subscribeUsers.get(i).Id);
                }
                     i += 1;
              }
           }catch(DmlException ex){
                System.debug('-->***** insert subscribeUsers process error: ' + ex.getMessage());
           }
        }else{
            System.debug('***** No subscribeUsers IDs found, by passing process');  
        }    

  }
}