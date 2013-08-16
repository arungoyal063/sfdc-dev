/**
*********************************************************************************************************************
* Module Name   :  CreateOANOppProdsForAgreement
* Description   :  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    CreateNewOANOppExtension
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      05/30/2013      Milligan         1359             Initial Version
*   
*******************************************************************************************************************
**/ 
trigger CreateOANOppProdsForAgreement on Opportunity (after insert) {
	//WO1359 OAN Button
	List<OpportunityLineItem> oliList = new List<OpportunityLineItem>(); 	
	List<OpportunityLineItem> insertOLiList = new List<OpportunityLineItem>();	
	Map<id, Agreements__c> aMap = new Map<id, Agreements__c>();
	
	Set<String> agreeIds = new Set<String>();
	
	for(Opportunity o: Trigger.New){
		if(o.CreateByObject__c == 'AgreeBtn'){
			agreeIds.add(o.Originating_Agreement__c);
		}
		 
	}	
	 
	//find agreement for this opportunity
	aMap = new Map<id, Agreements__c>([SELECT id, Opportunity__c, Annual_Value__c FROM Agreements__c WHERE id IN: agreeIds]);
		
	for(Opportunity o: Trigger.New){
		
		if(o.CreateByObject__c == 'AgreeBtn'){
			
			if(aMap.containsKey(o.Originating_Agreement__c)){
			     
				Agreements__c ag1 = aMap.get(o.Originating_Agreement__c);
				OpportunityLineItem newOli = new OpportunityLineItem();
								
				newOli.PricebookEntryId = '01uA0000009uF8RIAU';
				newOli.OpportunityId = o.Id;	
				newOli.Quantity = 1;
				newOli.UnitPrice = ag1.Annual_Value__c;
				
				
				 if(ag1.Annual_Value__c <> null)
					insertOLiList.add(newOli);	
			}
		}
		
		if(!insertOliList.IsEmpty()){
			insert insertOLiList;
		}
		
		 
	}
	
	
}