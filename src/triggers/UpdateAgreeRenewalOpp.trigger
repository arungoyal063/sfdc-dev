/**
*********************************************************************************************************************
* Module Name   :  UpdateAgreeRenewalOpp
* Description   :  U 
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :   AgreementCreateOppProduct
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      05/30/2013      Milligan         1343             Initial Version
*   
*******************************************************************************************************************
**/
trigger UpdateAgreeRenewalOpp on Opportunity (after insert) {
	//1343 AgreementCreateOppProduct
	List<Agreements__c> updAgreeList = new List<Agreements__c>();
	Set<String> agreeIds = new Set<String>();
	Map<id, Agreements__c> aMap = new Map<id, Agreements__c>();
	
	for(Opportunity o: Trigger.New){
		if(o.CreateByObject__c == 'Agreement'){
			agreeIds.add(o.Originating_Agreement__c);
		}
		 
	}
	
	//find agreement for this opportunity
	aMap = new Map<id, Agreements__c>([SELECT id, Opportunity__c,Subscription_Type__c, Renewal__c, Price_List_Item__c, Annual_Value__c FROM Agreements__c WHERE id IN: agreeIds]);
	
	if(!aMap.IsEmpty()){
		
		for(Opportunity o: Trigger.New){
			
			if(o.CreateByObject__c == 'Agreement'){
				
				if(aMap.containsKey(o.Originating_Agreement__c)){
					Agreements__c  ag = aMap.get(o.Originating_Agreement__c);
					ag.Renewal_Opportunity__c = o.id;
					updAgreeList.add(ag);
				}
				
 			}
		 
		}	
	}	
	
	if(!updAgreeList.IsEmpty()){
		update updAgreeList;
	}
			
}