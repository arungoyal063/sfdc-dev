@isTest
private class TriggerTests {

  static testMethod void myUnitTest() {
        Account a = new Account();
        a.Name = 'TestAccount';
        a.CRM_Org_ID__c = 'testAccount';
        a.Price_Book__c = 'Tier 1';
        a.Type = 'Client';
        a.AccountNumber = 'X0102';
        insert a;
        
        a.Price_Book__c = 'Tier 2';
        update a;
 Contact cnct = new Contact();
 cnct.LastName='LastName';
 cnct.FirstName='FirstName';
 cnct.AccountId=a.Id;
 insert cnct;

  


        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'partner test';
        o.amount = 100;
        o.closedate = system.today();
        o.recordtypeid = '012G0000000yBnDIAU';
        o.stagename = 'Proposal';
        o.LeadSource = 'Contract Vehicle';
        o.Services_Planned_Start_Date__c =system.today();
        o.Services_Planned_End_Date__c =system.today();
        o.Has_Primary_Contact__c = TRUE;
        o.Type = 'CBR';
        o.Category__c = 'Strategic Solutions';
        o.Summary__c ='Recruiter';
        o.Primary_Contact_2__c =cnct.id;
        insert o;
 
/*        Opportunity o1 = new Opportunity();
        o1.accountid = a.id;
        o1.name = 'test actionplan';
        o1.amount = 0;
        o1.stagename = 'Proposal';
        o1.LeadSource = 'Contract Vehicle';
        o1.closedate = system.today();
        o1.recordtypeid = '012G0000000yBn8';
        insert o1;
  */      
        o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.amount = 100;
        o.closedate = system.today();
        o.recordtypeid = '012G0000000yBn3IAE';
        o.stagename = 'Proposal';
        o.LeadSource = 'Contract Vehicle';
        o.BAS_Territory__c = '005G0000001xxOwIAI';
        o.ISR_Territory__c = '005G0000001xxOwIAI';
        o.Has_Primary_Contact__c = TRUE;
        o.Services_Planned_Start_Date__c =system.today();
        o.Services_Planned_End_Date__c =system.today();
        o.Primary_Contact_2__c =cnct.id;
        //system.debug('******************************'+o1.id);
        //o.Parent_Action_Plan__c = o1.id;
        insert o;

 /* OpportunityContactRole ocr = new OpportunityContactRole();        
 ocr.OpportunityId = o.Id;        
  ocr.ContactId=cnct.Id;    
   ocr.IsPrimary=TRUE;
          insert ocr;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Quantity = 1;
        oli.TotalPrice = 1;
        oli.PricebookEntryId = '01uG000000A91h1IAB';
        oli.OpportunityId = o.id;    
        oli.Unit_of_Measure__c = 'Fixed Fee';
        insert oli;  
             */
         
         
        o.StageName ='Contract Process';
        o.Type = 'CBR';
        o.Category__c = 'Strategic Solutions';
        o.Summary__c ='Recruiter';
        o.Amount = 60000;
        o.BAS_Territory__c = '005G0000001xxOyIAI';
        o.ISR_Territory__c = '005G0000001xxOwIAI';
        o.Services_Planned_Start_Date__c =system.today();
        o.Services_Planned_End_Date__c =system.today();
        o.Primary_Contact_2__c =cnct.id;
        o.Business_Unit__c = 'SG51';
        update o;
        
        //o.closedate =system.today().addMonths(1);
        //o.Amount = o.Amount * 1.2;
        //update o;
        
        Note n = new Note();
        n.ParentId = o.Id;
        n.Title = 'test';
        n.Body = 'test';
        insert n;
        
     }

}