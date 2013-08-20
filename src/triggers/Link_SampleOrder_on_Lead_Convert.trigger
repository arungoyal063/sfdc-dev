trigger Link_SampleOrder_on_Lead_Convert on Lead (after update) 
{
	//trigger to link Sample Order records to Opportunity, after Lead conversion
	
	if (Trigger.new.size() == 1)  //only work with manually converted leads 
	{
		list<sample_order__c> sample_orders_to_update = new list<sample_order__c>();
		
		//verify that the trigger has just been converted and that the conversion has created an opportunity
		if (Trigger.old[0].isConverted == false && Trigger.new[0].isConverted == true) 
		{
			
			for(Sample_Order__c so:[select id,opportunity__c from sample_order__c where lead__c = :trigger.new[0].id])
			{
				so.Opportunity__c = trigger.new[0].ConvertedOpportunityId;
				so.Account__c = trigger.new[0].ConvertedAccountId;
				
				sample_orders_to_update.add(so);
			}
			
			if(sample_orders_to_update.size() > 0)
			{
				update sample_orders_to_update;
			} 
		}  
	 
	 
	}
	

}