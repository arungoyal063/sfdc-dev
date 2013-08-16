/**
*********************************************************************************************************************
* Module Name   :  AccountTeamEmailBatch
* Description   :  Emails    
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :   EmailWrapper
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      02/10/2013     Milligan         1444             Initial Version
*   
*******************************************************************************************************************
**/ 
global class AccountTeamEmailBatch  implements Database.Batchable<sObject>, Database.Stateful{
    global String query = '';   
    
    List<AccountTeamMember> atmList = new  List<AccountTeamMember>();
    Set<EmailWrapper> emailSet = new  Set<EmailWrapper>();
      
    String sdttm;
    string sedttm;
    DateTime dttm;
    DateTime edttm;
     
    global  Database.Querylocator start(Database.BatchableContext bc) {
 
        Date dt = Date.Today();

        //dttm = DateTime.now();   
        //System.debug('CRFeedItemBatch Time Start --->' + dttm); 
                 
        dttm = DateTime.now().addMinutes(-5);
        System.debug('AccountTeamEmailBatch Time Start - 5 --->' + dttm + ' Current Time: ' + DateTime.now());                  
      
        sdttm = dttm.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';

        edttm = DateTime.now();     
        sedttm = edttm.formatGMT('yyyy-MM-dd') + 'T' + edttm.formatGMT('HH:mm:ss.SSS') + 'Z';   
        
        System.debug('AccountTeamEmailBatch Time Start --->' + dttm + ' End Time: ' + edttm);
            
  
        query = 'SELECT UserId, TeamMemberRole, CreatedDate, AccountId, User.Email, User.id, Account.Name FROM AccountTeamMember WHERE TeamMemberRole = '   + '\'' + 'Client Account Manager' + '\'' +     ' AND  CreatedDate   >= '   + sdttm + ' AND CreatedDate <= ' + sedttm;      
        //query = 'SELECT UserId, TeamMemberRole, CreatedDate, AccountId, User.Email, User.id, Account.Name FROM AccountTeamMember WHERE TeamMemberRole  IN ( '   + '\'' + 'biNOW Account Manager' + '\'' + ','  + '\'' + 'OAN Account Manager' + '\'' +   ')  AND  CreatedDate   >= '   + sdttm + ' AND CreatedDate <= ' + sedttm;        
        System.debug('AccountTeamEmailBatch Query --->' + query);
        
        return Database.getQueryLocator(query);           
    }
    
    global void execute(Database.BatchableContext BC, List<AccountTeamMember> atm){
    	
    	Set<String> acctIds = new Set<String>();
    	Map<id, Account> acctMap = new Map<id, Account>();
 		
 		for(AccountTeamMember a: atm){	
 
 			acctIds.add(a.AccountId);			
 			
 		}
 		
 		if(!acctIds.IsEmpty()){
 			
 			System.debug('acctIds size --> ' + acctIds.size());
 			
 			acctMap = new Map<id, Account>([SELECT id, name, (Select Id, CreatedDate,Closed_On__c, Account_Name__c  From Agreements__r where Agreement_Status__c = 'Pending Approval' order by CreatedDate desc) FROM Account WHERE id IN: acctIDs]);
 			
			for(AccountTeamMember a: atm){	
				
				
	 			if(acctMap.containsKey(a.AccountId)){
	 				
	 		 		Account acct = acctMap.get(a.AccountId);
	 		 		
					DateTime maxDate = null;
					Agreements__c maxAgree = new Agreements__c();
					//for each acct loop through the agreements for acct to get latest one
					//if(!acct.Agreements__r.isEmpty())
						//maxAgree = acct.Agreements__r.get(0);
					
					///for each acct loop through the agreements for acct to get latest one
					for(Agreements__c al: acct.Agreements__r){
					
						if(maxDate == null){
							maxDate = al.CreatedDate;
							maxAgree = al;
							
						}else{
							if(al.CreatedDate > maxDate){
								maxDate = al.CreatedDate;
								maxAgree = al;
								
							}
						}

					} //for

					if(maxAgree <> null){
						EmailWrapper em = new EmailWrapper();
						em.AcctID = a.AccountId;
						em.AgreeID = maxAgree.id;
						em.EmailAddress = a.User.Email;
						em.UserId = a.UserId;
						em.AcctName = a.Account.Name;
						emailSet.add(em);
						
						System.debug('Agreement --> ' + em.AgreeID + '  Account -- ' + em.Acctname + ' User ID ' + em.UserId);
					}						
	 			}	
			
			} //for
			
 		}	//acctIds	
    	 
    }   
    
   global void finish(Database.BatchableContext BC){
   		//“You have been assigned this Account.  Please review the Agreement and begin the onboarding process.”
    		
    	List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
   		
   		if(!emailSet.IsEmpty()){
 
        	AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        	Date dt = Date.TODAY();    
        
        
        	String dataDateStr = 'runDateNull';  		
    		
    		for(EmailWrapper atm: emailSet){
    			
    			String agreeID = '';
    			if(atm.AgreeID != null){
    				agreeID = atm.AgreeID;
    			}    		
    					
    			String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + atm.AcctID;
    			String agreeRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + agreeID;
    			
    			String subjectTxt = 'Salesforce Account Team Role Change';
				String bodyTxt = '\n You have been assigned Account - ' + atm.AcctName + + ' ' + fullRecordURL + '\n\n Please review the Agreement ' + agreeRecordURL  +  ' and begin the onboarding process.';
    			
        		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        		String[] toAddresses = new List<String> ();        		
        		
        		toAddresses.add(atm.EmailAddress);
        		//toAddresses.add('smilligan@rainmaker-llc.com');
        		 
                
       	 		email.setSubject(subjectTxt);
        		email.setToAddresses( toAddresses );        		    			
    			email.setPlainTextBody(bodyTxt);
    			
         	    listmail.add(email);
    			
    		}
    	 
   		
   		}
   		
   		if(!listmail.Isempty()){
   			Messaging.SendEmailResult [] results = Messaging.sendEmail(listmail);    
   		}
   	
   }    
    
}