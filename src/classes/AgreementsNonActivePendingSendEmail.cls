/**
*********************************************************************************************************************
* Module Name   :  AgreementsNonActivePendingSendEmail
* Description   :       
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    AgreementNonActivePendingTrigger
* Test Class    :  
* Fields        : Opportunity.Name, Account ID, Opportunity ID
* Logic         : Agreement Status = 'Pending Approval', Agreement.Opportunity.Stage = "CLOSED - WON"
* Organization  : Rainmaker Associates LLC
*  
* Revision History:- 
* Version  Date           Author           WO#         Description of Action
* 1.0      07/24/2013     Milligan         1443             Initial Version
* Email 1:  
* this email will be sent out to contracts@4centurion.com when Agreement.Status = "Pending Approval", 
* Agreement.Opportunity.Stage = "CLOSED - WON", and the Account associated with that 
* Agreement does not currently have any other associated Agreements where Status = "Active"
* ??  what if no other agreement exist should email be sent
* Email 2:
* If the agreement that is "Pending Approval" also has Product = "OAN" and the related Account does not have 
* any agreements where Status = "Active" and Product = "OAN", send the alert that OAN has been sold,
*******************************************************************************************************************
**/
public class AgreementsNonActivePendingSendEmail {
	
	List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
	List<Messaging.SingleEmailMessage> listmailOAN = new List<Messaging.SingleEmailMessage>();
	
	public void execute(List<String> aIds){				
		// for email 1
		List<Agreements__c> agreeList = new List<Agreements__c>();
		
		Set<String> acctIds = new Set<String>();		
		Map<id, Account> acctMap = new Map<id, Account>();
		
		// this is the list of Agreements the have Opp CLOSED WON in Trigger. These are only field needed to send email
		agreeList = [SELECT id, name, account_name__c, Opportunity__c, Opportunity__r.name, Account_Name__r.Name  FROM Agreements__c WHERE id IN: aIds];
		
		System.debug('Send1Email execute: Number of agreements --> '  + agreeList.size());
		 
		for(Agreements__c a: agreeList){
			acctIds.add(a.account_name__c);		
		}
		
		// gather all the account agreements where status is active  		
		if(!acctIds.IsEmpty()){
			acctMap = new Map<id, Account>([SELECT id, name,Owner.Email, (SELECT id, Agreement_Status__c  FROM Agreements__r WHERE Agreement_Status__c = 'Active') FROM Account WHERE id IN :acctIds]);
		}
		
		if(!acctMap.IsEmpty()){
			System.debug('Send1Email execute: Number of Accounts In Map --> ' +acctMap.size());
 		}		
		
		for(Agreements__c aa: agreeList)
		{
			
			if(acctMap.containsKey(aa.account_name__c))
			{
				Account acct = acctMap.get(aa.account_name__c);
				List<Agreements__c> getList = new List<Agreements__c>();
				
				getList = acct.Agreements__r;
				boolean hasActive = false;
				System.debug('Send1Email execute:  Accounts -->' + acct.Owner.Email);
				if(!getList.IsEmpty())
				{
					System.Debug('Send1Email execute: Account --> ' + aa.name + '  List of Agreements --  ' + getList.size());
					//If Account has Active Agreement then first email requirement satified
					for(Agreements__c ag: getList)
					{
						if(ag.id <> aa.id)
						{
							if(ag.Agreement_Status__c == 'Active')
							{
								hasActive = true;
								break;
							}
						} //if
						
						
					}  //for
				} //if
				
				// add to list
				if(hasActive == false)
				{
					System.debug('Send1Email:  Going to create email -->');
					createMail(aa);
				}
				
			}
		
		} //for
		
		if(!listmail.IsEmpty())
		{
			System.debug('Send1Email execute: Number of emails sending ---> ' + listMail.size());
   			Messaging.SendEmailResult [] results = Messaging.sendEmail(listmail);    
			
		}
	} // execute
	
	public void createMail(Agreements__c a)
	{ 
    	String acctRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.account_name__c;
    	String oppRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Opportunity__c;
    			
    	String subjectTxt = 'Net New Business – ' + a.Opportunity__r.name;
		String bodyTxt = '\n A new Opportunity for ' +   a.Account_Name__r.Name + ' has been marked as CLOSED - WON. Please click on the link to update the record status and add a Client Account Manager. '  + acctRecordURL + '\n\n Please note that any pertinent accounting or customer service information is located within the Opportunity record:  ' + oppRecordURL;
    			
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String> ();
        toAddresses.add('contracts@4centurion.com');  
        //toAddresses.add('smilligan@rainmaker-llc.com');  
            
       	 email.setSubject(subjectTxt);
         email.setToAddresses( toAddresses );        		    			
    	 email.setPlainTextBody(bodyTxt);
		 System.debug('Send1Email createMail:    -->');
    			
         listmail.add(email);		
	}
	
	
	
	
	
