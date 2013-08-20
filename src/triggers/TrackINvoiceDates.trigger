trigger TrackINvoiceDates on Invoice_Line_Item__c (after insert, after update) {
	
	String Id;
	RMA_Invoice__c invoice = new RMA_Invoice__c();
	List<Date> dateList = new List<Date>();  	
	List<Invoice_Line_Item__c> itemList = new List<Invoice_Line_Item__c>();
	for(Invoice_Line_Item__c lineItem : Trigger.new)
	{
		Id =  lineItem.Invoice__c;
	}
	
	itemList = [select Date__c,id,Project__c from Invoice_Line_Item__c where Invoice__c =: Id];
	invoice = [select Billing_Cycle_Start_Date__c,Billing_Cycle_End_Date__c,id from RMA_Invoice__c where Id =: Id];
	
	System.debug('invoice......'+invoice);
	System.debug('itemList......'+itemList);
	
	if(itemList != null && itemList.size() > 0)
	{
		for(Invoice_Line_Item__c item : itemList)
		{
			dateList.add(item.Date__c);
		}
		if(dateList != null && dateList.size() == 1)
		{
			dateList.sort();
			invoice.Billing_Cycle_Start_Date__c = dateList[0];
			invoice.Billing_Cycle_End_Date__c = dateList[0];
		}
		else if(dateList != null && dateList.size() > 1)
		{
			dateList.sort();
			invoice.Billing_Cycle_Start_Date__c = dateList[0];
			invoice.Billing_Cycle_End_Date__c = dateList[dateList.size() - 1];
		}
		if(invoice != null)
		{
			try{
				update invoice;
			}
			catch(Exception ex)
			{
				System.debug('Error on invoice update '+ex.getMessage());
			}
		}
		
	}
	}