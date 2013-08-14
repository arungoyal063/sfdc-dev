/**
    * CaseStatusChange - notifies chatter followers of a status change
    * @author: bmatthews
    * @version: 1.0
*/

trigger CRStatusChange on Change_Request__c bulk (after update) {
    boolean ignoreTriggers = false;
    if(!Test.isRunningTest()){
        User user = [select ignore_triggers__c from User where id = :UserInfo.getUserId()];
        ignoreTriggers = user.ignore_triggers__c;
    }
    if (ignoreTriggers==false) {
        if(trigger.isAfter){
            System.debug('************* new CODE');
            if(Trigger.old != null){
                set<Id> theIds = new set<id>();
                set<Id> typeIds = new set<id>();
                for(Integer x = 0; x < Trigger.old.size(); x++){
                
                    System.debug('************* new value: ' + trigger.old[x].Status__c);
                    System.debug('************* old value: ' + trigger.new[x].Status__c);
                    if(trigger.new[x].Status__c != trigger.old[x].Status__c){
                        theIds.add(trigger.old[x].Id);
                        
                        if(!typeIds.contains(trigger.old[x].RecordTypeId)){
                            typeIds.add(trigger.old[x].RecordTypeId);   
                        }
                    }
                }
                
                //now go get the list of people to notify
                //List<EntitySubscription> followers = new List<EntitySubscription>();
                //followers = [Select E.Id, E.ParentId, E.SubscriberId, E.Subscriber.Email from EntitySubscription E where parentId in :theIds];
               List<Change_Request_Follower__c> followers = new List<Change_Request_Follower__c>();
               followers = [Select E.Id,  E.Follower__c, E.Change_Request__c, E.Follower__r.Email from Change_Request_Follower__c E where Change_Request__c in :theIds];
               
               
                List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
               Map<ID, RecordType> m = new Map<ID, RecordType>([SELECT Id, Name FROM RecordType where id in:typeIds]);
                
                System.debug('************* found followers' + followers);
                
                System.debug('************* process the emails');
                
                for(Integer x = 0; x < Trigger.old.size(); x++){
                    if(theIds.contains(trigger.old[x].Id)){
                         for (Change_Request_Follower__c follower : followers) {
                        System.debug('************* processing CR: ' + trigger.old[x].Id);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        Map<Id, List<String>>  emails = new   Map<Id, List<String>>();
                        List<String> theEmails = new List<String>();
                        
                       
                          
                                System.debug('************* adding user email: ' + follower.Follower__c);
                             
                                    
                                                     
                        
                       // emails.put(trigger.old[x].Id, theEmails);     
                        CRStatusEmail__c customSetting = CRStatusEmail__c.getValues('default');
                        
                                     
                        if(!Test.isRunningTest()){
                              mail.setTargetObjectId(follower.Follower__c); 
                        }else{
                            String[] toAddresses = new list<String>{'agoyal@rainmaker-llc.com'};
                            mail.setBccAddresses(toAddresses);
                        }
                       
                        
                            String subject = '';
                            String body = '';
                            String link = '';
                            if(null != customSetting && !Test.isRunningTest()){
                                subject = customSetting.Subject__c;
                                body = customSetting.Body__c;
                                link = customSetting.Link__c + trigger.old[x].Id;
                                mail.setSenderDisplayName(customSetting.From_Name__c);
                                mail.setReplyTo(customSetting.From_Address__c);
                            }else{
                                subject = '***From Ellucian: Followers of Case #[NAME]';
                                body = 'A change has been made to Case #[NAME]: [SUBJECT] The status has changed from [OLD_STATUS] to [NEW_STATUS]. You may view the details for the Case here [LINK].';
                                link = 'https://ellucianpilot.sandbox.cs11.force.com/clients/';
                            }                           
                           
                            subject = subject.replace('[ID]',trigger.old[x].Id);
                            subject = subject.replace('[OLD_STATUS]',trigger.old[x].Status__c);
                            subject = subject.replace('[NEW_STATUS]',trigger.new[x].Status__c);
                            subject = subject.replace('[NAME]',trigger.old[x].Name);
                            subject = subject.replace('[LINK]',link);
                            subject = subject.replace('[RECORD_TYPE]', m.get(trigger.old[x].RecordTypeId).Name);
                            subject = subject.replace('[SUMMARY]',trigger.new[x].Summary__c);
                            
                            body = body.replace('[ID]',trigger.old[x].Id);
                            body = body.replace('[OLD_STATUS]',trigger.old[x].Status__c);
                            body = body.replace('[NEW_STATUS]',trigger.new[x].Status__c);
                            body = body.replace('[NAME]',trigger.old[x].Name);
                            body = body.replace('[LINK]',link);
                            body = body.replace('[RECORD_TYPE]', m.get(trigger.old[x].RecordTypeId).Name);
                            body = body.replace('[SUMMARY]',trigger.new[x].Summary__c);
                            mail.setSaveAsActivity(false);
                            mail.setSubject(subject);
                            mail.setPlainTextBody(body);
                            System.debug('************* adding Email to list');
                            listmail.add(mail);
                       }
                        
                    
                     }
                    
                }
                
                if(listmail.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(listmail);    
                }
            }
        }
    
    }
}