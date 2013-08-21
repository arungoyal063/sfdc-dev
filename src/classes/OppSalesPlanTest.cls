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
private class OppSalesPlanTest{
  
   static testMethod void testOppSalesPlanController(){
      try {
          Account a = TestUtils.returnAccount('Test', 'Other', 'USD');    // create Account 
          Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan    
          Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan 
          Opportunity opp = TestUtils.createOpportunity(a.Id, 'Closed Won', sp.Id, Date.today(),1000); // create Opportunity 
          
          Apexpages.currentPage().getParameters().put('spid',sp.id);
          ApexPages.StandardController controller = new ApexPages.StandardController(opp);
          OpportunitySalesPlanController spc = new OpportunitySalesPlanController(controller);          
          spc.doNext();
          spc.onCancel();       
          Apexpages.currentPage().getParameters().put('pid',sp.id);
          ApexPages.StandardController stdCtr = new ApexPages.StandardController(opp);
          OpportunitySalesPlanController spCtr = new OpportunitySalesPlanController(stdCtr);          
          spCtr.doAccountNext();
          spCtr.onCancel();            
      }  catch(Exception e) { 
          System.debug('Error' + e);
      }
   }
  
   static testMethod void testOppSalesPlanNegative(){
      try {
          Account a = TestUtils.returnAccount('Test', 'Other', 'USD');   // create Account   
          Opportunity opp = TestUtils.createOpportunity(a.Id, 'Closed Won', null ,Date.today(),1000);   // create Opportunity 
          Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan        
          Sales_Plan__c salesPlan = TestUtils.returnSalesPlan('Test','USD', NULL, a.Id, msp.Id);  // Create Sales Plan
          Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan            
          ApexPages.StandardController controller = new ApexPages.StandardController(opp); 
      
          OpportunitySalesPlanController spc = new OpportunitySalesPlanController(controller);         
      
      } catch(Exception e) { 
          System.debug('Error' + e);
      }
   }

   
}