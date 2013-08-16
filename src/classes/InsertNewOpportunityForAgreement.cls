public class InsertNewOpportunityForAgreement{
	
	Agreements__c ag;
	List<Agreements__c> agreeList = new List<Agreements__c>();
	List<Opportunity> oppList = new List<Opportunity>();
	List<RecordType> rt = new List<RecordType>();
	private final ApexPages.StandardController theController;

	
	public void InsertNewOpportunityForAgreement(ApexPages.StandardController stdController){
		
		this.ag =(Agreements__c)stdController.getRecord();
		
	}
	
	public PageReference autoRun(){
		
		String agId = ApexPages.currentPage().getParameters().get('id');
		
        if (agId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }		
        	// Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + agId);
        pageRef.setRedirect(true);		
        
		RecordType rt1 = new RecordType();
 		rt = [SELECT SobjectType, Name, IsActive, Id FROM RecordType  WHERE name = 'New Business/Up-sell (biNow/OAN)'];
				
		if(!rt.IsEmpty()){
			
			rt1 = rt[0];
			
        	for (Agreements__c o: [SELECT id, name FROM Agreements__c where id =:agId]) {
        		
            	//  
 				Opportunity opp = new Opportunity();
		
				opp.CloseDate = System.today();
				opp.CreateByObject__c = 'AgreeBtn';
				opp.StageName = 'Briefing/Demo Booked';
				opp.type = 'Renewal';
				opp.AccountId = ag.Account_Name__c;
			
				opp.Originating_Agreement__c = ag.id;
				opp.name = 'OAN' + ag.Name;	 	
				opp.RecordTypeId = rt1.id;
				oppList.add(opp);           	
        	}
        	
 			if(!oppList.IsEmpty()){
				insert oppList;
			}

        	return pageRef;
   			
		} else
        	return pageRef;
		
	}
		
}