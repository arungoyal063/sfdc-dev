/*********************************************************************************
** Class Name :  SalesPlanTest
** Description : Test Class for SalesPlanController 
** Throws : NA
** Calls : NA
**
** 
** Organization : Rainmaker Associates LLC
**
** Revision History:-
** Version Date             Author  WO#   Description of Action
** 1.0         2012-12-21   Algo    Weloclaize Initial Version
*********************************************************************************/

@isTest
private class SalesPlanTest{
  
   static testMethod void testSalesPlanController(){
      try {
          Account a = TestUtils.returnAccount('Test', 'Other', 'USD');    // create Account 
          Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan    
          Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan 
          Opportunity opp = TestUtils.createOpportunity(a.Id, 'Closed Won', sp.Id, Date.today(),1000); // create Opportunity 
          
          Apexpages.currentPage().getParameters().put('spid',sp.id);
          ApexPages.StandardController controller = new ApexPages.StandardController(opp);
          SalesPlanController spc = new SalesPlanController(controller);
          spc.doLoad();
          spc.doNext();
          spc.onCancel();          
      }  catch(Exception e) { 
          System.debug('Error' + e);
      }
   }
  
   static testMethod void testSalesPlanNegative(){
      try {
          Account a = TestUtils.returnAccount('Test', 'Other', 'USD');   // create Account   
          Opportunity opp = TestUtils.createOpportunity(a.Id, 'Closed Won', null ,Date.today(),1000);   // create Opportunity 
          Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan        
          Sales_Plan__c salesPlan = TestUtils.returnSalesPlan('Test','USD', NULL, a.Id, msp.Id);  // Create Sales Plan
          Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan            
          ApexPages.StandardController controller = new ApexPages.StandardController(opp); 
      
          SalesPlanController spc = new SalesPlanController(controller);
          spc.doLoad();
          spc.selectedSalesPlan = null;
          spc.doNext(); 
          spc.createNewOpportunity();
          spc.selectedSalesPlan = sp.Id;
          sp.Type__c = 'New Business';
          update sp;
          spc.createNewOpportunity();
          sp.Type__c = 'Add-on';
          update sp;
          spc.createNewOpportunity();
          sp.Type__c = 'Existing Business';
          update sp;
          spc.createNewOpportunity();
          sp.Type__c = 'Test';
          update sp;
          spc.createNewOpportunity();
      } catch(Exception e) { 
          System.debug('Error' + e);
      }
   }

   
}