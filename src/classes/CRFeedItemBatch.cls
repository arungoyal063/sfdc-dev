/**
*********************************************************************************************************************
* Module Name   :  CRFeedItemBatch
* Description   :  Emails Chatter Feeds from CR_Chatter_Sent staging table  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    : TrackCRFeedItemInserts
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
global class CRFeedItemBatch  implements Database.Batchable<sObject>, Database.Stateful{
    global enum VisibleItem {AllUsers, InternalUsers}
    global String query = '';   
    global List<String> parentIDs = new List<String>();
    global List<EntitySubscription> esList = new List<EntitySubscription>();
    
    //global Map<FeedItem, List<String>>  feedMap = new   Map<FeedItem, List<String>>();
    global Map<FeedItem, List<EntitySubscription>>  feedMap = new   Map<FeedItem, List<EntitySubscription>>();
    
    Map<String,String> fiMap = new Map<String,String>();        
     
      
    String sdttm;
    string sedttm;
    DateTime dttm;
    DateTime edttm;
    global  Database.Querylocator start(Database.BatchableContext bc) {
 
        Date dt = Date.Today();

        //dttm = DateTime.now();   
        //System.debug('CRFeedItemBatch Time Start --->' + dttm);          
        dttm = DateTime.now().addMinutes(-15);    
        System.debug('CRFeedItemBatch Time Start - 15 --->' + dttm + ' Current Time: ' + DateTime.now());          
      
        sdttm = dttm.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';

        edttm = DateTime.now();     
        sedttm = edttm.formatGMT('yyyy-MM-dd') + 'T' + edttm.formatGMT('HH:mm:ss.SSS') + 'Z';   
         
        System.debug('CRFeedItemBatch Time Start --->' + dttm + ' End Time: ' + edttm);
 		//1. test two users
        //query = 'SELECT id, Feed_Item_ID__c,CR_ID__c, Feed_Item_CreateDate__c, CRName__c FROM CR_Chatter_Sent__c where feed_item_id__c = ' + '\'' + '0D5Z000000EkJgvKAF' + '\''  + ' OR feed_item_id__c = ' + '\'' + '0D5Z000000EkJasKAF' + '\'' ;       
        
        //1. test one user  
        //query = 'SELECT id, Feed_Item_ID__c,CR_ID__c, Feed_Item_CreateDate__c, CRName__c FROM CR_Chatter_Sent__c where feed_item_id__c = ' + '\'' + '0D5Z000000EkJgvKAF' + '\'';       
        
        //Prod version
         query = 'SELECT id, Feed_Item_ID__c,CR_ID__c, Feed_Item_CreateDate__c, CRName__c FROM CR_Chatter_Sent__c WHERE  Feed_Item_CreateDate__c  >= '   + sdttm + ' AND Feed_Item_CreateDate__c <= ' + sedttm;      
         
         System.debug('CRFeedItemBatch Query --->' + query);
         return Database.getQueryLocator(query);           
    }
    
 

   global void execute(Database.BatchableContext BC, List<CR_Chatter_Sent__c> cr){
    
        System.debug('CRFeedBatch EXECUTE METHOD START -->');
    
        List<String> feedIDs = new List<String>();
        List<FeedItem> fItems = new List<FeedItem>();       
        
        // Get list of CR ids in feed
        for(CR_Chatter_Sent__c c: cr){
            feedIDs.add(c.Feed_Item_ID__c);
            fiMap.put(c.Feed_Item_ID__c, c.CRName__c);
        }
        
        if(!feedIDs.IsEmpty()){
            
            System.debug('FeedItem Total From CR Chatter Sent c --->' + feedIDs.size());
            
            //find CR FeedItems from FeedItem Object to use later to find CR in ES
            //2. Prod Version
            fItems = [SELECT parentid, id, createddate,Body, ContentData, contentfileName, linkUrl, title  FROM FeedItem WHERE createdDate >= :dttm AND createddate <= :edttm AND id IN: feedIDs];                     
            
            //2. Test Version
            //fItems = [SELECT parentid, id, createddate,Body, ContentData, contentfileName, linkUrl, title  FROM FeedItem WHERE id IN: feedIDs];                     

			
            if(!fItems.IsEmpty()){
                
                List<String> parentIDs = new List<String>();
                
                // get list of feeditem related cr                                  
                for(FeedItem fi: fItems){
                    parentIDs.add(fi.parentID);                 
                }
                
                System.Debug('FeedItem Change request total --->' + fItems.size());
                
                // ES will provide the list of followers for the all CR
                esList = [SELECT id, subscriberid, subscriber.name, subscriber.email, subscriber.id, parentID  FROM EntitySubscription WHERE parentID IN :parentIDs];
                
                System.Debug('Entity Subscription total --->' + esList.size());
    
                for(FeedItem fi: fItems){
             
                    //List<String> subEmails = new List<String>();
                    List<EntitySubscription> subEmails = new List<EntitySubscription>();
            
                    for(EntitySubscription es: esList){
                        
                        
                        if(es.ParentId==fi.ParentId){
                            subEmails.add(es);
                            System.debug('CR --> ' + fi.ParentId + ' User Email address -->' + es.subscriber.email + ' User ID -->' +  es.subscriber.id);
                        }
                    }       
                    if(!subEmails.IsEmpty()){
                        feedMap.put(fi, subEmails);                 
                    }   
                }
        
                if(!feedMap.IsEmpty()){
                    System.Debug('FeedItem value total --->' + feedMap.size());
                }   
                
            } //fiItems
            
        } //if crIDs     
        
   }
   
   global void finish(Database.BatchableContext BC){

              
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        Date runDate = Date.TODAY();
        String dataDateStr = 'runDateNull';        
        dataDateStr = String.valueOf(Date.TODAY());
        
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        System.debug('CRFeedBatch FINISH METHOD START -->');

        // List of CRs from FeedItem
        for(FeedItem fi: feedMap.keySet()){
            
            //Get the CR Chatter Feed from ConnectAPI
            ConnectApi.FeedItem item = ConnectApi.ChatterFeeds.getFeedItem(null, fi.Id);
             
            System.debug('FeedItem processing ID -->' + fi.Id);
            
            if(item.Visibility == ConnectApi.FeedItemVisibilityType.InternalUsers) continue;
            
            System.debug('FeedItem Visibilty -->  Not Internal User!!');
            
            // Get instance of Feed Item
            FeedItemInfo fitem = new FeedItemInfo(item);
            
            String crName = '';
            
            System.Debug('photo ---> '+ fitem.feedItem.photoUrl);           
            System.Debug('username ---> '+ fitem.userName);
            System.Debug('linkUrl ---> '+ fitem.linkUrl);  
            System.Debug('imageUrl ---> '+ fitem.imageUrl);  
                        
            if(fi.body <> null){
        
////////		
            	List<EntitySubscription> es = feedMap.get(fi);
            	
            	for(EntitySubscription sub : es)
            	{
            		
              		if(fiMap.containsKey(fi.id)){
                		crName = fiMap.get(fi.id);
              		}
              		
                    System.debug('Finish CR Name--> ' + crName + ' User Email address -->' + sub.subscriber.email + ' User ID -->' +  sub.subscriber.id);
              		
               
               		//body + username
               		Messaging.EmailFileAttachment  emailattach = new Messaging.EmailFileAttachment ();
               		Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
               
               		String emailBody = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">';
               		emailBody  = emailBody + '<br/>';
              		emailBody  = emailBody + '<html>';
              		emailBody  = emailBody + '<div class="row"><br/>';
               		emailBody  = emailBody + '<div style="display:inline-block;vertical-align:top;"><img src="' + fitem.feedItem.photoUrl  + '" style="margin:4px" width="25" />';
               		emailBody  = emailBody + '<b>' + fitem.userName + '</b><br/>';
               		emailBody  = emailBody + '<br/>';
               		emailBody  = emailBody + fitem.formattedText;
               		emailBody  = emailBody + '<br/>';                           
    
               		//add LinkUrl
               		if(fi.linkUrl <> null){
                    	emailBody  = emailBody + '<a href="' + fi.LinkUrl + '">' + fi.Title + '</a><br/>';                             
               		}
               
               		// add Comments
               		if(fitem.commentCount > 0){
                    
                    	for(CommentInfo cm : fitem.comments){
                        
                        	if(cm.imageUrl <> null){
                            	emailBody  = emailBody + '<div style="margin:4px;padding:4px;width:100%;">';
                            	emailBody  = emailBody + '<div style="display:inline-block;vertical-align:top;"><img src="' + cm.comment.user.photo.smallPhotoUrl +  '"style="margin:4px" width="25"/>';
                            	emailBody  = emailBody + '<div/><br/>';   
                                                                
                        	}                       
  
                        	emailBody  = emailBody + '<div style="display:inline-block;vertical-align:top;width:250px">';                       
                        	emailBody  = emailBody + '<b>' + cm.userName + '</b><br>';    
                        	emailBody  = emailBody +  '<b>' + cm.formattedText + '</b><br>';  
                        	emailBody  = emailBody + '<div/>';         
                        	emailBody  = emailBody + '<div style="clear: both;"/>';                     
                                                                                                                                
                    	}
                
               		}
               
               		emailBody  = emailBody  + '</div>';               
               		emailBody  = emailBody + '</html>';
                
               		//check for attachment
               		if(fi.ContentData <> null){
                
                    	Messaging.EmailFileAttachment fileAttached = new Messaging.EmailFileAttachment();     
                    	//blob fileAttachedBlob = blob.valueOf(fi.ContentData);
                          
                    	fileAttached.setFileName(fi.ContentFileName);
                    	fileAttached.setBody(fi.ContentData);               
                    	email.setFileAttachments(new Messaging.EmailFileAttachment[]{fileAttached});
                
               		}
               
               		///******    Address Target Object
               		 
               		
                	email.setTargetObjectId(sub.subscriber.id);
                
                	//List<String> toAddresses = new List<String>();
                	//toAddresses.add('smilligan@rainmaker-llc.com');
                	//email.setBccAddresses(toAddresses);
                 	CRStatusEmail__c customSetting = CRStatusEmail__c.getValues('default');
                 	String subject = customSetting.Subject__c;
                 	if(subject != null){
                 		subject = subject.replace('[NAME]',crName);
                 	}
                	email.setSubject(subject);//'Chatter Feed For Change Request: ' + crName);
                	email.setHtmlBody(emailBody);   
                	
                	email.setSaveAsActivity(false); 

                  ///***********
                  
       	    		listmail.add(email);
       	    		
             	}  // es for  
             	               
            }  //if
            
        } //for
        
        if(!listmail.IsEmpty()){
        	System.debug('List Size --->' + listmail.size());
         	Messaging.SendEmailResult [] results = Messaging.sendEmail(listmail);                       	
        }
        
   }
   
    @IsTest(SeeAllData=true)
    private  static void testCRFeedItemBatch() {
        
        Test.StartTest();
        
        //User
        Contact contact = new Contact();
        Account a;
        Product2 prod = new Product2();
        
        List<String> profileNames = new List<String>();
        profileNames.add('Overage Customer Portal Manager Custom');
        profileNames.add('Overage Ellucian Commmunities Manager Custom');
        profileNames.add('Overage Ellucian Commmunities Standard User');
        profileNames.add('Overage Ellucian Communities Manager Custom');
    
        List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name IN: profileNames]);
    
        User temp = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(temp)
        {
            temp.Can_Create_Accounts__c = true;
            update temp;
            //Create an Account to Associate to the Contact
            a = new Account();
            a.Name = 'Test';
            insert a;
                        
            //Create a Contact and A User for testing the trigger
            contact = new Contact();
            contact.LastName = 'Test';
            contact.AccountId = a.Id;
            insert(contact);
            
            prod.Name = 'Test Prod';
            insert prod;    
                        
            
        }   
  
        //Change Request
        Change_Request__c cr1 = new Change_Request__c();
        //cr1.Name = 'Change Request 1';
        cr1.Product__c = prod.id;
        cr1.Description__c ='Test CR';
        cr1.Summary__c = 'CR Summary';
        cr1.Status__c = 'New';
        insert cr1;
        
        //EntitySubscription
        EntitySubscription es = new EntitySubscription();
        es.ParentId = cr1.Id;
        es.SubscriberId = temp.Id;
        insert es;
        
        //FeedItem
        FeedItem fi = new FeedItem();
        fi.ParentId = cr1.Id;
        fi.Body = 'This is a test chatter feed';
        insert fi;
         
        CRFeedItemBatch batchRun = new CRFeedItemBatch();
        ID batchprocessid = Database.executeBatch(batchRun);  
        
                    
        AsyncApexJob a1 = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchprocessid];
        System.debug('\n\nFinal results are: '+a1);
        System.AssertEquals('Queued', a1.status);
        System.AssertEquals(0, a1.NumberOfErrors);
            
        Test.stopTest(); 
        
    }  
   
}