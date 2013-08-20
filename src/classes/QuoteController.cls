public with sharing class QuoteController {
	
	public Quote q {get;set;}
	public Double subTtl {get;set;}
	public String accName {get;set;}
	public String opptyName {get;set;}
	public String addressValues {get;set;}
	
	private String opptyId = '';
	
	public QuoteController(ApexPages.StandardController sc) {
		q = new Quote();
		q = (Quote)sc.getRecord();
		System.debug('q: '+q);
		//oppid
		addressValues = '';
		subTtl = 0.00;
		opptyId = ApexPages.currentPage().getParameters().get('oppid');
		q.OpportunityId = opptyId;
		if(opptyId != '') {
			List<Opportunity> opptyList = [Select Id, Name, AccountId, Account.Name, Amount From Opportunity Where Id =: opptyId];
			if(opptyList != null && opptyList.size() > 0) {
				Opportunity o = opptyList.get(0);
				opptyName = o.Name;
				accName = o.Account.Name;
				subTtl = o.Amount;
				/*Date d = Date.today();
				String oName = o.Name;
				if(oName != null && oName.contains(' - ')) {
					List<String> oNameSplit = oName.split(' - ');
					oName = oNameSplit[0];
				}
				String day = String.valueOf(d.day());
				String month = String.valueOf(d.month());
				String year = String.valueOf(d.year());
				if(day != null && day.length() == 1) day = '0' + day;
				if(month != null && month.length() == 1) month = '0' + month;
				q.Name = oName + ' - ' + o.Account.Name + ' - ' + month + day + year;
				*/
			}
		}
		if(subTtl == null) subTtl = 0.00;
		System.debug('called...');
	}
	
	public void populateAddress() {
		System.debug('called');
		addressValues = '';
		String cId = q.Contact_Name__c;
		//if(cId == null || cId == '') cId = Apexpages.currentPage().getParameters().get('cont');
		List<Contact> contList = [Select c.Account.ShippingCountry, c.Account.ShippingPostalCode, c.Account.ShippingState, c.Account.ShippingCity, 
									c.Account.ShippingStreet, c.Account.BillingCountry, c.Account.BillingPostalCode, c.Account.BillingState, 
									c.Account.BillingCity, c.Account.BillingStreet, c.Account.Name, c.AccountId, c.Phone, c.Id, c.Fax, c.Email 
									From Contact c Where Id =: cId];
		if(contList != null && contList.size() > 0) {
			//BILLING ADDRESS
			Contact c = contList.get(0);
			q.ContactId = c.Id;
			q.Email = c.Email;
			q.Phone = c.Phone;
			q.Fax = c.Fax;
			
			//BILLING ADDRESS
			q.BillingName = c.Account.Name;
			q.BillingStreet = c.Account.BillingStreet;
			q.BillingCity = c.Account.BillingCity;
			q.BillingState = c.Account.BillingState;
			q.BillingPostalCode = c.Account.BillingPostalCode;
			q.BillingCountry = c.Account.BillingCountry;
			
			//SHIPPING ADDRESS
			q.ShippingName = c.Account.Name;
			q.ShippingStreet = c.Account.ShippingStreet;
			q.ShippingCity = c.Account.ShippingCity;
			q.ShippingState = c.Account.ShippingState;
			q.ShippingPostalCode = c.Account.ShippingPostalCode;
			q.ShippingCountry = c.Account.ShippingCountry;
			
			
		} else {
			q.ContactId = null;
			q.Email = null;
			q.Phone = null;
			q.Fax = null;
			
			//BILLING ADDRESS
			q.BillingName = null;
			q.BillingStreet = null;
			q.BillingCity = null;
			q.BillingState = null;
			q.BillingPostalCode = null;
			q.BillingCountry = null;
			
			//SHIPPING ADDRESS
			q.ShippingName = null;
			q.ShippingStreet = null;
			q.ShippingCity = null;
			q.ShippingState = null;
			q.ShippingPostalCode = null;
			q.ShippingCountry = null;
		}
		
	}
	
	public Pagereference saveQuote() {
		List<Pricebook2> pb = [Select Id From Pricebook2 where IsStandard = true];
		if(pb != null && pb.size() > 0) {
			q.Pricebook2Id = pb.get(0).Id;
		}
		q.ContactId = q.Contact_Name__c;
		
		insert q;
		
		List<OpportunityLineItem> optyLineItemList = [Select o.UnitPrice, o.TotalPrice, o.Size__c, o.PricebookEntryId, o.Id, o.Description, 
														o.Color_Description__c, o.Bk__c, Style_Description__c, Quantity From OpportunityLineItem o Where o.OpportunityId =: opptyId];
		List<QuoteLineItem> qliList = new List<QuoteLineItem>();
		for(OpportunityLineItem oli : optyLineItemList) {
			QuoteLineItem qli = new QuoteLineItem();
			qli.PricebookEntryId = oli.PricebookEntryId;
			qli.Style_Description__c = oli.Style_Description__c;
			qli.Color_Description__c = oli.Color_Description__c;
			qli.Bk__c = oli.Bk__c;
			qli.Size__c = oli.Size__c;
			qli.UnitPrice = oli.UnitPrice;
			qli.Quantity = oli.Quantity;
			qli.Description = oli.Description;
			qli.QuoteId = q.Id;
			qliList.add(qli);
		}
		if(qliList != null && qliList.size() > 0) insert qliList;
		
		String hostName = Apexpages.currentPage().getHeaders().get('Host');
        String returnUrl = 'https://' + hostName + '/' + q.Id;
        PageReference p = new PageReference(returnUrl);
        p.setRedirect(true);
        return p;
	}
	
}