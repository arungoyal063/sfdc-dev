/*********************************************************************************************************************
* Module Name   :  ContentManagementService Class
* Description   :  This Class is Used for process Trigger requests
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : TestAgentContributionArticleController
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      12/02/2013      bmatthews     Ellucian    Initial Version
*******************************************************************************************************************/
public with sharing class ContentManagementService{
	
	public static void applyFormulas(ContentVersion[] items) {
		
		set<Id> theIds = new set<id>();
	   	for (ContentVersion item :items){
			if (item.product__c != null){
			  	theIds.add(item.product__c);
			}
	   	}
		
		if(theIds.size() > 0){
			//get the associated products
			List<Product2> products = [SELECT Id, Parent_Product__c, Name, Parent_Product__r.Name,
                   Product_Line__c, Parent_Product__r.Product_Line__c 
                   FROM Product2 WHERE Id IN :theIds];
			
			//create the map
			Map<ID, Product2> productMap = new Map<ID, Product2>();
			for(Product2 product : products)
			{
			    productMap.put(product.id, product);
			}
			
			System.debug('********** Map: ' + productMap);
			
			//process the items
			for (ContentVersion item :items){
				if (item.product__c != null){
				  
					try{
						
					if(productmap.containsKey(item.Product__c)){
						
					//Set the product line field
					if(productMap.get(item.product__c).Parent_Product__c == null){ 
						if(productMap.get(item.product__c).Product_Line__c != null){
							item.ProductLine__c = productMap.get(item.product__c).Product_Line__c;
						}
				  	}else{
						if(productMap.get(item.product__c).Parent_Product__r.Product_Line__c != null){
					  		item.ProductLine__c = productMap.get(item.product__c).Parent_Product__r.Product_Line__c;
						}
				  	}
					
					//Set the product name field
			  		if(productMap.get(item.product__c).Parent_Product__c == null){
						if(productMap.get(item.product__c).Name != null){
				  			item.ProductName__c = productMap.get(item.product__c).Name;
						}
			  		}else{
						if(productMap.get(item.product__c).Parent_Product__r.Name != null){
				  			item.ProductName__c = productMap.get(item.product__c).Parent_Product__r.Name;
						}
			  		}
					
					//Set the module line
				  	if(productMap.get(item.product__c).Parent_Product__c != null){
						if(productMap.get(item.product__c).Name != null){
							item.Module__c = productMap.get(item.product__c).Name ;
						}
				  	}else{}
					
					}
					}catch(Exception ex){}
				}
		   	}
		}
	} 

}