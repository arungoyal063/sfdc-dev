/*******************************************************************************************************************
** Module Name   : CaseProdSelectionController
** Description   : Controller for the popup page to help the user select the correct product for the Case.
** Throws        : NA
** Calls         : NA
** Test Class    : CaseProdSelectionControllerTest
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2012-12-03  US                    Initial Version
******************************************************************************************************************/
 

public class CaseProdSelectionController {
    
    public Id accountId{get;set;}
    public List<Case> caseLists{get;set;}
    public List<Account> childAccountLists{get;set;}
    public transient List<Entitlement> entitlementLists{get;set;}
    public Boolean entitlementPresent{get;set;}
    public Set<Id> childAccountIds{get;set;}
    public List<String> productLineLists{get;set;}
    public List<String> productNameLists{get;set;}
    public List<String> moduleNameLists{get;set;}
    public Map<String,List<Product2>> productLineMap{get;set;}
    public String productLineSelected{get;set;}
    public String productNameSelected{get;set;}
    public Boolean isProdLineSelected{get;set;}
    public Boolean isProdSelected{get;set;}
    public String pls{get;set;}
    public String prd{get;set;}
    public String module{get;set;}
    public String version{get;set;}
    public Product2 finalProductSelected{get;set;}
    public Boolean isReadOnly{get;set;}
    public String editButtonLabel{get;set;}
    public Boolean isEditMode{get;set;}
    public String fProductSelected{get;set;} //to show the selected product on the VF page
    
    public List<SelectOption> productLineOptions = new List<SelectOption>();
    public String redirectUrl {get; private set;}
    private Entitlement caseEntitlement;
    private Set<Id> prodIds{get;set;}
    private Map<String,List<Version__c>> productVersionMap;
    //Constructor
    public CaseProdSelectionController(ApexPages.StandardController con){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        try {
            prodIds = new Set<Id>();
            productVersionMap = new Map<String,List<Version__c>>();
            fProductSelected= NULL;
            isEditMode = FALSE;
            editButtonLabel = 'Edit';
            //isReadOnly = true;
            isReadOnly = false;
            isProdSelected = false;
            entitlementPresent = false;
            isProdLineSelected = false;
            productLineSelected = NULL;
            productLineLists = new List<String>();
            productNameLists = new List<String>();
            productNameSelected = NULL;
            pls = NULL;
            prd = NULL;
            module = NULL;
            finalProductSelected = NULL;
            productLineMap = new Map<String,List<Product2>>();
            Id caseId = ApexPages.CurrentPage().getParameters().get('id');
            if(this.findAccountId(caseId)) {
          //  accountId = ApexPages.CurrentPage().getParameters().get('accountId');
                if(accountId!=NULL) {
                    this.getChilds();
                    childAccountIds.add(accountId);
                    this.getEntitlements();
                    if(entitlementPresent) {
                        System.debug('-------Entitlements Present ------ ');
                        this.prepareProductLines();
                        System.debug('-------------EntitlementPresent : ' + entitlementLists.size());
                        //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'-------------EntitlementPresent : ' + entitlementLists.size()));
                    }   
                } else {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to select an Account before selecting the Product'));            
                }
            }
        } catch(Exception e) {
            System.debug('------Exception : ' + e);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to select an Account before selecting the Product'));            
        }
    }
    
    public Boolean findAccountId(Id caseId) {
        try {
            
            caseLists = [Select Id, AccountId, Licensed_Product__c, Licensed_Product__r.Name, ProductId, Product_Line__c, Module__c, Product_Version__c  from Case where Id=:caseId LIMIT 1]; 
            
            if(!caseLists.isEmpty()) {
                Case selCase = caseLists.get(0);                
                pageReference cView = new ApexPages.StandardController(selCase).view();              
                redirectUrl =  cView.getUrl();
                pls =  caseLists.get(0).Product_Line__c;
                /* show already selected product - block1 */
                if(caseLists.get(0).Module__c != null) {
                    module =  caseLists.get(0).ProductId;
                }  else {
                    prd = caseLists.get(0).ProductId;
                }
                if(selCase.Product_Version__c != null) { 
                    version = selCase.Product_Version__c;
                }
                /* show already selected product - block1 */
            }
            if(caseLists.get(0).Licensed_Product__c!=NULL) {
                fProductSelected = caseLists.get(0).Licensed_Product__r.Name;
            }
            if(caseLists.get(0).AccountId!=NULL) {
                accountId = caseLists.get(0).AccountId;
                System.debug('AccountId::' + accountId);
                return true;
            } else {
                accountId = NULL;
            }
            return false;
        } catch(Exception e) {
            System.debug('--------Exception ------------- : ' + e);
            return false;
        }    
    }
    
    
    public void doCancel() {
        pls = NULL;
        prd = NULL;
        module = NULL;
        version = NULL;    
    }
    
