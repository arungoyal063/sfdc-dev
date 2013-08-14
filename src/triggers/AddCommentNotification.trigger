/**
    * AddCommentNotification - <description>
    * @author: Rainmaker Admin Ellucian
    * @version: 1.0
*/

trigger AddCommentNotification on CaseComment bulk (after insert) {
boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    //if(trigger.isAfter){
        System.debug('************* new CODE');
        
        set<Id> theIds = new set<id>();
        set<Id> typeIds = new set<id>();
        for(Integer x = 0; x < Trigger.new.size(); x++){
        
            System.debug('************* old value: ' + trigger.new[x].ParentId);
            if(!theIds.contains(trigger.new[x].ParentId)){
                theIds.add(trigger.new[x].ParentId);
                
                if(!typeIds.contains(trigger.new[x].Parent.RecordTypeId)){
                    typeIds.add(trigger.new[x].Parent.RecordTypeId);    
                }
            }
        }
                
                
                //now go get the list of people to notify
                List<EntitySubscription> followers = [Select E.Id, E.ParentId, E.SubscriberId, E.Subscriber.Email from EntitySubscription E where parentId in :theIds]; 
                List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
                Map<ID, RecordType> m = new Map<ID, RecordType>([SELECT Id, Name FROM RecordType where id in:typeIds]);
                Map<ID, Case> parentCases = new Map<ID, Case>([SELECT Id, CaseNumber, Subject FROM Case where id in:theIds]);
                
                System.debug('************* found followers' + followers);
                
                System.debug('************* process the emails');
                
                for(Integer x = 0; x < Trigger.new.size(); x++){
                    if(theIds.contains(trigger.new[x].ParentId)){
                        System.debug('************* processing Case: ' + trigger.new[x].ParentId);
                        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'actionline@ellucian.com'];
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        Map<Id, List<String>>  emails = new   Map<Id, List<String>>();
                        List<String> theEmails = new List<String>();
                        
                        for (EntitySubscription follower : followers) {
                            if(follower.ParentId == trigger.new[x].ParentId){
                                System.debug('************* adding user email: ' + follower.Subscriber.Email);
                                if(follower.Subscriber.Email != null && follower.Subscriber.Email.trim() != '' && follower.Subscriber.Email.trim() != '#N/A' && follower.Subscriber.Email.trim() != 'N/A'){
                                    theEmails.add(follower.Subscriber.Email);
                                }
                            }
                        }
                        
                        emails.put(trigger.new[x].Id, theEmails);     
                        CaseCommentEmail__c customSetting = CaseCommentEmail__c.getValues('default');
                        
                        String[] toAddresses = emails.get(trigger.new[x].Id);                        
                        if(toAddresses != null && toAddresses.size() > 0) {
                        
                            String subject = customSetting.Subject__c;
                            String body = customSetting.Body__c;
                            String link = customSetting.Link__c + trigger.new[x].Id;
                           
                            subject = subject.replace('[ID]',trigger.new[x].Id);
                            //subject = subject.replace('[OLD_STATUS]',trigger.old[x].Status);
                            //subject = subject.replace('[NEW_STATUS]',trigger.new[x].Status);
                            subject = subject.replace('[NAME]',parentCases.get(trigger.new[x].ParentId).CaseNumber);//trigger.new[x].Parent.CaseNumber);
                            subject = subject.replace('[LINK]',link);
                            //subject = subject.replace('[RECORD_TYPE]', m.get(trigger.old[x].RecordTypeId).Name);
                            subject = subject.replace('[SUBJECT]',parentCases.get(trigger.new[x].ParentId).Subject);//trigger.old[x].Subject);
                            
                            body = body.replace('[ID]',trigger.new[x].Id);
                            body = body.replace('[COMMENT]',trigger.new[x].CommentBody);
                            ///body = body.replace('[OLD_STATUS]',trigger.old[x].Status);
                            //body = body.replace('[NEW_STATUS]',trigger.new[x].Status);
                            body = body.replace('[NAME]',parentCases.get(trigger.new[x].ParentId).CaseNumber);
                            body = body.replace('[LINK]',link);
                            //body = body.replace('[RECORD_TYPE]', m.get(trigger.new[x].RecordTypeId).Name);
                            body = body.replace('[SUBJECT]',parentCases.get(trigger.new[x].ParentId).Subject);
                            
                            mail.setSubject(subject);//'New Case Comment'
                            mail.setPlainTextBody(body);
                            mail.setbccAddresses(toAddresses);
                            
                            //mail.setSenderDisplayName(customSetting.From_Name__c);
                            mail.setReplyTo(customSetting.From_Address__c);
                            
                            if (owea.size() > 0 ) {
                               mail.setOrgWideEmailAddressId(owea.get(0).Id);
                            }else{ mail.setSenderDisplayName(customSetting.From_Name__c);}
                            System.debug('************* adding Email to list');
                            listmail.add(mail);
                       }
                        
                    }
                    
                }
                
                if(listmail.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(listmail);    
                }
            //}
        

}
}