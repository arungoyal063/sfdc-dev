/**
*********************************************************************************************************************
* Module Name   :  CreateOppProdsForAgreement
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
* 1.1		06/28/2013		Justin Padilla	1418		When a renewal opportunity is created, check it's products against Won Closed Renewals products and set
														Initial Renewal to true if all products are not found on a previously Closed Won Renewal Opp  
*******************************************************************************************************************
**/
trigger CreateOppProdsForAgreement on Opportunity (before insert, after insert) {
	//1343 AgreementCreateOppProduct
	Set<String> agreeIds = new Set<String>();
	Set<String> oppIds = new Set<String>();
	
	List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
	List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
	Map<id, Agreements__c> aMap = new Map<id, Agreements__c>();
	
	List<OpportunityLineItem> insertOLiList = new List<OpportunityLineItem>();
	List<OpportunityContactRole> insertCRList = new List<OpportunityContactRole>();
	
	List<Agreements__c> agreeUpdList = new List<Agreements__c>();

	for(Opportunity o: Trigger.New){
		if(o.CreateByObject__c == 'Agreement'){
			agreeIds.add(o.Originating_Agreement__c);
		}
		 
	}
	//find agreement for this opportunity
	aMap = new Map<id, Agreements__c>([SELECT id, Opportunity__c,Subscription_Type__c, Renewal__c, Price_List_Item__c, Annual_Value__c FROM Agreements__c WHERE id IN: agreeIds]);
	
	if(!aMap.IsEmpty()){
		
		System.debug('Found Agreements for Opportunity Created Array size -->' + aMap.size());
		
		for(Agreements__c a: aMap.values()){
			oppIds.add(a.Opportunity__c);
		}
		
		//find opplineItems for agreement opp
		if(!oppIds.IsEmpty()){
			
			Map<id, OpportunityLineItem> oliMap = new Map<id, OpportunityLineItem>(); 
		
			oliList = [SELECT Id,PricebookEntryId, PricebookEntry.Pricebook2Id,PricebookEntry.Product2Id,PricebookEntry.Name, OpportunityId From OpportunityLineItem 
 						WHERE PricebookEntry.Name IN ('Business Intelligence NOW - (biNOW)', 'Opportunity Assessment NOW - (OAN)') AND OpportunityId IN: oppIDs];
 			                                        
 			contactRoleList = [Select Role, OpportunityId, IsPrimary, Id, ContactId FROM OpportunityContactRole WHERE OpportunityId IN: oppIds];
			
			if(!oliList.IsEmpty()){
				
				System.debug('Found Opportunity Line Items Product For Originating Agreement Opp Size -->' + oliList.size());
				
				for(OpportunityLineItem ol: oliList){
				
					oliMap.put(ol.OpportunityId, ol);
					System.debug('Opportunity ID -->' + ol.OpportunityId + ' Pricebook Name -->' + ol.PricebookEntry.Name);
				}				
				 
				for(Opportunity o: Trigger.New){
					
					if(aMap.containsKey(o.Originating_Agreement__c)){
						
						//Create a Set of ProductId's for Closed Won Renewal Opporunities
						Map<Id,OpportunityLineItem> relatedRenewalClosedWon = new Map<Id,OpportunityLineItem>([SELECT OpportunityLineItem.id,OpportunityLineItem.PricebookEntryId,OpportunityLineItem.PricebookEntry.Product2Id FROM OpportunityLineItem WHERE OpportunityLineItem.Opportunity.type = 'Renewal' AND OpportunityLineItem.Opportunity.StageName ='CLOSED - WON' AND OpportunityLineItem.Opportunity.AccountId =: o.AccountId]);
						Set<Id> relatedRenewalOpportunityProductIds = new Set<Id>();
						for (OpportunityLineItem oli:relatedRenewalClosedWon.values())
						{
							if (!relatedRenewalOpportunityProductIds.contains(oli.PricebookEntry.Product2Id))
								relatedRenewalOpportunityProductIds.add(oli.PricebookEntry.Product2Id);
						}
						if (trigger.isBefore)
							o.Initial_Renewal__c = true; //Set initial renewal to True, if a product is found it will set to false
						
						Agreements__c ag = aMap.get(o.Originating_Agreement__c);
						
						ag.Renewal_Opportunity__c = o.id;
						agreeUpdList.add(ag);
						
						for(OpportunityLineItem ol: oliList){
							
							System.debug('CreateOppProd -->  Opp Line Item Opp ID -->' + ol.OpportunityId + ' Agree Opp ID -->' + ag.Opportunity__c );
							if(ol.OpportunityId == ag.Opportunity__c){
								
								if (trigger.isBefore && relatedRenewalOpportunityProductIds.contains(ol.PricebookEntry.Product2Id))
									o.Initial_Renewal__c = false;
									
								OpportunityLineItem newOli = new OpportunityLineItem();
								
								newOli.PricebookEntryId = ol.PricebookEntryId;
								newOli.OpportunityId = o.Id;
								
								//remove
								System.debug('CreateOppProd Renewal --' + ag.Renewal__c + ' Annual -->' + ag.Annual_Value__c + ' Price List Item --> + ag.Price_List_Item__c');
								
								if(ag.Renewal__c == 'Yes'){
 									if(ag.Annual_Value__c <> null)
										newOli.UnitPrice = ag.Annual_Value__c * 1.05;
								}else if (ag.Renewal__c == 'No'){
									
									if(ag.Price_List_Item__c <> null){
										
 										String priceItem = ag.Price_List_Item__c.replace(',','');
 										System.debug('Price_List_Item__c --->' + ag.Price_List_Item__c);
 									
										boolean isNums = priceItem.isNumeric();
									
										newOli.UnitPrice = Integer.valueOf(priceItem) * 1.05;
 									
 										System.debug('priceItem --->' + priceItem + ' IsNums -->' + isNums);
									}	
								}
								
								boolean createOpp = true;
								
								if(ag.Subscription_Type__c == '1 Year'){
									newOli.Quantity = 1;
								}else if(ag.Subscription_Type__c == '2 Year'){
									newOli.Quantity = 2;
								}else if(ag.Subscription_Type__c == '3 Year'){
									newOli.Quantity = 3;
								}else{
									createOpp = false;
								}
								
								if(newOli.UnitPrice == null) createOpp = false;
								
								System.debug('Total Quantity --->' + newOli.Quantity + ' Unit --> ' + newOli.UnitPrice + ' Type --> ' +ag.Subscription_Type__c );
								
								if(createOpp){
									System.debug('Total Quantity --->' + newOli.Quantity + ' Unit -->' + newOli.UnitPrice);
									//newOli.TotalPrice = newOli.Quantity * 	newOli.UnitPrice;					
									insertOLiList.add(newOli);
								}		
								
								
							}   
												
						} //for
						
 
						for(OpportunityContactRole cr: contactRoleList){
							
							if(cr.OpportunityId == ag.Opportunity__c){
								OpportunityContactRole newCr = new OpportunityContactRole();
								newCr.OpportunityId = o.Id;
								newCr.ContactId = cr.ContactId;
								newCr.Role = cr.Role;
								newCr.IsPrimary = cr.IsPrimary;
								
								insertCRList.add(newCr);
							}
					
						} //for						
						
					
					} //if aMap			
					 					
				}  //for opp
				
			}	 //if oli
			
		}
		

	} //aMap
	if (trigger.isAfter)
	{
		if(!insertOLiList.IsEmpty()){
			insert insertOLiList;
		}
		if(!insertCRList.IsEmpty()){
			insert insertCRList;
		}
	}
	
}