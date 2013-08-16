/**
*********************************************************************************************************************
* Module Name   :  CreateNewOANOppExtension
* Description   :  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    CreateOANOppProdsForAgreement
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      05/30/2013      Milligan         1359             Initial Version
* 1.1		06/28/2013		Justin Padilla	1433		Route back to the Opportunity instead of the Agreement when created 
* 1.2		07/10/2013		Justin Padilla	1433 (updated)	Reverted routing back to Agreement 
*******************************************************************************************************************
**/ 
public with sharing class CreateNewOANOppExtension {

	//WO 1359 
	Agreements__c ag;
	List<Agreements__c> agreeList = new List<Agreements__c>();
	List<Opportunity> oppList = new List<Opportunity>();
	List<RecordType> rt = new List<RecordType>();
	
	Map<id, Account> acctMap = new Map<id, Account>();
	
	private final ApexPages.StandardController theController;

    public CreateNewOANOppExtension(ApexPages.StandardController controller) {
		this.ag =(Agreements__c) controller.getRecord();
    }


	public PageReference autoRun(){
		
		String agId = ApexPages.currentPage().getParameters().get('id');
		Agreements__c current;
		if (agId != null && agId != '')
			current = [SELECT Agreements__c.Id, Agreements__c.Opportunity__c FROM Agreements__c where Agreements__c.Id =: agId];
        if (agId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }		
        // Redirect the user back to the original page
        PageReference pageRef;
        /*
        if (current != null)
        	pageRef = new PageReference('/' + current.Opportunity__c);
        else
        	pageRef = new PageReference('/' + agId);
        	*/
        
        			
        
		RecordType rt1 = new RecordType();
 		rt = [SELECT SobjectType, Name, IsActive, Id FROM RecordType  WHERE name = 'New Business/Up-sell (biNow/OAN)'];
				
		if(!rt.IsEmpty()){
			
			rt1 = rt[0];
			
			
        	for (Agreements__c ag1: [SELECT id, name, Account_Name__c, Account_Name__r.name  FROM Agreements__c where id =:agId]) {
        		
            	//  
 				Opportunity opp = new Opportunity();
		
				opp.CloseDate = System.today() + 30;
				opp.CreateByObject__c = 'AgreeBtn';
				opp.StageName = 'Briefing/Demo Booked';
				opp.type = 'Up-sell/Add-On Business';
				opp.AccountId = ag1.Account_Name__c;
			
				opp.Originating_Agreement__c = ag1.id;
				opp.name = ag1.Account_Name__r.name + ' - OAN-Initial Sale';	 	
				opp.RecordTypeId = rt1.id;
				//oppList.add(opp); 
				insert(opp);
				pageRef = new PageReference('/' + opp.Id);
				pageRef.setRedirect(true); 	
        	}
        	/*
 			if(!oppList.IsEmpty()){
 				
				insert oppList;
			}
			*/
        	return pageRef;
   			
		} else
        	return pageRef;
		
	}	

}