/*********************************************************************************
** Class Name :  SalesPlanController 
** Description : SalesPlanController Class
** Throws : NA
** Calls : NA
** Test Class : SalesPlanTest
** 
** Organization : Rainmaker Associates LLC
**
** Revision History:-
** Version Date             Author  WO#   Description of Action
** 1.0         2012-12-21   Algo    Weloclaize Initial Version
*********************************************************************************/
public with sharing class SalesPlanController { 
    public List<SelectOption> salesPlanList{get;set;}   
    public String selectedSalesPlan{get;set;}     
    Opportunity oppObj;  
    public SalesPlanController(ApexPages.StandardController controller) {
        oppObj = (Opportunity)controller.getRecord();       
        salesPlanList = new  List<SelectOption>();
        //for(Sales_Plan__c sp : [Select Id, Name from Sales_Plan__c limit 9999]){
        //   salesPlanList.add(new SelectOption(sp.Id,sp.Name));    
        //}
    }    
    
    public pageReference doLoad(){
         selectedSalesPlan = Apexpages.currentPage().getParameters().get('spid');
         list<Sales_Plan__c> objSalesPlan = [SELECT Name,Account__c FROM Sales_Plan__c WHERE Account__r.New_Business_Account__c = false AND Id=:selectedSalesPlan limit 1];
         if(!objSalesPlan.isEmpty()){
            pageReference pr = new pageReference('/006/e?&nooverride=1');
            pr.setRedirect(true);        
            return pr;
         }
         if(selectedSalesPlan == null || selectedSalesPlan == ''){           
            return null;
         }
         oppObj.sales_plan__c = selectedSalesPlan;
         return doNext();
    }
    
    public pageReference doNext() {
        selectedSalesPlan = oppObj.sales_plan__c; 
        if(selectedSalesPlan != null && (!selectedSalesPlan.trim().equals(''))) {
            String createdOppId = createNewOpportunity();
            if(createdOppId == null || createdOppId == ''){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to create opportunity,Contact your Admin!'));
                return null;
            }
            String redirectURL = Apexpages.currentPage().getParameters().get('spid');
            if(redirectURL == null || redirectURL == ''){
                redirectURL = String.Format('/{0}/e?retURL=%2F006%2Fo',new String[]{createdOppId});
            }else{
                redirectURL = '/'+createdOppId+'/e?retURL='+redirectURL;
            }
            pageReference pr = new pageReference(redirectURL);
            pr.setRedirect(true);        
            return pr;
        } else {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a Sales Plan!'));        
        }
        return null;
    } 
    
    public pageReference onCancel() {
        pageReference pr = new pageReference('/006/o');
        pr.setRedirect(true);        
        return pr;
    }
    //To create opp
    public String createNewOpportunity() {
        
        list<Sales_Plan__c> salesPlanTobeCopy = getSalesPlan(selectedSalesPlan);
        if(salesPlanTobeCopy == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sales Plan does not exist!'));
            return null;
        }
        list<Account> accountTobeCopy = getAccount(salesPlanTobeCopy.get(0).Account__c);
        if(accountTobeCopy == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account does not exist for the selected SalesPlan!'));
            return null;
        }
        
       
        
       
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = accountTobeCopy.get(0).Id;
        objOpportunity.Industry__c = accountTobeCopy.get(0).Industry__c;
        objOpportunity.Description = accountTobeCopy.get(0).Description;
        objOpportunity.GRM__c = accountTobeCopy.get(0).GRM__c;
        objOpportunity.EPD__c = accountTobeCopy.get(0).EPD__c;
        objOpportunity.Project_Type__c = accountTobeCopy.get(0).Project_Type__c;
        objOpportunity.Systems_Tools__c = accountTobeCopy.get(0).Systems_Tools__c;
        objOpportunity.Content_Types__c = accountTobeCopy.get(0).Content_Types__c;
        objOpportunity.Client_Division__c = accountTobeCopy.get(0).Client_Division__c;
        objOpportunity.Vertical_speciality__c = accountTobeCopy.get(0).Vertical_speciality__c;
        objOpportunity.African__c = accountTobeCopy.get(0).African_Language__c;
        objOpportunity.Technical_Services__c = accountTobeCopy.get(0).Technical_Services__c;
        objOpportunity.South_East_Asian__c = accountTobeCopy.get(0).South_East_Asian__c;
        objOpportunity.Other_Nordic__c = accountTobeCopy.get(0).Other_Nordic__c;
        objOpportunity.Other_Europe__c = accountTobeCopy.get(0).Other_Europe__c;
        objOpportunity.Other_Asia__c = accountTobeCopy.get(0).Other_Asia__c;
        objOpportunity.Middle_Eastern__c = accountTobeCopy.get(0).Middle_Eastern__c;
        objOpportunity.Latin_American_Caribbean__c = accountTobeCopy.get(0).Latin_American_Caribbean__c;
        objOpportunity.Indian_Subcontinent__c = accountTobeCopy.get(0).Indian_Subcontinent__c;
        objOpportunity.FIGS__c = accountTobeCopy.get(0).FIGS__c;
        objOpportunity.English_variants__c = accountTobeCopy.get(0).English_variants__c;
        objOpportunity.Eastern_European__c = accountTobeCopy.get(0).Eastern_European__c;
        objOpportunity.Australasia_Pacific_Islands__c = accountTobeCopy.get(0).Australasia_Pacific_Islands__c;
        objOpportunity.DDNFS__c = accountTobeCopy.get(0).DDNFS__c;
        objOpportunity.Central_Asian__c = accountTobeCopy.get(0).Central_Asian__c;
        objOpportunity.Canadian__c = accountTobeCopy.get(0).Canadian__c;
        objOpportunity.CCJK__c = accountTobeCopy.get(0).CCJK_4__c;
        objOpportunity.Sales_Plan__c = salesPlanTobeCopy.get(0).Id;
        objOpportunity.CloseDate = salesPlanTobeCopy.get(0).Year_Ending__c;
        objOpportunity.OwnerId = salesPlanTobeCopy.get(0).CreatedById;
        objOpportunity.Type = salesPlanTobeCopy.get(0).Type__c; 
        
        if(objOpportunity.Type != NULL) {
            if(objOpportunity.Type.equalsIgnoreCase('New Business')) {
                objOpportunity.StageName = '3. Champion (Letter)';  
            } else if(objOpportunity.Type.equalsIgnoreCase('Add-on')) {
                objOpportunity.StageName = '4. Evaluating (SOE)';                 
            } else if(objOpportunity.Type.equalsIgnoreCase('Existing Business')) {
                objOpportunity.StageName = '5. Pre-decision Review';              
            } else {
                objOpportunity.StageName = '1. Active';
            }
        } else {
            objOpportunity.StageName = '1. Active';
        }   
          
        objOpportunity.Probability = findOppProbabilty(objOpportunity.StageName); 
        objOpportunity.CurrencyIsoCode = salesPlanTobeCopy.get(0).CurrencyIsoCode;
        if(salesPlanTobeCopy.get(0).Year_Ending__c != null) {
            dateTime closeDate = datetime.newInstance(salesPlanTobeCopy.get(0).Year_Ending__c.year(), salesPlanTobeCopy.get(0).Year_Ending__c.month(), salesPlanTobeCopy.get(0).Year_Ending__c.day());
            objOpportunity.Name = String.Format('{0} {1} {2}',new list<String>{accountTobeCopy.get(0).Name,
                                            closeDate.format('MMM'),closeDate.format('yyyy')});
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Year Ending Date does not Exist on Sales Plan, Please fill an Year Ending Date then try again!'));    
        }                                                                                        
        try{
            insert objOpportunity;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+ex.getMessage()));
            return null;
        }
        return objOpportunity.Id;
    }
    
    //get Opportunity Stage Name for Opportunity Type 
    private Decimal findOppProbabilty(String oppStage) {
        Decimal opppb = 0.0;
        List<OpportunityStage> ooList = [SELECT MasterLabel, DefaultProbability FROM OpportunityStage WHERE MasterLabel = :oppStage LIMIT 1];
        if(!ooList.isEmpty()) {
            return ooList.get(0).DefaultProbability;
        }
        return opppb;
    } 
    
    //To getSalesPlan
    list<Sales_Plan__c> getSalesPlan(Id salesPlanId){
        if(salesPlanId != null){
            list<Sales_Plan__c> objSalesPlan = [SELECT 
                                                        Account__c,
                                                        Year_Ending__c,
                                                        Type__c, 
                                                        Sales_Plan_Total__c, 
                                                        CreatedById,
                                                        CurrencyIsoCode,
                                                        Status__c 
                                                FROM 
                                                        Sales_Plan__c 
                                                WHERE 
                                                        Id =:salesPlanId];
            return objSalesPlan;
        }
        return null;
    }
    //To getAccount
    list<Account> getAccount(Id AccountId){
        if(AccountId != null) {
            list<Account> objAccount = [SELECT 
                                            Vertical_speciality__c,
                                            Type, 
                                            Systems_Tools__c, 
                                            Project_Type__c, 
                                            GRM__c, EPD__c, 
                                            Description, 
                                            Content_Types__c, 
                                            Client_Division__c, 
                                            Name,
                                            Technical_Services__c,
                                            South_East_Asian__c,
                                            Other_Nordic__c,
                                            Other_Europe__c,
                                            Other_Asia__c,
                                            Middle_Eastern__c,
                                            Latin_American_Caribbean__c,
                                            Indian_Subcontinent__c,
                                            FIGS__c,
                                            English_variants__c,
                                            Eastern_European__c, 
                                            Australasia_Pacific_Islands__c,
                                            African_Language__c,
                                            DDNFS__c,
                                            Central_Asian__c,
                                            Canadian__c,
                                            CCJK_4__c,
                                            Industry__c  
                                    FROM 
                                            Account 
                                    WHERE 
                                            Id =:AccountId];
            return objAccount;
        } 
        return null;
    }
}