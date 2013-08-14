/*********************************************************************************************************************
* Module Name   :  UpdateCaseMileStone Controller 
* Description   :  This Class is used to update Target Milestone Date and Completion Date on Case Record
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <Test_UpdateCaseMileStone>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/

public class UpdateCaseMileStone {

      @future 
      public static void updateMileStoneTargetDate(Set<ID> caseIDs) {
       if(caseIDs != null) {
           List<CaseMilestone> mileStoneList   = [SELECT CaseMilestone.Id, CaseMilestone.CaseId, CaseMilestone.CompletionDate,CaseMilestone.TargetDate FROM CaseMilestone WHERE CaseMilestone.CaseId IN :caseIDs ];
           List<Case> caseList = [Select CaseNumber,Priority,Entitlement_Type__c,Id, MileStone_Target_Date__c, Completion_Date__c, Account.Name, Product_Line__c,Product_Name__c,Contact.Name,Contact.Phone,Queue_Group__c, OwnerID,LastModifiedDate,Subject,CreatedDate  from Case where Id IN :caseIDs];
           //List<Case> caseList = [Select Id, MileStone_Target_Date__c, Completion_Date__c,  from Case where Id IN :caseIDs];
           List<Case> updateCaseList = new List<Case>();
            if(!mileStoneList.isEmpty()) {
                Map<ID, CaseMilestone> caseTargetDateMap = new Map<ID, CaseMilestone>();
                for(CaseMilestone cm :mileStoneList) {
                    if(cm.CaseId != null && cm.TargetDate != null) {
                        caseTargetDateMap.put(cm.CaseId , cm);        
                    }     
                }
                
                for(Case c: caseList) {
                    if(caseTargetDateMap.containsKey(c.Id)) {
                        if(c.MileStone_Target_Date__c == null || (c.MileStone_Target_Date__c != caseTargetDateMap.get(c.Id).TargetDate) || (c.Completion_Date__c != caseTargetDateMap.get(c.Id).CompletionDate)) {
                            c.MileStone_Target_Date__c = caseTargetDateMap.get(c.Id).TargetDate;
                            c.Completion_Date__c = caseTargetDateMap.get(c.Id).CompletionDate; 
                            updateCaseList.add(c);
                        }
                    }
                }
                
                if(!updateCaseList.isEmpty()) {
                    try {
                        TriggerRunOnce.runOnce();
                        update updateCaseList;
                        list<String> userIds = new list<String>{Userinfo.getUserId()};
                        for(Case c1: updateCaseList){
                        	userIds.add(c1.OwnerId);
                        }
                        map<Id,User> objUser = new map<Id,User>([SELECT Name,Ignore_Workflows__c,Email FROM User WHERE ID IN:userIds]);
                        system.debug('>>>>>>>>>>>>'+updateCaseList);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        Action_Center_Case_Notification_Priority__c customSetting = Action_Center_Case_Notification_Priority__c.getValues('default');
                        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
                        for(Case c:updateCaseList){
                        	if(c.Priority == '1' && (c.Entitlement_Type__c == 'Hawaii' || c.Entitlement_Type__c == 'Bronze' || c.Entitlement_Type__c == 'Hosted Bronze' || c.Entitlement_Type__c == 'ActionLine12' || c.Entitlement_Type__c == 'ActionLine24'  
                        		|| c.Entitlement_Type__c == 'SmartCall' || c.Entitlement_Type__c == 'PowerCampus24_5' || c.Entitlement_Type__c == 'Standard') 
                        		&& c.Milestone_Target_Date__c != null && objUser.get(userinfo.getUserId()).Ignore_Workflows__c == false){
	                        	String[] toAddresses = new list<String>{'musman@rainmaker-llc.com'};
	                        	String[] ccAddresses = new list<String>();
	                        	toAddresses.add(objUser.get(userinfo.getUserId()).Email);
	                        	for(String email: customSetting.Recipients__c.split(',')){
	                        		toAddresses.add(email);
	                        	}
	                        	for(String ccemail: customSetting.cc_Address__c.split(',')){
	                        		ccAddresses.add(ccemail);
	                        	}  
					            if(!Test.isRunningTest()){		                
					                mail.setToAddresses(toAddresses);
					                mail.setCcAddresses(ccAddresses);		                
					            }else{				                
					                mail.setToAddresses(toAddresses);
					                mail.setCcAddresses(ccAddresses);
					            }
						           
					            String subject = '';
					            String body = '';
					            String link = '';
					           // CaseStatusEmail__c customSetting = CaseStatusEmail__c.getValues('default');
					            if(null != customSetting && !Test.isRunningTest()){
					                subject = customSetting.Subject__c;
					                body = customSetting.Email_Body__c + '\n';
					                body += customSetting.Email_Body1__c;
					                link = customSetting.Link__c + c.Id;
					                mail.setSenderDisplayName(customSetting.From_Name__c);
					                mail.setReplyTo(customSetting.From_Address__c);
					            }else{
					                subject = 'Case# {!Case.CaseNumber} Notification - Priority: {!Case.Priority} Entitlement: {!Case.Entitlement_Type__c}';
					                body = 'Account: {!Case.Account} Product Line: {!Case.Product_Line__c}Product: {!Case.Product_Name__c}Contact Name: {!Case.Contact}Contact Phone: {!Contact.Phone}Date Created: {!Case.CreatedDate} Milestone Target: {!Case.Milestone_Target_Date__c}';
					                link = 'https://ellucianpilot.sandbox.cs11.force.com/clients/';
					            }
					                       
					            subject = subject.replace('{!Case.Id}',c.Id);
					            subject = subject.replace('{!Case.Entitlement_Type__c}',c.Entitlement_Type__c);
					            subject = subject.replace('{!Case.Priority}',c.Priority);
					            subject = subject.replace('{!Case.CaseNumber}',c.CaseNumber);
					            subject = subject.replace('{!Case.Link}',link);
					            subject = subject.replace('{!Case.Subject}',c.Subject); 
					            body = body.replace('{!Case.Id}',c.Id);
					            if(c.Account.Name != null){
					            	body = body.replace('{!Case.Account}',c.Account.Name);
					            }else{
					            	body = body.replace('{!Case.Account}','');
					            }
					            body = body.replace('{!Case.Product_Line__c}',c.Product_Line__c);
					            body = body.replace('{!Case.Product_Name__c}',c.Product_Name__c);
					            if(c.Contact.Name != null){
					            	body = body.replace('{!Case.Contact}',c.Contact.Name);
					            }else{
					            	body = body.replace('{!Case.Contact}','');
					            }
					            if(c.Contact.Phone != null){
					            	body = body.replace('{!Contact.Phone}',c.Contact.Phone);	
					            }else{
					            	body = body.replace('{!Contact.Phone}','');
					            }			            					            
					            body = body.replace('{!Case.CreatedDate}',c.CreatedDate.format('MM/dd/yyyy'));
					            if(c.Milestone_Target_Date__c != null){
					            	body = body.replace('{!Case.Milestone_Target_Date__c}',c.Milestone_Target_Date__c.format('MM/dd/yyyy'));
					            }else{
					            	body = body.replace('{!Case.Milestone_Target_Date__c}','');
					            }
					            body = body.replace('{!Case.Queue_Group__c}',c.Queue_Group__c);
					            if(objUser.get(c.OwnerId) != null){
					            	body = body.replace('{!Case.OwnerFullName}',objUser.get(c.OwnerId).Name);
					            }else{
					            	body = body.replace('{!Case.OwnerFullName}','');
					            }
					            body = body.replace('{!Case.LastModifiedDate}',c.LastModifiedDate.format('MM/dd/yyyy'));
					            body = body.replace('{!Case.Subject}',c.Subject);
					            body = body.replace('{!Case.Link}',link);
					            mail.setSubject(subject);
					            mail.setPlainTextBody(body);
					            //Save As Activity Flag
					            mail.setSaveAsActivity(false);                              
					            listmail.add(mail);	
                        	}	                        
                        }
				        if(listmail.size() > 0) {
			        		system.debug('-----------');
				            Messaging.SendEmailResult[] results = Messaging.sendEmail(listmail);
				        }
				        
                        /*List<Case> caseList1 = [Select Id, Priority, Entitlement_Type__c FROM Case Where Id In: caseIds];
                        User u = [Select id, name, Ignore_Workflows__c From User Where Id =: UserInfo.getUserId()];
                        for(Case ca : caseList1){
                           
                           if((((ca.Priority == '1') && (ca.Entitlement_Type__c == 'Bronze' || ca.Entitlement_Type__c == 'Hosted Bronze' || ca.Entitlement_Type__c == 'ActionLine12' || ca.Entitlement_Type__c == 'ActionLine24')) || ((ca.Priority == '1') && (ca.Entitlement_Type__c == 'SmartCall' || ca.Entitlement_Type__c == 'PowerCampus24_5' || ca.Entitlement_Type__c == 'Standard'))) && (u.Ignore_Workflows__c)){}
                           List<String> toaddr =  new String[] { 'agupta@rainmaker-llc.com' };
                           // Send an email to the Apex job's submitter notifying of job completion.  
                           EmailTemplate et=[Select id from EmailTemplate where name=:'Action Center Case Notification'];
                           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                           mail.setwhatId(ca.id);
                           mail.setToAddresses(toaddr);
                           //mail.setTargetObjectId(con.Id);
                           //mail.setSenderDisplayName(‘Charan Tej’);
                           mail.setTemplateId(et.id);
                           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        } */
                    } catch(Exception e) {
                        System.debug('Error ::' + e);
                    }
                }
                
             } 
         } 
      }
}