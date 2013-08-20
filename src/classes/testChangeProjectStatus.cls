public with sharing class testChangeProjectStatus {
	
	static testMethod void testChangeProjectStatus(){
		
		User userObj = Util.createUser();
		Account accObj = Util.createAccount();
		Appirio_PSAe__Resource__c resourceOBJ = Util.createResource(userObj.Id);
		Opportunity oppObj = Util.createOpportunity(accObj.id);
		Appirio_PSAe__Proj__c projectObj = Util.createProject(resourceOBJ.id, oppObj.Id, accObj.id);
		Appirio_PSAe__Assignment__c assign = Util.createAssignment(resourceOBJ.id,projectObj.id);
		Appirio_PSAe__Timecard__c timeObj = Util.createTimeCard(resourceOBJ.Id, projectObj.id, assign.id);
		
		// call 2 
		assign.Appirio_PSAe__Total_Assignment_Hours__c = 10;
		update assign;
		 
		try
		{
			Appirio_PSAe__Timecard__c timeObj2 = Util.createTimeCard(resourceOBJ.Id, projectObj.id, assign.id);
		}
		catch(Exception ex)
		{
			System.debug('Error On Insert....'+ex.getMessage());	
		}
		   
		
	}
	static testMethod void testCreateAssignmentbyWO() {
		
		System.debug('Trigger.ru onlce.....1....'+TriggerRunOnce.runOnce());
		
		User userObj = Util.createUser();
		Account accObj = Util.createAccount();
		Appirio_PSAe__Resource__c resourceOBJ = Util.createResource(userObj.Id);
		Opportunity oppObj = Util.createOpportunity(accObj.id);
		Appirio_PSAe__Proj__c projectObj = Util.createProject(resourceOBJ.id, oppObj.Id, accObj.id);
		Work_Order__c workObj = new Work_Order__c();
		workObj.Project__c = projectObj.id;
		workObj.Account__c = accObj.Id; 
		workObj.PM__c   = userObj.id; 
		workObj.Technical_Lead__c = userObj.id;
		workObj.Stage__c = 'Client Approved';
		workObj.Budgeted_Hours__c = '30';
		
		TriggerRunOnce.run = true;
		insert workObj; 
		System.debug('Trigger.ru onlce.....3....'+TriggerRunOnce.runOnce());
		
	}
	
	static testMethod void testCalculateBillingHours() {
		User userObj = Util.createUser();
		Account accObj = Util.createAccount();
		Appirio_PSAe__Resource__c resourceOBJ = Util.createResource(userObj.Id);
		Opportunity oppObj = Util.createOpportunity(accObj.id);
		Appirio_PSAe__Proj__c projectObj = Util.createProject(resourceOBJ.id, oppObj.Id, accObj.id);
		// add proj 
		Appirio_PSAe__Proj__c projectObj1 = Util.createProjectChild(resourceOBJ.id, oppObj.Id, accObj.id,projectObj.Id);
		
	}
	static testMethod void testTrackINvoiceDates() {
		User userObj = Util.createUser();
		Account accObj = Util.createAccount();
		Appirio_PSAe__Resource__c resourceOBJ = Util.createResource(userObj.Id);
		Opportunity oppObj = Util.createOpportunity(accObj.id);
		Appirio_PSAe__Proj__c projectObj = Util.createProject(resourceOBJ.id, oppObj.Id, accObj.id);
		 
		RMA_Invoice__c inVoiceOBj = new RMA_Invoice__c();
		inVoiceOBj.Project__c = projectObj.Id;
		inVoiceOBj.Account__c = accObj.Id; 
		inVoiceOBj.CurrencyIsoCode = 'USD';
		insert inVoiceOBj;
		
		Invoice_Line_Item__c lineOBj1 = new Invoice_Line_Item__c();
		lineOBj1.Invoice__c = inVoiceOBj.id;
		lineOBj1.Date__c = System.today();
		insert lineOBj1;
		
		Invoice_Line_Item__c lineOBj2 = new Invoice_Line_Item__c();
		lineOBj2.Invoice__c = inVoiceOBj.id;
		lineOBj2.Date__c = System.today().addDays(3);
		insert lineOBj2;
	}
	static testMethod void testChangeProjectonBuilling() {
		User userObj = Util.createUser();
		Account accObj = Util.createAccount();
		Appirio_PSAe__Resource__c resourceOBJ = Util.createResource(userObj.Id);
		Opportunity oppObj = Util.createOpportunity(accObj.id);
		Appirio_PSAe__Proj__c projectObj = Util.createProject(resourceOBJ.id, oppObj.Id, accObj.id);
		Billing_Line_Item__c billItem = Util.createBillLineItem(projectObj.Id);
		update billItem;
				
	}
	

}