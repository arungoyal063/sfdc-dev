public with sharing class QuoteEditController {
	
	public Quote q {get;set;}
	
	public QuoteEditController(ApexPages.StandardController sc) {
		q = new Quote();
		//q = (Quote)sc.getRecord();
		q = [Select q.TotalPrice, q.Tax, q.Subtotal, q.Status, q.ShippingStreet, q.ShippingState, q.ShippingPostalCode, q.ShippingName, 
				q.ShippingHandling, q.ShippingCountry, q.ShippingCity, q.Phone, q.Payment_Terms__c, q.Opportunity.AccountId, q.OpportunityId, 
				q.Notes__c, q.Name, q.IsSyncing, q.Id, q.GrandTotal, q.Fax, q.ExpirationDate, q.Email, q.Discount, q.Description, q.Contract_Number__c, 
				q.ContactId, q.BillingStreet, q.BillingState, q.BillingPostalCode, q.BillingName, q.BillingCountry, q.BillingCity, q.Approved__c, 
				q.QuoteNumber, q.Opportunity.Name, q.Opportunity.Account.Name, q.Contact_Name__c From Quote q Where Id =: sc.getId()];
		System.debug('q: '+q);
		q.Contact_Name__c = q.ContactId;
	}
	
	public void populateAddress() {
		System.debug('called');
		//addressValues = '';
		List<Contact> contList = [Select c.Account.ShippingCountry, c.Account.ShippingPostalCode, c.Account.ShippingState, c.Account.ShippingCity, 
									c.Account.ShippingStreet, c.Account.BillingCountry, c.Account.BillingPostalCode, c.Account.BillingState, 
									c.Account.BillingCity, c.Account.BillingStreet, c.Account.Name, c.AccountId, c.Phone, c.Id, c.Fax, c.Email 
									From Contact c Where Id =: q.Contact_Name__c];
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
		q.ContactId = q.Contact_Name__c;
		update q;
		
		String hostName = Apexpages.currentPage().getHeaders().get('Host');
        String returnUrl = 'https://' + hostName + '/' + q.Id;
        PageReference p = new PageReference(returnUrl);
        p.setRedirect(true);
        return p;
	}
}