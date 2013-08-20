public with sharing class OpptyLineItemEditController {
	
	public OpportunityLineItem oli {get;set;}
	public List<Selectoption> colorDescOptions {get;set;}
	public String prodCode {get;set;}
	public String productName {get;set;}
	private String priceBookId = '';
	public Boolean isCustomProduct {get;set;}
	
	public OpptyLineItemEditController(Apexpages.StandardController sc) {
		oli = (OpportunityLineItem)sc.getRecord();
		colorDescOptions = new List<Selectoption>();
		isCustomProduct = false;
		List<OpportunityLineItem> optyLineItemList = [Select o.Unit_of_Measure__c, o.UnitPrice, o.TotalPrice, o.Style_Description__c, o.SortOrder, 
														o.Size__c, o.Opportunity.Name, 
														o.Sidemark__c, o.ServiceDate, o.Quantity, o.Product_Category__c, o.PricebookEntryId, 
														o.OpportunityId, o.ListPrice, o.Id, o.Description, o.Color_Description__c, o.Bk__c, 
														o.PricebookEntry.Product2Id, o.PricebookEntry.Product2.Name, o.PricebookEntry.UnitPrice, 
														o.PricebookEntry.Product2.ProductCode From OpportunityLineItem o Where o.Id =: oli.Id];
		if(optyLineItemList != null && optyLineItemList.size() > 0) {
			oli = optyLineItemList[0];
			AggregateResult[] productList = [select Product2.Color_Description__c colorDesc From PricebookEntry Where IsActive = true 
												and (Product2.Product_Category__c =: oli.Product_Category__c 
												AND Product2.Style_Description__c =: oli.Style_Description__c 
												AND Product2.Bk__c =: oli.Bk__c and Product2.size__c =: oli.Size__c 
												AND Product2.Unit_of_Measurement__c =: oli.Unit_of_Measure__c AND Product2.IsActive = true) 
												and Product2.Color_Description__c != null GROUP BY Product2.Color_Description__c 
												ORDER BY Product2.Color_Description__c];
			colorDescOptions.add(new Selectoption('', '--TBD--'));
			for(AggregateResult ar : productList) {
                String colorDesc = String.valueOf(ar.get('colorDesc'));
                colorDescOptions.add(new Selectoption(colorDesc, colorDesc));
            }
            productName = oli.PricebookEntry.Product2.Name;
            priceBookId = oli.PricebookEntryId;
            if(oli.PricebookEntry.Product2.ProductCode != null) {
            	prodCode = oli.PricebookEntry.Product2.ProductCode;
            }
            if(oli.Color_Description__c == null || oli.Color_Description__c == '') {
            	isCustomProduct = true;
            }
		}
	}
	
	public void fetchProductCode() {
		if(oli.Color_Description__c != null && oli.Color_Description__c != '') {
			List<PricebookEntry> productPEList = [select Id, Product2Id, Product2.ProductCode, Product2.Name From PricebookEntry Where IsActive = true 
													and (Product2.Product_Category__c =: oli.Product_Category__c 
													AND Product2.Style_Description__c =: oli.Style_Description__c 
													AND Product2.Bk__c =: oli.Bk__c and Product2.size__c =: oli.Size__c 
													AND Product2.Color_Description__c =: oli.Color_Description__c 
													AND Product2.Unit_of_Measurement__c =: oli.Unit_of_Measure__c AND Product2.IsActive = true)];
			if(productPEList != null && productPEList.size() > 0) {
				productName = productPEList[0].Product2.Name;
				prodCode = productPEList[0].Product2.ProductCode;
				priceBookId = productPEList[0].Id;
				System.debug('log: '+productName + ' :: ' + prodCode + ' :: ' + priceBookId);
			}
		} else {
			productName = oli.PricebookEntry.Product2.Name;
			prodCode = '';
			priceBookId = oli.PricebookEntryId;
		}
	}
	
	public Pagereference saveOLI() {
		PageReference p;
		OpportunityLineItem o = new OpportunityLineItem();
		String hostName = Apexpages.currentPage().getHeaders().get('Host');
	    String returnUrl = 'https://' + hostName + '/' + oli.Id ;
		/*if(priceBookId != null && priceBookId != '') {
			oli.PricebookEntryId = priceBookId;
		}*/
		Boolean createOli = false;
		if(isCustomProduct && oli.PricebookEntryId != priceBookId) {
			createOli = true;
			o.Unit_of_Measure__c = oli.Unit_of_Measure__c;
			o.UnitPrice = oli.UnitPrice;
			o.Style_Description__c = oli.Style_Description__c;
			o.Size__c = oli.Size__c;
			o.Sidemark__c = oli.Sidemark__c;
			o.ServiceDate = oli.ServiceDate;
			o.Quantity = oli.Quantity;
			o.PricebookEntryId = priceBookId;
			o.OpportunityId = oli.OpportunityId;
			o.Description = oli.Description;
			o.Color_Description__c = oli.Color_Description__c;
			o.Bk__c = oli.Bk__c;
		}
		try {
			if(createOli) {
				delete oli;
				insert o;
				returnUrl = 'https://' + hostName + '/' + o.Id ;
			} else {
				update oli;
				returnUrl = 'https://' + hostName + '/' + oli.Id ;
			}
	        p = new PageReference(returnUrl);
	        p.setRedirect(true);
		} catch(Exception ex) {
			System.debug('error msg: '+ ex.getMessage() + ' at line number ' + ex.getLineNumber().format());
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + ' at line number ' + ex.getLineNumber().format());
            ApexPages.addMessage(msg);
			p = null;
		}
		return p;
	}
}