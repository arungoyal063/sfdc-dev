/*********************************************************************************
** Class Name :  CreateOppFromSalesPlanTriggerTest Test Class
** Description : Test Class for SalesPopulateAndCopyAccountOppTrigger 
** Throws : NA
** Calls : NA
**
** 
** Organization : Rainmaker Associates LLC
**
** Revision History:-
** Version Date             Author  WO#   Description of Action
** 1.0     2013-01-17   Algo    Weloclaize Initial Version
*********************************************************************************/
@isTest
private class CreateOppFromSalesPlanTriggerTest{
  
   static testMethod void testOppFromSalesPlanTrigger_UnitTest(){
       try {
         Account a = TestUtils.returnAccount('Test', 'Other', 'USD');   // create Account   
         Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan       
         Sales_Plan__c sp = TestUtils.returnSalesPlanWithMonths('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan 
         List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Sales_Plan__c =:sp.Id];
         System.assert(oppList.size() > 0);
         
       } catch(Exception e) { 
          System.debug('Error' + e);
      }   
   }
   
}