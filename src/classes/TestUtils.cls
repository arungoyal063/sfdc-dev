/*********************************************************************************
** Class Name :  TestUtils 
** Description : This Class is used to create Mock Test Data for Test Classes.  
** Throws : NA
** Calls : NA
**
** 
** Organization : Rainmaker Associates LLC
**
** Revision History:-
** Version Date            Author  WO#        Description of Action
** 1.0         2012-12-21  Algo    Weloclaize Initial Version
*********************************************************************************/

public class TestUtils {

    /* create Manager_Sales_Plan__c record */
    public static Manager_Sales_Plan__c returnManagerSalesPlan(String mspName,String mspCurrecncy,Date mspYED) {
        Manager_Sales_Plan__c msp = new Manager_Sales_Plan__c(Name = mspName, CurrencyIsoCode = mspCurrecncy, Year_Ending__c = mspYED);
        try {
            insert msp;
        } catch(Exception e) { System.debug('Error' + e);}    
        return msp;      
    }
    
    /* create Account record */
    public static Account returnAccount(String accName, String accIndustry, String accCurrecncy) {
        Account a = new Account(Name = accName, Industry = accIndustry, CurrencyIsoCode = accCurrecncy);
        try {           
            insert a;            
        } catch(Exception e) { System.debug('Error' + e);}
        return a;
    }
    
    /* create Sales_Plan__c record */
    public static Sales_Plan__c returnSalesPlan(String spName, String spCurrecncy, Date spYED, String spAccId, String spMSPId) {
        Sales_Plan__c sp = new Sales_Plan__c(Name = spName, Account__c = spAccId, CurrencyIsoCode = spCurrecncy, Manager_Sales_Plan__c = spMSPId);
        
        try {
            if(spYED != null) {
                sp.Year_Ending__c = spYED;
            }
            insert sp;
        } catch(Exception e) { System.debug('Error' + e);}        
        return sp;
    }
    
    /* create Sales_Plan__c record with Month Value Populated*/
    public static Sales_Plan__c returnSalesPlanWithMonths(String spName, String spCurrecncy, Date spYED, String spAccId, String spMSPId) {
        Sales_Plan__c sp = new Sales_Plan__c(Name = spName, Account__c = spAccId, CurrencyIsoCode = spCurrecncy, Manager_Sales_Plan__c = spMSPId);
        
        try {
            if(spYED != null) {
                sp.Year_Ending__c = spYED;
            }
            sp.January__c = 1000;
            sp.February__c = 1000;
            sp.March__c = 1000;          
            sp.April__c = 1000;
            sp.May__c = 1000;
            sp.June__c = 1000;
            sp.July__c = 1000;
            sp.August__c = 1000;
            sp.September__c = 1000;
            sp.October__c = 1000;
            sp.November__c = 1000;
            sp.December__c = 1000;
            
            insert sp;
        } catch(Exception e) { System.debug('Error' + e);}        
        return sp;
    }
    
    /* create Opportunity record */
    public static Opportunity createOpportunity(String AccId,String stage, String spId,Date cDate, Decimal oppAmount) {
        Opportunity opp = new Opportunity(Name = 'Test');
        opp.AccountId = AccId;
        opp.StageName = stage;
        opp.Industry__c = 'Other';
        opp.CloseDate = cDate;
        opp.Type = 'New Business';
        opp.Systems_Tools__c = 'XML'; 
        opp.EPD__c = 'Allan Feng';
        opp.GRM__c = 'Annette Lee';
        opp.Vertical_speciality__c = 'Accounting';
        opp.Content_Types__c  = 'Other';
        opp.Language_List__c = 'Test';
        opp.Sales_Plan__c = spId;
        opp.Amount = oppAmount;
        try {
            insert opp;
        } catch(Exception e) { System.debug('Error' + e);}  
        return opp;
    }
    
     static testMethod void testTestUtils(){
          Account a = TestUtils.returnAccount('Test', 'Other', 'USD');    // create Account 
          Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan    
          Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan 
          Sales_Plan__c sp1= TestUtils.returnSalesPlanWithMonths('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan
          Opportunity opp = TestUtils.createOpportunity(a.Id, 'Closed Won', sp.Id, Date.today(),1000); // create Opportunity 
        
     }
     
     static testMethod void testTestUtilsNegative(){
          try {
              Account a = TestUtils.returnAccount('Test', 'Other', 'null');    // create Account 
              Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'null', Date.today()); //  Create Manager Sales Plan    
              Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','null', Date.today(), a.Id, msp.Id);  // Create Sales Plan 
              Opportunity opp = TestUtils.createOpportunity(a.Id, 'Closed Won', sp.Id, Date.today(),1000); // create Opportunity 
          } catch(Exception e) { System.debug('Error' + e);}  
     }
}