    public void selectProuduct() {
        
        if(!isEditMode) {
            isEditMode = TRUE;
            editButtonLabel = 'Cancel';
            isReadOnly = FALSE;
        } else {
            editButtonLabel = 'Edit';
            isEditMode = FALSE;
            isReadOnly = TRUE;
        }
        
    }
    
    public void getChilds() {
        childAccountIds = new Set<Id>();
        childAccountLists = [Select Id from Account where parentId =:accountId ];
        System.debug('childAccountLists' + childAccountLists);
        if(childAccountLists!=NULL && childAccountLists.size()>=1) {
            for(Account a: childAccountLists) {
                childAccountIds.add(a.Id);
            }
        }       
    }
    
    public void getEntitlements() {
        try {
            entitlementLists = [Select Licensed_Product__r.Product_New__c,Licensed_Product__r.Product_New__r.Parent_Product__c,status,Licensed_Product__c, Id From Entitlement where status='Active' AND AccountId IN :childAccountIds];   
            if(entitlementLists!=NULL && entitlementLists.size()>=1) {
                entitlementPresent = true;
            }
        } catch(Exception e) {
            System.debug('-----------Exception : ' + e);
        }   
    }  
    
    
    public void isProductLineSelected() {
    
        System.debug('-----------------The value of ProductLine selected is : ' + pls);
        System.debug('------In isProductLineSelected --------------- ' );
        prd=NULL;
        module=NULL;
        System.debug('-----------Module is set to NULL ');
        if(pls!=NULL) {
            isProdLineSelected = true;
            //this.prepareProductLineItems();
        } else {
            isProdLineSelected = false;
        }
          
        System.debug('-----Product Line selected : ' + pls);
        System.debug('-------Value of isProdLineSelected : ' + isProdLineSelected);
        
    }   
    
    public void isProductSelected() {
        System.debug('-----------------The value of Product selected is : ' + prd);
        System.debug('------In isProductSelected --------------- ' + isProdSelected);
        module = NULL;
        System.debug('-----------Module is set to NULL ');
        if(prd!=NULL) {
            isProdSelected = true;
        } else {
            isProdSelected = false;
        }
        
        System.debug('-----Product Line selected : ' + prd);
        System.debug('----------->>>Value of isProductSelected : ' + isProdSelected);
    }
    
