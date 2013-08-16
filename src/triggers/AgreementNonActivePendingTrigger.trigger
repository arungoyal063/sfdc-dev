/**
*********************************************************************************************************************
* Module Name   :  AgreementNonActivePendingTrigger
* Description   :       
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    AgreementsNonActivePendingSendEmail
* Test Class    :  
* Fields        : Opportunity.Name, Account ID, Opportunity ID
* Logic         : Agreement Status = 'Pending Approval', Agreement.Opportunity.Stage = "CLOSED - WON"
* Organization  : Rainmaker Associates LLC
*  
* Revision History:- 
* Version  Date           Author           WO#         Description of Action
* 1.0      07/24/2013     Milligan         1443             Initial Version
*   this email will be sent out to contracts@4centurion.com when Agreement.Status = "Pending Approval", 
* Agreement.Opportunity.Stage = "CLOSED - WON", and the Account associated with that 
* Agreement does not currently have any other associated Agreements where Status = "Active"
*
* This trigger looks to see if the Argeement Opportunity is CLOSED WON. If true gather the Agreement
* and sends the list to Class for processing
* There are two emails sent. 1. Looks for Active Agreements for the Account other that the one in Trigger
*2. Looks for Active Agreements and where the Product is OAN
*******************************************************************************************************************
**/
trigger AgreementNonActivePendingTrigger on Agreements__c (after update, after insert) {

	Set<String> oppIds = new Set<String>();
	Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
	
	//for email 1 Agreements the have Opp CLOSED WON
	List<String> agreeIds = new List<String>();
	//for email 2 Agreements the have Opp CLOSED WON
	List<String> agreeOANIds = new List<String>();

	AgreementsNonActivePendingSendEmail em = new AgreementsNonActivePendingSendEmail();

	for(Agreements__c ag: Trigger.New) 
	{
		oppIds.add(ag.opportunity__c);
		System.debug('PendingSendEmail - Agreement Opportunity ---> ' + ag.opportunity__c);
		
	}
    //Gather Opportunities with status = 'closed Won'
	oppMap = new Map<id,Opportunity>([SELECT id, StageName FROM Opportunity WHERE StageName = 'CLOSED - WON' AND id IN : oppIds]);

	for(Agreements__c a: Trigger.New) 
	{
		if(Trigger.isUpdate) 
		{
			Agreements__c ac = Trigger.oldMap.get(a.id);
			System.debug('PendingSendEmail - Agreement Current Status ---> ' + a.Agreement_Status__c + '  -- Old Status -- ' + ac.Agreement_Status__c );
		
			if(ac.Agreement_Status__c <> 'Pending Approval' && a.Agreement_Status__c == 'Pending Approval') 
			{
		 		if(a.Opportunity__c <> null)
					if(oppMap.containsKey(a.Opportunity__c))
					{
						//if this Agreement has a closed won opportunity add to list
						//class will later retrieve all Agreements for Account  to check other Agreements status = 'Active'
						System.debug('PendingSendEmail - Adding Agreement ---> ' + a.id);
						agreeIds.add(a.id);
						
						// email 2
						if(a.product__c == 'OAN')
							agreeOANIds.add(a.id);						
					}
			} else
			{
				System.debug('PendingSendEmail - Does not qualify! ---> ');
			}
		
		}  //isUpdate
		
		if(Trigger.isInsert) 
		{
			System.debug('PendingSendEmail - Agreement Status ---> ' + a.Agreement_Status__c);
			
			if( a.Agreement_Status__c == 'Pending Approval') 
			{
				if(a.Opportunity__c <> null)
					if(oppMap.containsKey(a.Opportunity__c))
					{
						System.debug('PendingSendEmail - Adding Agreement ---> ' + a.id);
						// email 1
						agreeIds.add(a.id);
						// email 2
						if(a.product__c == 'OAN')
							agreeOANIds.add(a.id);

					}
			
			}
		
		} //isInsert	
	}
	
	//Call the class to send email 1
	if(!agreeIds.IsEmpty())
	{
		System.debug('PendingSendEmail - Number of Agreements sending to calls for email 1 creation --> ' + agreeIds.size());
		em.execute(agreeIds);
	}
	
	//Call the class to send email 2
	if(!agreeOANIds.IsEmpty())
	{
		System.debug('PendingSendEmail - Number of Agreements sending to calls for email 2 creation --> ' + agreeOANIds.size());
		em.stageOanMail(agreeOANIds);
	}	
}