/**
*********************************************************************************************************************
* Module Name   :  AgreementCreateOppProduct
* Description   :    
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :   UpdateAgreeRenewalOpp
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      05/30/2013      Milligan        1343             Initial Version
* 1.1	   06/28/2013	   Justin Padilla	1418		*Updated the Trigger so it fires when Agreement Status = 'Active' and Changed 
*														Renewal Opportunity Naming Convention to: 
*														[Account Name]-[Product]-Renewal_[Close Date Year] 
*   
*******************************************************************************************************************
**/
trigger AgreementCreateOppProduct on Agreements__c (after update, after insert) {
	//1343 UpdateAgreeRenewalOpp
	List<String> oppIDs = new List<String>();
	List<RecordType> rt = new List<RecordType>();
	
	List<Opportunity> oppList = new List<Opportunity>(); 
	Map<id, Opportunity> oppMap = new Map<id,Opportunity>(); 
	List< AccountTeamMember> acctTeamList = new List<AccountTeamMember>(); 
	
	Map<id, Account> acctMap = new Map<id,Account>(); 
	
	Set<String> acctIds = new Set<String>(); 
	
		
	for(Agreements__c a: Trigger.New){
	
	
		if(Trigger.isUpdate){
		
			System.debug('C--> Agreement Status ---> ' + a.Agreement_Status__c);
	
			Agreements__c ac = Trigger.oldMap.get(a.id);
		
		
			if(ac.Agreement_Status__c <> 'Active' && a.Agreement_Status__c == 'Active'){
			
				if(a.Opportunity__c <> null)
					oppIDs.add(a.Opportunity__c);
			
			}
		
		}
		
		if(Trigger.isInsert){
		
			System.debug('C--> Agreement Status ---> ' + a.Agreement_Status__c);
			
			if( a.Agreement_Status__c == 'Active'){
			
				if(a.Opportunity__c <> null)
				
					System.debug('C--> Adding Opportunity ---> ' + a.Opportunity__c);
					oppIDs.add(a.Opportunity__c);
			
			}
		
		}		
		
	}
	
	if(!oppIDs.IsEmpty()){
		//Get Opportunity Data
		oppMap = new Map<id,Opportunity>([SELECT id, accountId,Account.Name, name, Originating_Agreement__c FROM Opportunity WHERE id IN: oppIDs]);
		
		if(!oppMap.IsEmpty()){
			
			for(Opportunity o: oppMap.values()){
				
				acctIds.add(o.AccountId);
				
			}
			
			if(!acctIds.IsEmpty()){
				//Get Account Team Member Role info
			//	acctTeamList = [SELECT AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE teamMemberRole = 'biNOW Account Manager' AND accountID IN:acctIds];
				acctTeamList = [SELECT AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE teamMemberRole = 'Client Account Manager' AND accountID IN:acctIds];
			}
			 			
			for(Agreements__c a: Trigger.New){
				
				RecordType rt1 = new RecordType();
				rt = [SELECT SobjectType, Name, IsActive, Id FROM RecordType  WHERE name = 'Renewal (biNOW/OAN)'];
				
				if(!rt.IsEmpty()){
					rt1 = rt[0];
				}
				
				if(oppMap.containsKey(a.Opportunity__c)){
					
					Opportunity agreeOpp = oppMap.get(a.Opportunity__c);
					String acctOwner = 'None';
					Id acctID = null;
					
					
					for(AccountTeamMember atm: acctTeamList){
						if(atm.AccountId == agreeOpp.accountId)
							acctOwner = atm.UserID;
							acctID = atm.UserID;
					}

					Opportunity o = new Opportunity();
			 		o.RecordTypeId = rt1.id;
			 		o.StageName = 'Pending Renewal';
			 		o.type = 'Renewal';
			 		o.AccountId = agreeOpp.AccountId;
			 		
			 		//is the id available before insert??????
			 		o.Originating_Agreement__c = a.Id;
			 		
			 		if(acctOwner <> 'None')
			 			o.OwnerId = acctOwner;
			 		
			 		if(a.Subscription_End_Date__c <> null)
			 			o.CloseDate = a.Subscription_End_Date__c - 60;
			 		else
			 			o.CloseDate = System.today() + 30;
			 		//maybe o.ForecastCategory =
					
					Integer cYear = o.CloseDate.year();
					
					if((agreeOpp.name <> null && agreeOpp.name <> '') && (a.Product__c <> null && a.Product__c <> '') )
			 			//o.name = agreeOpp.name + '-' + a.Product__c + '- Renewal ' + String.valueOf(cYear);
			 			o.Name = agreeOpp.Account.Name+'-'+a.Product__c+'-Renewal_'+String.valueOf(cYear);
			 		else
			 			o.name = a.name;
			 		
			 		o.CreateByObject__c = 'Agreement';
 			 		oppList.add(o);
 			 		System.debug('Created Opportunity ---> ' + o.name);
				}						
			}		
			
		}
	}
	
	if(!oppList.IsEmpty())
	{
		insert oppList;
	}

}