    public void prepareProductLines() {
        try {
            List<String> prodLists = new List<String>();
            prodIds = new Set<Id>();
            productLineMap = new Map<String,List<Product2>>();
            System.debug('------In PrepareProductLines --------- ');
            if(entitlementPresent) {
                for(Entitlement e: entitlementLists) {
                    if(e.Licensed_Product__c!=NULL && e.Licensed_Product__r.Product_New__c!=NULL && e.status!=NULL && e.status=='Active') {
                        //prodLists.add(e.Licensed_Product__r.Product_Line__c);
                        prodIds.add(e.Licensed_Product__r.Product_New__c);
                    }  
                }
                //Hardcode product added vis custom setting
                Generic_Product_List__c gpl = Generic_Product_List__c.getInstance('Ellucian Support Center');
                if (gpl != null) {
                    String genPrdIds = gpl.Generic_Product_Ids__c;
                    if(genPrdIds != null){
                        for(String val :genPrdIds.split(',')){
                            prodIds.add(val.trim());
                        }
                    }   
                }
              
                //List<Licensed_Product__c> productLists = [Select Id,Name, Product_Line__c, Product_New__c, Product_New__r.Name from Licensed_Product__c where Product_Line__c IN :prodLists];
                list<Product2> productLists = [Select Id, Name, Product_Line__c, Parent_Product__c,Parent_Product__r.Name,(Select Id,Name from Versions__r where Active__c=true order by Name desc) from Product2 where (Id IN :prodIds or Parent_Product__c IN :prodIds) and Family = 'Software' and Is_Case_Supported__c = true]; 
                System.debug('-----Products found : ' + productLists.size());
                if(productLists!=NULL && productLists.size()>0) {
                    for(Product2 lP: productLists) {
                       
                        if(lP.Product_Line__c!=NULL) {                           
                            productLineLists.add(lP.Product_Line__c);
                            // Product --> version Map
                            if(lP.Versions__r != null) {
                                productVersionMap.put(lP.Id, lP.Versions__r);
                            }
                            if(!productLineMap.containsKey(lP.Product_Line__c)) {
                                List<Product2> ps = new List<Product2>();
                                ps.add(lp);
                                productLineMap.put(lP.Product_Line__c,ps);
                                system.debug('key map .....'+ productLineMap);
                            } else {
                                List<Product2> ps = productLineMap.get(lP.Product_Line__c);
                                ps.add(lP);
                                productLineMap.put(lP.Product_Line__c,ps);
                                system.debug('key map else.....'+ productLineMap);
                            }
                        }
                    }
                }
                 
            }  
            
            System.debug('>>>>' + productVersionMap);
          
        } catch(Exception e) {
            System.debug('-------Exception ' + e);
        }
    }
    
    //method to populate the productLine picklist
    public List<SelectOption> getProductLineItems() {

        System.debug('------------in Product Line Items ----------- ' + productLineMap.keySet());
        List<SelectOption> options = new List<SelectOption>();
        
        for(String s: productLineMap.keySet()) {
            options.add(new SelectOption(s,s));
        }
        options = SortSelectOptions.selectOptionSortByLabel(options);       
        return options;
    }
      
