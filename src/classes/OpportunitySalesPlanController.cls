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
public with sharing class OpportunitySalesPlanController { 
    
    public List<SelectOption> salesPlanList{get;set;}   
    public String selectedAccount{get;set;}  
    public String redirectURL{get; set;}
    public Opportunity oppObj{get;set;} 
    private Map<String, String> fieldValueMap;
    public String selectedSalesPlan{get;set;}   
    public list<Sales_Plan__c> objSalesPlan{get;set;} 
    public boolean isAccountTrue{get;set;}
    public OpportunitySalesPlanController(ApexPages.StandardController controller) {
        oppObj = (Opportunity)controller.getRecord(); 
        fieldValueMap = new Map<String, String>(); 
        
        selectedSalesPlan = Apexpages.currentPage().getParameters().get('spid');
        if(selectedSalesPlan != null && (!selectedSalesPlan.trim().equals(''))) {
             oppObj.Sales_Plan__c = selectedSalesPlan;
             doNext();
        } 
        
        selectedSalesPlan = Apexpages.currentPage().getParameters().get('pid');
        if(selectedSalesPlan != null && (!selectedSalesPlan.trim().equals(''))) {
             oppObj.Sales_Plan__c = selectedSalesPlan;
             objSalesPlan = [SELECT Id, Name FROM Sales_Plan__c WHERE Id =:selectedSalesPlan LIMIT 1];
        } 
        //salesPlanList = new  List<SelectOption>{new SelectOption('','--Select--')};
        /*for(Sales_Plan__c sp: [Select Account__c,Id, Name from Sales_Plan__c]){
            if(sp.Account__c != null){
                if(sp.Account__r.New_Business_Account__c){
                    salesPlanList.add(new SelectOption(sp.Name,sp.Name)); 
                }
            }
        }*/
        //for(Sales_Plan__c sp : [Select Id, Name from Sales_Plan__c WHERE Account__r.New_Business_Account__c = true]){
        //      salesPlanList.add(new SelectOption(sp.Name,sp.Name));             
        //}    
    }    
    
   /* private set<Id> newBusinessAccountIds(){
        list<Id> accIds = new list<Id>();
        for(Account acc:[SELECT Id FROM Account]){
        } 
    }
   public pageReference doLoad(){
         selectedSalesPlan = Apexpages.currentPage().getParameters().get('spid');
         if(selectedSalesPlan == null || selectedSalesPlan == ''){           
            return null;
         }
         oppObj.sales_plan__c = selectedSalesPlan;
         return doNext();
    }
    
     public pageReference doNext() {
        selectedSalesPlan = oppObj.sales_plan__c;       
        if(selectedSalesPlan != null && (!selectedSalesPlan.trim().equals(''))) {
            String createdOppId = createFieldMapping(null,null);
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
    }*/ 
    
    public void isAccountTrue1() {
        objSalesPlan = [SELECT Id, Name,Account__c, Account__r.New_Business_Account__c  FROM Sales_Plan__c WHERE Id=:oppObj.Sales_Plan__c  limit 1];     
        if(objSalesPlan.size() > 0){
            isAccountTrue = objSalesPlan.get(0).Account__r.New_Business_Account__c;            
        }
        isAccountTrue = false;
    }
     
     
   // doNext from Step 1     
    public pageReference doNext() {
        selectedSalesPlan = oppObj.Sales_Plan__c;  
        if(selectedSalesPlan != null && (!selectedSalesPlan.trim().equals(''))) {
            objSalesPlan = [SELECT Id, Name, Account__c, Account__r.New_Business_Account__c  FROM Sales_Plan__c WHERE Id=:oppObj.Sales_Plan__c  limit 1];     
            if(!objSalesPlan.isEmpty()) {
                if(objSalesPlan.get(0).Account__c != null && (!objSalesPlan.get(0).Account__r.New_Business_Account__c)) {
                    list<Account> accountTobeCopy = getAccount(objSalesPlan.get(0).Account__c);
                    if(accountTobeCopy == null) {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Opportunity Account does not exist!'));
                        return null;
                    }
                    createFieldMapping(accountTobeCopy.get(0),objSalesPlan);
                    String pr = createDefaultValues();  
                    redirectURL = pr;                    
                } else {
                    redirectURL = '/apex/OpportunitySalesPlanAccount?pid=' + selectedSalesPlan +'&retUrl=/006/o'; 
                    
                    /****fieldValueMap.put('Sales_Plan__c',objSalesPlan.get(0).Name);
                    String pr = createDefaultValues(); 
                    redirectURL = pr; ***/
                    
                    //redirectURL = '/006/e?&newopp=new&nooverride=1' ;
                     //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a Sales Plan!'));                              
                     //PageReference p = new PageReference('/' + Opportunity.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');
                     //p.setRedirect(true);
                     //return p;    
                     //redirectURL = ''+p;    
                }
            } else {
                redirectURL = '/' + Opportunity.SObjectType.getDescribe().getKeyPrefix() + '/e?&nooverride=1';
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a Sales Plan!'));
        }
        return null;
    } 
    
    
    
      
   // doNext from Step 2    
   public String doAccountNext() {
        selectedAccount = oppObj.AccountId;
        if(selectedAccount != null && (!selectedAccount.trim().equals(''))) {
            List<Account> accountList = getAccount(selectedAccount);
            if(!accountList.isEmpty()) {
                 createFieldMapping(accountList.get(0),objSalesPlan);
                 String pr = createDefaultValues();  
                 redirectURL = pr;
                 System.debug('###' + redirectURL);
                 /*pageReference prf = new pageReference(pr); 
                 prf.setRedirect(true);
                 return prf;  */
                 
            } else {
                if(!objSalesPlan.isEmpty()) {
                    fieldValueMap.put('Sales_Plan__c',objSalesPlan.get(0).Name);
                }               
                String pr = createDefaultValues();
                redirectURL = pr; 
                System.debug('###' + redirectURL);               
                /*pageReference prf = new pageReference(pr); 
                prf.setRedirect(true);
                return prf;*/ 
              
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select an Account!'));
        }
        return null;
    }
    
    
    
    public pageReference onCancel() {
        pageReference pr = new pageReference('/006/o');
        pr.setRedirect(true);        
        return pr;
    }
    
    public pagereference redirectUrl(){
        PageReference p = new PageReference('/' + Opportunity.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');
        p.setRedirect(true);
        return p;   
    }
   
  
    //To getAccount
    list<Account> getAccount(Id AccountId){
        if(AccountId != null) {
            list<Account> objAccount = [SELECT Id,
                                            New_Business_Account__c, 
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
    
    private String createDefaultValues() {
         
        if(!fieldValueMap.isEmpty()) {
            PageReference p = new PageReference('/' + Opportunity.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');
            String html = '';
            if(!Test.isRunningTest()) {
                html = p.getContent().toString();
            } else {
                html = ''; 
            }
            Map<String, String> labelToId = new Map<String, String>();
            Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
            while (m.find()) {
                String label = m.group(3);
                String id = m.group(1);
                labelToId.put(label, id);
                System.debug(label + '>>' + id);
            }
            
            
           if(labelToId.containsKey('Account Name')) {
               String AccLabel = labelToId.get('Account Name');
               labelToId.remove('Account Name');
               labelToId.put('Account ID', AccLabel);
               //labelToId.put('Account Id', AccLabel);
           }
           
            if(labelToId.containsKey('Type')) {
               String oppType = labelToId.get('Type');
               labelToId.remove('Type');
               labelToId.put('Opportunity Type', oppType);
               //labelToId.put('Account Id', AccLabel);
           }
           
    
            String paramStr = '';
            for (SObjectField field : Opportunity.SObjectType.getDescribe().fields.getMap().values()) {
                
                DescribeFieldResult f = field.getDescribe();
                System.debug('****' + f.getName());
                String value = getDefaultValue(f.getName());
                System.debug('####' + value);
                String label = f.getLabel();
                
                if (value != null) {
                    List<String> valueList = value.split(';');                    
                     if (labelToId.containsKey(label)) {
                        
                         for(String str : valueList) {
                             paramStr = paramStr + '&' + labelToId.get(label) + '=' + EncodingUtil.urlEncode(str, 'UTF-8');
                             
                         }
                     }
                }
                String lkidName = f.getName() + '_lkid';
                String lkidvalue = getDefaultValue(lkidName);
                
                if (lkidvalue != null) {
                    if (labelToId.containsKey(label)) {
                        paramStr = paramStr + '&' + labelToId.get(label) + '_lkid=' + EncodingUtil.urlEncode(lkidvalue, 'UTF-8');
                     }    
                }
            }
            
            if(paramStr.length() > 0) {
                paramStr = paramStr.subString(1,paramStr.length());
                paramStr = '/' + Opportunity.SObjectType.getDescribe().getKeyPrefix() + '/e?' + paramStr;
                paramStr = paramStr + '&nooverride=1&retURL='+ Apexpages.currentPage().getParameters().get('retURL');     
                return paramStr;                      
                
            }
             /*Map<String, String> paramMap = page.getParameters();
             paramMap.putAll(params);
             paramMap.put('nooverride', '1');
             paramMap.put('retURL', ApexPages.currentPage().getParameters().get('retURL'));*/
            
        }
        return null;
    }
    
    String getDefaultValue(String fieldName) {
        if(fieldName != null && fieldValueMap.containsKey(fieldName)) {           
            return fieldValueMap.get(fieldName);
        }   
        return null;   
    }
    
    public void createFieldMapping(Account accountTobeCopy,list<Sales_Plan__c> objSalesPlan) {
        fieldValueMap = new Map<String, String>(); 
        if(accountTobeCopy != null) {           
            fieldValueMap.put('AccountId',accountTobeCopy.Name);
            fieldValueMap.put('AccountId_lkid',accountTobeCopy.Id);
            fieldValueMap.put('Industry__c',accountTobeCopy.Industry__c);
            fieldValueMap.put('Description',accountTobeCopy.Description);
            fieldValueMap.put('GRM__c',accountTobeCopy.GRM__c);         
            fieldValueMap.put('EPD__c',accountTobeCopy.EPD__c);
            fieldValueMap.put('Project_Type__c',accountTobeCopy.Project_Type__c);
            fieldValueMap.put('Systems_Tools__c',accountTobeCopy.Systems_Tools__c);
            fieldValueMap.put('Content_Types__c',accountTobeCopy.Content_Types__c);            
            fieldValueMap.put('Client_Division__c',accountTobeCopy.Client_Division__c);
            fieldValueMap.put('Vertical_speciality__c',accountTobeCopy.Vertical_speciality__c);
            fieldValueMap.put('African__c',accountTobeCopy.African_Language__c);
            fieldValueMap.put('Technical_Services__c',accountTobeCopy.Technical_Services__c);           
            fieldValueMap.put('South_East_Asian__c',accountTobeCopy.South_East_Asian__c);
            fieldValueMap.put('Other_Nordic__c',accountTobeCopy.Other_Nordic__c);
            fieldValueMap.put('Other_Europe__c',accountTobeCopy.Other_Europe__c);
            fieldValueMap.put('Other_Asia__c',accountTobeCopy.Other_Asia__c);         
            fieldValueMap.put('Middle_Eastern__c',accountTobeCopy.Middle_Eastern__c);
            fieldValueMap.put('Latin_American_Caribbean__c',accountTobeCopy.Latin_American_Caribbean__c);
            fieldValueMap.put('Indian_Subcontinent__c',accountTobeCopy.Indian_Subcontinent__c);
            fieldValueMap.put('FIGS__c',accountTobeCopy.FIGS__c);          
            fieldValueMap.put('English_variants__c',accountTobeCopy.English_variants__c);
            fieldValueMap.put('Eastern_European__c',accountTobeCopy.Eastern_European__c);
            fieldValueMap.put('Australasia_Pacific_Islands__c',accountTobeCopy.Australasia_Pacific_Islands__c);
            fieldValueMap.put('DDNFS__c',accountTobeCopy.DDNFS__c);
            fieldValueMap.put('Central_Asian__c',accountTobeCopy.Central_Asian__c);
            fieldValueMap.put('Canadian__c',accountTobeCopy.Canadian__c);
            fieldValueMap.put('CCJK__c',accountTobeCopy.CCJK_4__c);
            fieldValueMap.put('Type','New Business');
            fieldValueMap.put('StageName','3. Champion (Letter)');  
            fieldValueMap.put('Probability',''+findOppProbabilty('3. Champion (Letter)'));      
        }       
        if(objSalesPlan != null && objSalesPlan.size() > 0) {
            fieldValueMap.put('Sales_Plan__c',objSalesPlan.get(0).Name);
            fieldValueMap.put('Sales_Plan__c_lkid',objSalesPlan.get(0).Id);
        }    
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
}