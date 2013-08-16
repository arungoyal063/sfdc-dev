/**
*********************************************************************************************************************
* Module Name   :  AgreementCompanyTierUpdate
* Description   :  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      05/30/2013      Milligan         1349             Initial Version
*   
*******************************************************************************************************************
**/
trigger AgreementCompanyTierUpdate on Agreements__c (after update, after insert) {
	//WO1349
	List<String> oppIDs = new List<String>();	
	List<Opportunity> oppList = new List<Opportunity>();
	
	List<String> acctIDs = new List<String>();		 
	Map<id, Opportunity> oppMap = new Map<id,Opportunity>(); 	
	
	List<Agreements__c> agreeList = new List<Agreements__c>();
	Map<id, Decimal> acctMap = new Map<id, Decimal>(); 	
	
	List<Account> acctList = new List<Account>();	
	
	for(Agreements__c a: Trigger.new){
		
		if(a.Agreement_Status__c == 'Active' && a.Product__c == 'biNOW'){			
			//get the accounts associated with Agreement
			if(a.Account_Name__c <> null){
				System.debug('Trigger Acct -->' + a.Account_Name__c);
				acctIDs.add(a.Account_Name__c);
			}		
		}
	}
	//a.Final_Subscription_Value__c, a.Annual_Value__c
	// get all the agreements for the account that fit the criteria
	agreeList = [SELECT id, Subscription_Start_Date__c, Account_Name__c, Final_Subscription_Value__c, Annual_Value__c, Closed_On__c 
				 FROM agreements__c WHERE agreement_Status__c = 'Active' AND Closed_On__c <> null AND Account_Name__c IN: acctIDs];
	
	// get the list of accounts for agreement			 
	acctList = [SELECT id, Company_Tier__c, name  FROM Account WHERE id IN: acctIDs];
				 
	if(!agreeList.IsEmpty()){
		
		System.debug('agree List -->' + agreeList.size());
		
		for(Account a: acctList){		
				
			Date maxDate = null;
			Agreements__c maxAgree = new Agreements__c();
			
			//for each acct loop through the agreements for acct to get latest one
			for(Agreements__c al: agreeList){
				
				if(a.id == al.Account_Name__c){
					
					if(maxDate == null){
						maxDate = al.Closed_On__c;
						maxAgree = al;
					}else{
						if(al.Closed_On__c > maxDate){
							maxDate = al.Closed_On__c;
							maxAgree = al;
						}
					}
				}	//if		 
			
			} //for 
			
 			
			if(maxAgree <> null){
				
				System.debug('Max Account ID -->' +  a.id + ' Max Date -->' + maxAgree.Closed_On__c + ' Value -->' + maxAgree.Annual_Value__c);
				
				//acctMap.put(maxAgree.Account_Name__c, maxAgree.Annual_Value__c);
				
				if(maxAgree.Annual_Value__c < 10000)
					a.Company_Tier__c = '3';
				else if (maxAgree.Annual_Value__c > 10000 && maxAgree.Annual_Value__c < 18000 )
					a.Company_Tier__c = '2';
				else if(maxAgree.Annual_Value__c > 18000)
					a.Company_Tier__c = '1';
					
					System.debug('Updating Company Tier -->' + a.Company_Tier__c);
				
			}
			
		}  //for
		
	} //if
	
	if(!acctList.IsEmpty()){
		system.debug('Account List to Update is  size -->' + acctList.size());
		update acctList;
		
	} else {
		system.debug('Account List to Update is NULL -->');
	}
	
}