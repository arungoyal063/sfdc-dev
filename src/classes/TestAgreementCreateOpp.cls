/**
*********************************************************************************************************************
* Module Name   :  TestAgreementCreateOpp
* Description   :  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : AgreementCreateOppProduct
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date        	  Author      	   WO#         Description of Action
* 1.0      02/05/2012     Milligan          1343       		Initial Version
*   
*******************************************************************************************************************
**/
@isTest(SeeAllData=true)
public with sharing class TestAgreementCreateOpp {

    static testMethod void testAgreementCreateOpp() { 
    	
        Test.StartTest();
            	
		Account acct = new Account();
		acct.Name = 'Acme';
		
		insert acct;
		
		Opportunity opp = new Opportunity();
		opp.name = 'Acme Opp 1';
		opp.AccountId = acct.Id;
		opp.Type = 'New Business';
		opp.CloseDate = System.today() + 30;
		opp.StageName = 'Briefing/Demo Booked';
		
		insert opp;
		
		PricebookEntry pb = [Select p.ProductCode, p.Product2Id, p.Pricebook2Id, p.Name From PricebookEntry p 
		where id = '01uA0000009uF8RIAU' limit 1];
		
		OpportunityLineItem newOli = new OpportunityLineItem();
								
		//newOli.PricebookEntryId = '01uA0000009uF8RIAU';
		newOli.PricebookEntryId = pb.id;
		newOli.OpportunityId = opp.Id;	
		newOli.Quantity = 1;
		newOli.UnitPrice = 2000;

		insert newOli;	
							
		
		Agreements__c ag1 = new Agreements__c();
		ag1.Account_Name__c = acct.Id;
		ag1.Subscription_Start_Date__c = System.today() - 30;
		ag1.closed_on__c = System.today() - 30;		
		ag1.Subscription_Type__c = '1 Year';
		ag1.Annual_Value__c = 2000;
		ag1.Final_Subscription_Value__c = 2000;
		ag1.Price_List_Item__c	= '5000';	
		ag1.Opportunity__c = opp.Id;
		ag1.Agreement_Status__c = 'Offer';		
		ag1.Subscription_End_Date__c =  System.today();
		insert ag1;
		
		ag1.Agreement_Status__c = 'Active';
		ag1.Opportunity__c = opp.Id;
		ag1.Renewal__c = 'No';
		update ag1;
		
		
		Opportunity opp2 = new Opportunity();
		opp2.name = 'Acme Opp 12';
		opp2.AccountId = acct.Id;
		opp2.Type = 'New Business';
		opp2.CloseDate = System.today() + 30;
		opp2.StageName = 'Briefing/Demo Booked';
		opp2.Originating_Agreement__c = ag1.Id;
		opp2.CreateByObject__c = 'Agreement';
		
		insert opp2;
		
		OpportunityLineItem newOli2 = new OpportunityLineItem();
								
		newOli2.PricebookEntryId = '01uA0000009uF8RIAU';
		newOli2.OpportunityId = opp2.Id;	
		newOli2.Quantity = 1;
		newOli2.UnitPrice = 2000;
		

		insert newOli2;
		
		ag1.Final_Subscription_Value__c = 15000;
		ag1.Annual_Value__c = 15000;		
		ag1.Subscription_Type__c = '2 Year';
		update ag1;
		
		ag1.Annual_Value__c = 25000;		
		ag1.Final_Subscription_Value__c = 25000;
		ag1.Subscription_Type__c = '3 Year';
		update ag1;		
		
		ApexPages.currentPage().getParameters().put('id',ag1.Id);    
		
        //Create controller instance
        ApexPages.StandardController sc = new ApexPages.StandardController(ag1);    
            
        CreateNewOANOppExtension cw = new CreateNewOANOppExtension(sc);   	
        
        cw.autoRun();
        
        User temp = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
                
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acct.Id;
        atm.UserId = temp.id;
        atm.TeamMemberRole = 'Client Account Manager';
        insert atm;
        
        AccountTeamEmailBatch batchRun = new AccountTeamEmailBatch();
        ID batchprocessid = Database.executeBatch(batchRun);    
                    
        AsyncApexJob a1 = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchprocessid];
        System.debug('\n\nFinal results are: '+a1);
        System.AssertEquals('Queued', a1.status);
        System.AssertEquals(0, a1.NumberOfErrors);        
        
        Test.StopTest();		
    }
}