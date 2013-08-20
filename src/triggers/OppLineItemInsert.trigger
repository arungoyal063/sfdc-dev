/**
*********************************************************************************************************************
* Module Name   :  OppLineItemInsert 
* Description   :  Updates OpportunityLineItem Style_Description__c, bk__c,Color_Description__c with Product2 data on insert
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date        	  Author      	   WO#         Description of Action
* 1.0      03/28/2013     Milligan                 	   Initial Version
*   
*******************************************************************************************************************
**/
trigger OppLineItemInsert on OpportunityLineItem (before insert) {
	List<String> priceBkIds = new List<String>();
 	
	for(OpportunityLineItem ol: Trigger.new){
		priceBkIds.add(ol.PricebookEntryId);			
	}
	  
	if(!priceBkIds.isEmpty()){
		
		Map<Id, PricebookEntry> priceMap = new Map<Id, PricebookEntry>([Select  id, Product2.Style_Description__c,  Product2.Color_Description__c, Product2.Bk__c, Product2.unit_of_measurement__c, Product2.size__c From PricebookEntry  WHERE Id IN :priceBkIds]);
 
 		for(OpportunityLineItem ol: Trigger.new){
 			
			if(priceMap.containskey(ol.PricebookEntryId)){
				PricebookEntry pe = new PricebookEntry();
				pe = priceMap.get(ol.PricebookEntryId);
				if(ol.Style_Description__c == null)
					ol.Style_Description__c = pe.Product2.Style_Description__c;
					
				if(ol.Color_Description__c == null)					
					ol.Color_Description__c = pe.Product2.Color_Description__c;
					
				if(ol.Bk__c == null)					
					ol.Bk__c = pe.Product2.Bk__c;
					
					
				if(ol.Size__c == null)					
					ol.Size__c = pe.Product2.Size__c;	
					
				if(ol.Unit_of_Measure__c == null)					
					ol.Unit_of_Measure__c = pe.Product2.Unit_of_Measurement__c;													
			}
 		}		
		
 	}
}