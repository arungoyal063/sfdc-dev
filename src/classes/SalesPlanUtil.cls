/*********************************************************************************
** Class Name :  SalesPlanUtil
** Description : This Util Class to be used with CreateOppFromSalesPlanTrigger to create Opportunity on new Sales Plan Insert
** Throws : NA
** Calls : NA
** Test Class : <Included within Class>
** 
** Organization : Rainmaker Associates LLC
**
** Revision History:-
** Version Date             Author  WO#   Description of Action
** 1.0         2012-12-21   Algo    Weloclaize Initial Version
*********************************************************************************/

public class SalesPlanUtil {
    // Opportunity Stage -> Probability Map
    private static Map<String, Decimal> stagePblMap = new Map<String, Decimal>();
    // Month -> End Date Map
    private final static Map<String, Integer> monthEndMap =  new Map<String, Integer>{
        'Jan'=>1,'Feb'=>2,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12
    };
    public static Opportunity createOpportunity(Sales_Plan__c salesplan, Account accountTobeCopy, String oppMonth, Decimal monthAmount) {
       if(salesplan.Account__c != null && accountTobeCopy != null) {     
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.AccountId = accountTobeCopy.Id;
            objOpportunity.Industry__c = accountTobeCopy.Industry__c;
            objOpportunity.Description = accountTobeCopy.Description;
            objOpportunity.GRM__c = accountTobeCopy.GRM__c;
            objOpportunity.EPD__c = accountTobeCopy.EPD__c;
            objOpportunity.Project_Type__c = accountTobeCopy.Project_Type__c;
            objOpportunity.Systems_Tools__c = accountTobeCopy.Systems_Tools__c;
            objOpportunity.Content_Types__c = accountTobeCopy.Content_Types__c;
            objOpportunity.Client_Division__c = accountTobeCopy.Client_Division__c;
            objOpportunity.Vertical_speciality__c = accountTobeCopy.Vertical_speciality__c;
            objOpportunity.African__c = accountTobeCopy.African_Language__c;
            objOpportunity.Technical_Services__c = accountTobeCopy.Technical_Services__c;
            objOpportunity.South_East_Asian__c = accountTobeCopy.South_East_Asian__c;
            objOpportunity.Other_Nordic__c = accountTobeCopy.Other_Nordic__c;
            objOpportunity.Other_Europe__c = accountTobeCopy.Other_Europe__c;
            objOpportunity.Other_Asia__c = accountTobeCopy.Other_Asia__c;
            objOpportunity.Middle_Eastern__c = accountTobeCopy.Middle_Eastern__c;
            objOpportunity.Latin_American_Caribbean__c = accountTobeCopy.Latin_American_Caribbean__c;
            objOpportunity.Indian_Subcontinent__c = accountTobeCopy.Indian_Subcontinent__c;
            objOpportunity.FIGS__c = accountTobeCopy.FIGS__c;
            objOpportunity.English_variants__c = accountTobeCopy.English_variants__c;
            objOpportunity.Eastern_European__c = accountTobeCopy.Eastern_European__c;
            objOpportunity.Australasia_Pacific_Islands__c = accountTobeCopy.Australasia_Pacific_Islands__c;
            objOpportunity.DDNFS__c = accountTobeCopy.DDNFS__c;
            objOpportunity.Central_Asian__c = accountTobeCopy.Central_Asian__c;
            objOpportunity.Canadian__c = accountTobeCopy.Canadian__c;
            objOpportunity.CCJK__c = accountTobeCopy.CCJK_4__c;            
            objOpportunity.Sales_Plan__c = salesplan.Id;
            objOpportunity.CloseDate = date.newInstance(salesplan.Year_Ending__c.year(),monthEndMap.get(oppMonth),date.daysInMonth(salesplan.Year_Ending__c.year(), monthEndMap.get(oppMonth)));
            objOpportunity.OwnerId = salesplan.CreatedById;
            objOpportunity.Type = salesplan.Type__c; 
            objOpportunity.Amount = monthAmount;
            
            if(objOpportunity.Type != NULL) {
                if(objOpportunity.Type.equalsIgnoreCase('New Business')) {
                    objOpportunity.StageName = '3. Champion (Letter)';  
                } else if(objOpportunity.Type.equalsIgnoreCase('Add-on')) {
                    objOpportunity.StageName = '4. Evaluating (SOE)';                 
                } else if(objOpportunity.Type.equalsIgnoreCase('Existing Business')) {
                    objOpportunity.StageName = '5. Pre-decision Review';              
                } else{ 
                    objOpportunity.StageName = '1. Active';
                }
            } else {
                objOpportunity.StageName = '1. Active';
            }  
                    
            objOpportunity.Probability = findOppProbabilty(objOpportunity.StageName); 
            objOpportunity.CurrencyIsoCode = salesplan.CurrencyIsoCode;
            if(salesplan.Year_Ending__c != null) {
                dateTime closeDate = datetime.newInstance(salesplan.Year_Ending__c.year(), salesplan.Year_Ending__c.month(), salesplan.Year_Ending__c.day());
                objOpportunity.Name = String.Format('{0} {1} {2}',new list<String>{accountTobeCopy.Name,
                                                oppMonth,closeDate.format('yyyy')});
            }
            
            return objOpportunity;
       }
       return null;
   }
   
   //get Opportunity Stage Name for Opportunity Type 
    public static Decimal findOppProbabilty(String oppStage) {
        Decimal opppb = 0.0;
        if(stagePblMap.isEmpty()) {
            List<OpportunityStage> stageList = [SELECT MasterLabel, DefaultProbability FROM OpportunityStage];
            for(OpportunityStage os :stageList) {
                stagePblMap.put(os.MasterLabel, os.DefaultProbability);   
            }
        } 
        if(stagePblMap.containsKey(oppStage)) {
            opppb = stagePblMap.get(oppStage);
        }
        return opppb;
    } 
    
    //Test Class for SalesPlanUtil
    static testMethod void SalesPlanUtilUnitTest(){
        Account a = TestUtils.returnAccount('Test', 'Other', 'USD');   // create Account   
        Manager_Sales_Plan__c msp = TestUtils.returnManagerSalesPlan('Test', 'USD', Date.today()); //  Create Manager Sales Plan     
        Sales_Plan__c sp = TestUtils.returnSalesPlan('Test','USD', Date.today(), a.Id, msp.Id);  // Create Sales Plan 
        SalesPlanUtil.createOpportunity(sp,a, 'Jan', 1000);
        sp.Type__c =  'New Business';
        update sp;
        SalesPlanUtil.createOpportunity(sp,a, 'Jan', 1000);
        sp.Type__c =  'Existing Business';
        update sp;
        SalesPlanUtil.createOpportunity(sp,a, 'Jan', 1000);
        sp.Type__c =  'Add-on';
        update sp;
        SalesPlanUtil.createOpportunity(sp,a, 'Jan', 1000);  
        sp.Type__c =  'Test';
        update sp;
        SalesPlanUtil.createOpportunity(sp,a, 'Jan', 1000);   
    }
}