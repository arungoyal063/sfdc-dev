/**
    * CaseStatusChange - notifies chatter followers of a status change
    * @author: bmatthews
    * @version: 1.0
*/

trigger CaseStatusChange on Case bulk (after update) {
    boolean ignoreTriggers = false;
    boolean ignoreWorkflows = false;
    User user = [select ignore_triggers__c,Ignore_Workflows__c 
                    from User where id = :UserInfo.getUserId()];
    ignoreTriggers = user.ignore_triggers__c;
    ignoreWorkflows = user.Ignore_Workflows__c;
        
    if (ignoreTriggers)
        return;
        
     list<Id> caseIdList = new list<Id>();
     System.debug('************* new CODE');
     set<Id> theIds = new set<id>();
     set<Id> typeIds = new set<id>();
     for(Integer x = 0; x < Trigger.old.size(); x++){
                
        System.debug('************* new value: ' + trigger.old[x].Status);
        System.debug('************* old value: ' + trigger.new[x].Status);
        if((trigger.new[x].Status != trigger.old[x].Status) 
        || (trigger.new[x].Subject != trigger.old[x].Subject)){
            if(trigger.new[x].Status == 'Client Action Required' ) { 
                caseIdList.add(trigger.new[x].Id);
            }
            if(!theIds.contains(trigger.old[x].Id)){
                theIds.add(trigger.old[x].Id);
            }                        
            
            if(!typeIds.contains(trigger.old[x].RecordTypeId)){
                typeIds.add(trigger.old[x].RecordTypeId);   
            }
        }
    }
         
        if (theIds.size() > 0) {       
        //now go get the list of people to notify
        //List<EntitySubscription> followers = new List<EntitySubscription>();
        System.debug(theIds);
        //followers = [Select E.Id, E.ParentId, E.SubscriberId, E.Subscriber.Email from EntitySubscription E where parentId in :theIds Limit 500];    
        List<Case_Follower__c> followers = new List<Case_Follower__c>();
        followers = [SELECT Case__c, Follower__c,Id, Follower__r.email FROM Case_Follower__c WHERE Case__c IN: theIds];                
        System.debug(theIds);
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        Map<ID, RecordType> m = new Map<ID, RecordType>([SELECT Id, Name FROM RecordType where id in:typeIds]);
        
        System.debug('************* found followers' + followers);
        
        System.debug('************* process the emails');
        
        for(Integer x = 0; x < Trigger.old.size(); x++){
            for (Case_Follower__c follower : followers) {
                if(follower.Case__c == trigger.old[x].Id){
                    System.debug('************* processing CR: ' + trigger.old[x].Id);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    Map<Id, Set<Id>>  emails = new   Map<Id, Set<Id>>();
                    Set<Id> theEmails = new Set<Id>();
                    CaseStatusEmail__c customSetting = CaseStatusEmail__c.getValues('default');
                    
               
            
                        
           emails.put(trigger.old[x].Id, theEmails);     
                                     
            if(!Test.isRunningTest()){
                
                 mail.setTargetObjectId(follower.Follower__c); 
                
            }else{
                String[] toAddresses = new list<String>{'agoyal@rainmaker-llc.com'};
                mail.setBccAddresses(toAddresses);
            }
           
            String subject = '';
            String body = '';
            String link = '';
           // CaseStatusEmail__c customSetting = CaseStatusEmail__c.getValues('default');
            if(null != customSetting && !Test.isRunningTest()){
                subject = customSetting.Subject__c;
                body = customSetting.Body__c;
                link = customSetting.Link__c + trigger.old[x].Id;
                mail.setSenderDisplayName(customSetting.From_Name__c);
                mail.setReplyTo(customSetting.From_Address__c);
            }else{
                subject = '***From Ellucian: Followers of Case #[NAME]';
                body = 'A change has been made to Case #[NAME]: [SUBJECT] The status has changed from [OLD_STATUS] to [NEW_STATUS].You may view the details for the Case here [LINK].';
                link = 'https://ellucianpilot.sandbox.cs11.force.com/clients/';
            }
                       
            subject = subject.replace('[ID]',trigger.old[x].Id);
            subject = subject.replace('[OLD_STATUS]',trigger.old[x].Status);
            subject = subject.replace('[NEW_STATUS]',trigger.new[x].Status);
            subject = subject.replace('[NAME]',trigger.old[x].CaseNumber);
            subject = subject.replace('[LINK]',link);
            //subject = subject.replace('[RECORD_TYPE]', m.get(trigger.old[x].RecordTypeId).Name);                                                       
            subject = subject.replace('[SUBJECT]',trigger.old[x].Subject); 
            body = body.replace('[ID]',trigger.old[x].Id);
            body = body.replace('[OLD_STATUS]',trigger.old[x].Status);
            body = body.replace('[NEW_STATUS]',trigger.new[x].Status);
            body = body.replace('[NAME]',trigger.old[x].CaseNumber);
            body = body.replace('[LINK]',link);
            //body = body.replace('[RECORD_TYPE]', m.get(trigger.old[x].RecordTypeId).Name);
            body = body.replace('[SUBJECT]',trigger.old[x].Subject);
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            //Save As Activity Flag
            mail.setSaveAsActivity(false);                              
            System.debug('************* adding Email to list');
            //if (toAddressList.size() > 0)
            listmail.add(mail);
                        
        }
         }
        }
        
        if(listmail.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(listmail);    
        }
            
}
        
        //code for removal of field update "Set Next Contact Date Client Action Requ" on WFR "Case Set Next Contact Date & Create Task - Client Action Required"
        if(!caseIdList.isEmpty()){
            List<Case> caseObjList = [SELECT Id, Next_Contact_Date__c FROM Case WHERE Id in :caseIdList];
            for(Case caseObj: caseObjList){
                caseObj.Next_Contact_Date__c = system.today() + 14;
            }
            try{                            
                update caseObjList;
            }
            catch(Exception e){}
        }
    
}