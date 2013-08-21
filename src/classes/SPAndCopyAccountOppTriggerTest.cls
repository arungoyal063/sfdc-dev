/*********************************************************************************
** Class Name : SPAndCopyAccountOppTriggerTest
** Description : Test Class for SalesPopulateAndCopyAccountOppTrigger  Trigger
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
private class SPAndCopyAccountOppTriggerTest{
  
   static testMethod void testSPAndCopyAccountOppTrigger(){
       try { 
            Account a = TestUtils.returnAccount('Test', 'Other', 'USD');    // create Account 
            Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan    
            Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan
            Date d =  date.newinstance(2012,1,1);                                                   // create Date object     
            Opportunity opp = TestUtils.createOpportunity(a.Id, 'Closed Won', sp.Id, Date.today(),1000); // create Opportunity 
            sp = [Select Id,January__c from Sales_Plan__c where Id = :sp.Id];            
            //System.assertEquals(1000,sp.January__c);
            
            opp.CloseDate = opp.CloseDate.addMonths(1);
            opp.Amount = 2000;
            update opp; 
            sp = [Select Id,February__c from Sales_Plan__c where Id = :sp.Id];            
            //System.assertEquals(2000,sp.February__c);
                       
            opp.CloseDate = Date.today(); 
            update opp; 
                      
            opp.CloseDate = Date.today().addMonths(2);
            update opp;
            opp.CloseDate = Date.today().addMonths(3);
            update opp;
            opp.CloseDate = Date.today().addMonths(4);
            update opp;
            opp.CloseDate = Date.today().addMonths(5);
            update opp;
            opp.CloseDate = Date.today().addMonths(6);
            update opp;
            opp.CloseDate = Date.today().addMonths(7);
            update opp;
            opp.CloseDate = Date.today().addMonths(8);
            update opp;
            opp.CloseDate = Date.today().addMonths(9);
            update opp;
            opp.CloseDate = Date.today().addMonths(10);
            update opp;
            opp.CloseDate = Date.today().addMonths(11);
            update opp; 
        } catch(Exception e) { 
             System.debug('Error' + e);
        }
   }
   
}