    //method to populate the product Name picklist
    public List<SelectOption> getProductNameItems() {
        List<SelectOption> options = new List<SelectOption>();
        System.debug('--------------- In Prouduct Name selection ------- ');
        System.debug('--------------- Product Line Selected : ' + pls);
       
        if(pls!=NULL) {
            
            List<Product2> avaliableProducts = productLineMap.get(pls);
            if(avaliableProducts!=NULL && avaliableProducts.size()>0) {
                Set<String> tempSet = new Set<String>();
                for(Product2 s: avaliableProducts) {
                    if(s.Parent_Product__c==NULL) {
                        String opt = s.Name;
                        if(!tempSet.contains(s.Id)) {
                            options.add(new SelectOption(s.Id,opt));
                            tempSet.add(s.Id);
                        }
                    } else {
                        
                        String opt = s.Parent_Product__r.Name;
                        if(!tempSet.contains(s.Parent_Product__c)) {
                            options.add(new SelectOption(s.Parent_Product__c,opt));
                            tempSet.add(s.Parent_Product__c);
                        }
                        
                        /* show already selected product - block2 */
                        if(module != null && module !='BLANK' && s.Id == module) {
                            prd = s.Parent_Product__c;
                        }
                        /* show already selected product - block2 */
                    }
                    
                } 
            }      
            
        }
        System.debug('-----------getProductNameItems finished successfully ');
        options = SortSelectOptions.selectOptionSortByLabel(options);       
        return options;
    }
     
    
    //method to populate the Module Name Picklist
    /*public List<SelectOption> getModuleNameItems() {
        List<SelectOption> options = new List<SelectOption>();
        System.debug('--------------- In getModuleNameItems ------- ');
        if(prd!=NULL) {
            System.debug('---------prd selected : ' + prd);
            List<Product2> avaliableProducts = productLineMap.get(prd);
            System.debug('-----------Avaliable Products : ' + avaliableProducts);
            if(avaliableProducts!=NULL && avaliableProducts.size()>0) {
                Set<String> tempSet = new Set<String>();
                for(Product2 s: avaliableProducts) {
                    if(s.Parent_Product__c!=NULL) {
                        String opt = s.Name;
                       if(!tempSet.contains(s.Id)) {
                            options.add(new SelectOption(opt,opt));
                            tempSet.add(s.Id);
                       }
                    }
                } 
                
                if(options==NULL || options.size()<=0) {
                    System.debug('-----------Module is set to BLANK ');
                    module='BLANK';
                }
            } else {
                System.debug('-----------Module is set to BLANK ');
                module='BLANK';            
            }      
        }
       
        return options;
    }*/
    
    
    //method to populate the Module Name Picklist
    public  List<SelectOption> getModuleNameItems() {
        List<SelectOption> options = new List<SelectOption>();       
        if(prd!=NULL && prodIds != null) {
            List<Product2> moduleProducts = [SELECT Id,Name FROM Product2 WHERE Parent_Product__c = :prd AND Id IN :prodIds AND Family = 'Software' AND Is_Case_Supported__c = true];
            
            if(moduleProducts!=NULL && moduleProducts.size()>0) {
                Set<String> tempSet = new Set<String>();
                for(Product2 s: moduleProducts) {
                   String opt = s.Name;
                   if(!tempSet.contains(s.Id)) {
                        options.add(new SelectOption(s.Id,opt));
                        tempSet.add(s.Id);
                   }
                } 
                
                if(options==NULL || options.size()<=0) {
                    System.debug('-----------Module is set to BLANK ');
                    module='BLANK';
                }
            } else {
                System.debug('-----------Module is set to BLANK ');
                module='BLANK';            
            }      
        }
        
        options = SortSelectOptions.selectOptionSortByLabel(options);
        return options;
    }
    
    
    //method to populate the Module Name Picklist
    public List<SelectOption> getProductVersionList() {
    	List<SelectOption> sortedList = new List<SelectOption>();
        List<SelectOption> options = new List<SelectOption>();
        //List<SelectOptionWrapper> wrapperList = new List<SelectOptionWrapper>(); 
        List<Version__c> versionList;      
        if(prd!=NULL && prodIds != null) {
            if(productVersionMap.containsKey(prd)) {
                versionList = productVersionMap.get(prd);                  
            } else {
                versionList = [Select Id,Name from Version__c where Product__c=:prd and Active__c=true  order by Name desc]; 
            }
            
            for(Version__c v : versionList) {
                //wrapperList.add(new SelectOptionWrapper(new SelectOption(v.Id,v.Name)));
                options.add(new SelectOption(v.Id,v.Name));     
            }    
        }
        sortedList = SelectOptionWrapper.selectOptionSortByLabel(options);
        /*wrapperList.sort();
        for(SelectOptionWrapper sopt :wrapperList) {
            options.add(sopt.oppy);
        }
        return options;*/
        return sortedList;
    }
    
