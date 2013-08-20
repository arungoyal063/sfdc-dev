public with sharing class QuoteLineItemEditController {
	
	public QuoteLineItem qli {get;set;}
	public List<Selectoption> colorDescOptions {get;set;}
	public String prodCode {get;set;}
	public String productName {get;set;}
	private String priceBookId = '';
	public Boolean isCustomProduct {get;set;}
	
	public QuoteLineItemEditController(Apexpages.StandardController sc) {
		qli = (QuoteLineItem)sc.getRecord();
		colorDescOptions = new List<Selectoption>();
		isCustomProduct = false;
		List<QuoteLineItem> quoteLineItemList = [Select q.Id, q.Unit_of_Measure__c, q.UnitPrice, q.TotalPrice, q.Subtotal, q.Style_Description__c, 
													q.Size__c, q.Sidemark__c, q.ServiceDate, q.QuoteId, q.Quantity, q.Product_Category__c, 
													q.PricebookEntryId, q.PriceDiff__c, q.ListPrice, q.LineNumber, q.Discount, q.Description, 
													q.CreatedById, q.Color_Description__c, q.Bk__c, q.Quote.Name, q.PricebookEntry.Product2Id, 
													q.PricebookEntry.Product2.Name, q.PricebookEntry.UnitPrice, q.PricebookEntry.Product2.ProductCode
													From QuoteLineItem q Where q.Id =: qli.Id];
		if(quoteLineItemList != null && quoteLineItemList.size() > 0) {
			qli = quoteLineItemList[0];
			AggregateResult[] productList = [select Product2.Color_Description__c colorDesc From PricebookEntry Where IsActive = true 
												and (Product2.Product_Category__c =: qli.Product_Category__c 
												AND Product2.Style_Description__c =: qli.Style_Description__c 
												AND Product2.Bk__c =: qli.Bk__c and Product2.size__c =: qli.Size__c 
												AND Product2.Unit_of_Measurement__c =: qli.Unit_of_Measure__c AND Product2.IsActive = true) 
												and Product2.Color_Description__c != null GROUP BY Product2.Color_Description__c 
												ORDER BY Product2.Color_Description__c];
			colorDescOptions.add(new Selectoption('', '--TBD--'));
			for(AggregateResult ar : productList) {
                String colorDesc = String.valueOf(ar.get('colorDesc'));
                colorDescOptions.add(new Selectoption(colorDesc, colorDesc));
            }
            productName = qli.PricebookEntry.Product2.Name;
            priceBookId = qli.PricebookEntryId;
            if(qli.PricebookEntry.Product2.ProductCode != null) {
            	prodCode = qli.PricebookEntry.Product2.ProductCode;
            }
            if(qli.Color_Description__c == null || qli.Color_Description__c == '') {
            	isCustomProduct = true;
            }
		}
	}
	
	public void fetchProductCode() {
		if(qli.Color_Description__c != null && qli.Color_Description__c != '') {
			List<PricebookEntry> productPEList = [select Id, Product2Id, Product2.ProductCode, Product2.Name From PricebookEntry Where IsActive = true 
													and (Product2.Product_Category__c =: qli.Product_Category__c 
													AND Product2.Style_Description__c =: qli.Style_Description__c 
													AND Product2.Bk__c =: qli.Bk__c and Product2.size__c =: qli.Size__c 
													AND Product2.Color_Description__c =: qli.Color_Description__c 
													AND Product2.Unit_of_Measurement__c =: qli.Unit_of_Measure__c AND Product2.IsActive = true)];
			if(productPEList != null && productPEList.size() > 0) {
				productName = productPEList[0].Product2.Name;
				prodCode = productPEList[0].Product2.ProductCode;
				priceBookId = productPEList[0].Id;
				System.debug('log: '+productName + ' :: ' + prodCode + ' :: ' + priceBookId);
			}
		} else {
			productName = qli.PricebookEntry.Product2.Name;
			prodCode = '';
			priceBookId = qli.PricebookEntryId;
		}
	}
	
	public Pagereference saveOLI() {
		PageReference p;
		QuoteLineItem q = new QuoteLineItem();
		String hostName = Apexpages.currentPage().getHeaders().get('Host');
	    String returnUrl = 'https://' + hostName + '/' + qli.Id ;
		/*if(priceBookId != null && priceBookId != '') {
			qli.PricebookEntryId = priceBookId;
		}*/
		Boolean createQli = false;
		if(isCustomProduct && qli.PricebookEntryId != priceBookId) {
			createQli = true;
			q.Discount = qli.Discount;
			q.Unit_of_Measure__c = qli.Unit_of_Measure__c;
			q.UnitPrice = qli.UnitPrice;
			q.Style_Description__c = qli.Style_Description__c;
			q.Size__c = qli.Size__c;
			q.Sidemark__c = qli.Sidemark__c;
			q.ServiceDate = qli.ServiceDate;
			q.Quantity = qli.Quantity;
			q.PricebookEntryId = priceBookId;
			q.QuoteId = qli.QuoteId;
			q.Description = qli.Description;
			q.Color_Description__c = qli.Color_Description__c;
			q.Bk__c = qli.Bk__c;
		}
		try {
			if(createQli) {
				delete qli;
				insert q;
				returnUrl = 'https://' + hostName + '/' + q.Id ;
			} else {
				update qli;
				returnUrl = 'https://' + hostName + '/' + qli.Id ;
			}
			//update qli;
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