	public void stageOanMail(List<String> aIds){				
		
		//for email 2
		List<Agreements__c> agreeList = new List<Agreements__c>();
		AccountTeamMember teamMember = new AccountTeamMember();
		
		Set<String> acctIds = new Set<String>();		
		Map<id, Account> acctMap = new Map<id, Account>();
		
		// this is the list of Agreements the have Opp CLOSED WON in Trigger. These are only field needed to send email
		agreeList = [SELECT id, name, account_name__c, Opportunity__c, Opportunity__r.name, Account_Name__r.Name ,Product__c FROM Agreements__c WHERE id IN: aIds];
		
		System.debug('Send2Email stageOanMail Number of agreements --> '  + agreeList.size());
		
		//gather all the account id
		for(Agreements__c a: agreeList){
			acctIds.add(a.account_name__c);		
		}
		// gather all the account agreements where status is active and productc is OAN and team members where role is client account
		if(!acctIds.IsEmpty()){
			acctMap = new Map<id, Account>([SELECT id, name, (SELECT User.email, TeamMemberRole From AccountTeamMembers WHERE TeamMemberRole = 'Client Account Manager' ) ,(SELECT id, Agreement_Status__c, Product__c  FROM Agreements__r WHERE Agreement_Status__c = 'Active' and Product__c = 'OAN') FROM Account WHERE id IN :acctIds]);
		}
		
		if(!acctMap.IsEmpty()){
			System.debug('Send2Email stageOanMail Number of Accounts In Map --> ' +acctMap.size());
 		}		
		
		// trigger list of agreements where opp is closed won
		for(Agreements__c aa: agreeList)
		{
			
			if(acctMap.containsKey(aa.account_name__c))
			{
				//find account in map
				Account acct = acctMap.get(aa.account_name__c);
				
				//get the agreements
				List<Agreements__c> getList = new List<Agreements__c>();
				getList = acct.Agreements__r;
				
				//get the AccountTeamMembers
				List<AccountTeamMember> getTeamList = new List<AccountTeamMember>();
				getTeamList = acct.AccountTeamMembers;	
				
				if(!getTeamList.IsEmpty())	
				{
					teamMember = getTeamList.get(0);
					System.debug('Send2Email Found Team Member -- ' + teamMember.user.email);
					
				} else
				{
					System.debug('Send2Email- No Team Member!!');
					
				}		
				
				boolean hasActive = false;
				
				if(!getList.IsEmpty())
				{
					System.Debug('Send2Email Account --> ' + aa.name + '  List of Agreements --  ' + getList.size());
					//If Account has Active Agreement then first email requirement satified
					for(Agreements__c ag: getList)
					{
						//if its not the Agreement in the Trigger
						if(ag.id <> aa.id)
						{
							if(ag.Agreement_Status__c == 'Active' && ag.Product__c == 'OAN')
							{
								hasActive = true;
								break;
							}

						} //if
					} //for
				} //if
				
				
				if(hasActive == false)	
				{							
					System.debug('Send2Email found another active/oan agreeement');
								
					// add to list
					if(teamMember <> null)
					{
						createOANMail(aa);
					}				
				}
			}
		
		} //for
		
		if(!listmailOAN.IsEmpty())
		{
			System.debug('SendEmail stageOanMail Number of listmailOAN sending ---> ' + listmailOAN.size());
   			Messaging.SendEmailResult [] results = Messaging.sendEmail(listmailOAN);    
			
		}
	} // executeOAN	
		
	
	public void createOANMail(Agreements__c a)
	{ 
    	String acctRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.account_name__c;
    	String oppRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Opportunity__c;
    			
    	String subjectTxt = 'OAN SOLD – ' + a.Opportunity__r.name;
		String bodyTxt = '\n A new Opportunity for ' + a.Account_Name__r.Name + ' has been marked as CLOSED - WON. Please click on the link to update the record status and add a Client Account Manager. '  + acctRecordURL + '\n\n Please note that any pertinent accounting or customer service information is located within the Opportunity record:  ' + oppRecordURL;
    			
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String> ();
        		
        //toAddresses.add(emailAddress);
         toAddresses.add('contracts@4centurion.com');
                 
         // email "contracts@4centurion.com".		  
         //email.setTargetObjectId(atm.UserId);
         //email.setSaveAsActivity(false); 
                
       	 email.setSubject(subjectTxt);
         email.setToAddresses( toAddresses );        		    			
    	 email.setPlainTextBody(bodyTxt);
    			
         listmailOAN.add(email);		
	}	
	
	
}