    public void productSelect() {
        try {
        System.debug('-----Product Line : ' + pls);
        System.debug('-----Product Name : ' + prd);
        System.debug('-----Module : ' + module);
        finalProductSelected = NULL;
        //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Prd Line : ' + pls + ' Prd Name : ' + prd + ' Module : ' + module));
        //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Modules : ' + this.getModuleNameItems()));
        //if(prd!=NULL && this.getModuleNameItems().size()<1)  Algo Coment
        
        if(prd!=NULL && (module == 'BLANK'|| module == NULL || (module != NULL && module.trim().equals('')))) {
            System.debug('---------------No Module preset -------');
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'---------------No Module preset -------'));
            List<Product2> avaliableProducts = productLineMap.get(pls);
            if(avaliableProducts!=NULL && avaliableProducts.size()>0) {
                
                for(Product2 s: avaliableProducts) {                   
                    if(s.Parent_Product__c==NULL) {                        
                        if(s.Id == prd) {                        
                            finalProductSelected = s;
                            fProductSelected = s.Name;
                            caseLists.get(0).ProductId = s.Id;
                            caseLists.get(0).Product_Version__c = getProductVersion();
                            updareCaseEntilements(s.Id);
                            update caseLists.get(0);
                            break;
                        }
                    } else {
                        
                        if(s.Parent_Product__c == prd) {                           
                            //finalProductSelected = s.Parent_Product__c;
                            fProductSelected = s.Parent_Product__r.Name;
                            caseLists.get(0).ProductId = s.Parent_Product__c;
                            caseLists.get(0).Product_Version__c = getProductVersion();
                            updareCaseEntilements(s.Parent_Product__c);
                            update caseLists.get(0);
                            break;
                        }   
                    }
                }    
            } 
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Product Selected successfully : ' + finalProductSelected));
        } else if(prd!=NULL && module!=NULL) {
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'----------------------Module preset -------'));
            List<Product2> avaliableProducts = productLineMap.get(pls);
            if(avaliableProducts!=NULL && avaliableProducts.size()>0) {
               System.debug('PPPPPP' + avaliableProducts);
                
                for(Product2 s: avaliableProducts) {
                   
                    if(s.Parent_Product__c != NULL) {
                        
                        if(s.Id == module) {
                            finalProductSelected = s;
                            fProductSelected = s.Name;
                            caseLists.get(0).ProductId = s.Id;
                            caseLists.get(0).Product_Version__c = getProductVersion();
                            updareCaseEntilements(s.Id);
                            update caseLists.get(0);
                            break;                            
                        }
                    }
                }
            }       
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Product Selected successfully : ' + finalProductSelected));
        } else {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'To select the Product, you need to select the Product Line, Product Name and Module.'));    
        }
        } catch(Exception e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));        
        }
        
    }
    
    private String getProductVersion() {
        if(version != null && version.trim() != '') {
            return version;
        }
        return null;
    }
    
    private void updareCaseEntilements(String product2Id) {
        if(accountId != null  && caseLists.get(0).ProductId != null) {
            Date nowDate = Date.today();
             List<Entitlement> caseEntlmnt = [SELECT Id FROM Entitlement WHERE Licensed_Product__c IN (SELECT Id FROM Licensed_Product__c WHERE Account__c = :accountId AND Product_New__c = :product2Id) AND StartDate <= :nowDate  AND EndDate >= :nowDate AND status='Active' LIMIT 1];
           
            if(!caseEntlmnt.isEmpty()) {
                caseLists.get(0).EntitlementId = caseEntlmnt.get(0).Id;                
            } else {
                 caseLists.get(0).EntitlementId = null;
            }
        }
    } 
    
    
    
    
  
    static testMethod void CaseProdSelectionUnitTest() {
         Case c = MockTestData.createCaseRecord('open', 'Email', 'Level 3', 'Test','Test');   // Case Created 
         Account a = MockTestData.createAccountRecord('Test',100);
         Account childAcc = MockTestData.createAccountRecord('Test',100);
         Entitlement  en  = MockTestData.createEntlmntRecord('Test', a);
         Licensed_Product__c lp = MockTestData.createLPRecord('Test', a);        
         Product2 pro = MockTestData.createProductRecord('Test');         
         Version__c v= MockTestData.createVersionRecord(pro.Id);       
         pro.Product_Line__c = 'Test';
         update pro;
         
         Product2 childProduct = MockTestData.createProductRecord('Test');
         childProduct.Product_Line__c = 'Test';
         childProduct.Parent_Product__c = pro.Id;
         update childProduct;
         
         lp.Product_New__c = pro.Id;
         update lp;
         
         en.Licensed_Product__c = lp.Id;
         update lp;
         
         c.AccountId = a.Id;
         c.Licensed_Product__c = lp.Id;
         c.ProductId = pro.Id;
         update c;
         
         childAcc.ParentId = a.Id;        
         update childAcc;
         
         en.StartDate = Date.Today(); 
         en.EndDate = Date.Today().addDays(10);        
         update en;
         
         ApexPages.CurrentPage().getParameters().put('id', c.Id);
         ApexPages.StandardController con = new ApexPages.StandardController(c);
         CaseProdSelectionController cp = new CaseProdSelectionController(con);
         cp.doCancel();
         cp.selectProuduct();
         cp.selectProuduct();
         cp.isProductLineSelected();
         cp.isProductSelected();
         cp.getProductLineItems();
         cp.pls = 'Test';
         cp.getProductNameItems();
         cp.prd = pro.Id;
         cp.getModuleNameItems();
         cp.getProductVersionList();
         cp.productSelect();
         cp.updareCaseEntilements(pro.Id);
        
         
    }
}