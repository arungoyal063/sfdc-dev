/*******************************************************************************************************************
** Module Name   : CaseProductSelection Controller Extension 
** Description   : Controller for the popup page to help the community user select the correct product for the Case.
** Throws        : NA
** Calls         : NA
** Test Class    : Test_CaseProductSelection
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2012-12-03  US                    Initial Version
******************************************************************************************************************/
public with sharing class CaseProductSelection {

    public Id accountId{get;set;}    
    public String version{get;set;}
    public String productLineSelected{get;set;}
    public String productNameSelected{get;set;}
    public Boolean isProdLineSelected{get;set;}
    public Boolean isProdSelected{get;set;}
    public String pls{get;set;}
    public String prd{get;set;}
    public String module{get;set;}
    public Product2 finalProductSelected{get;set;}
    public Boolean isReadOnly{get;set;}
    public String editButtonLabel{get;set;}
    public Boolean isEditMode{get;set;}
    private Map<String,List<Version__c>> productVersionMap;
    public String fProductSelected{get;set;} //to show the selected product on the VF page
    
    public List<SelectOption> productLineOptions = new List<SelectOption>();
    public String redirectUrl {get; private set;}
    private Entitlement caseEntitlement;
    public Id CRId;    
    public Set<Id> childAccountIds{get;set;}
    public Transient List<Entitlement> entitlementLists{get;set;}
    public Boolean entitlementPresent{get;set;}
    private Set<Id> prodIds{get;set;}
    public Map<String,List<Product2>> productLineMap{get;set;}
    // added code 
    public List<SelectOption> ProductLineItem{get;set;}
    public List<SelectOption> ProductItem{get;set;}
    public List<SelectOption> ModuleItem{get;set;}
    public List<SelectOption> VersionItem{get;set;}
    public Boolean errorMsg{get;set;}
    //private final ApexPages.IdeaStandardController ideaController;    
    
    //Constructor
    public CaseProductSelection(ApexPages.StandardController con){
        
        try {
            Schema.DescribeSObjectResult describeResult = Case.getSObjectType().getDescribe(); 
            if(describeResult.isCreateable()) {  
                errorMsg = false;
                productVersionMap = new Map<String,List<Version__c>>();
                fProductSelected= NULL;
                isEditMode = FALSE;
                editButtonLabel = 'Edit';
                //isReadOnly = true;
                isReadOnly = false;
                isProdSelected = false;
                isProdLineSelected = false;
                productLineSelected = NULL;
                productNameSelected = NULL;
                pls = NULL;
                prd = NULL;
                module = NULL;
                finalProductSelected = NULL;
                ProductLineItem = new List<SelectOption>();
                ProductItem = new List<SelectOption>();
                ModuleItem = new List<SelectOption>();
                VersionItem = new List<SelectOption>();
                productLineMap = new Map<String,List<Product2>>();
                List<User> userList = [Select AccountId from User where Id =:UserInfo.getUserId()];
                if((!userList.isEmpty()) && (userList.get(0).AccountId != null)) {
                    accountId = userList.get(0).AccountId;                 
                    getChilds();  
                    childAccountIds.add(accountId);
                    getEntitlements();
                    if(entitlementPresent) {
                        this.prepareProductLines(); 
                    } 
                    
                }
            } else {
               errorMsg = true;    
            }   
        } catch(Exception e) {
            System.debug('------Exception : ' + e);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to select an Account before selecting the Product'));            
        }
    }
    
    
    public void doCancel() {
        pls = NULL;
        prd = NULL;
        module = NULL;    
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
    
    public void isProductLineSelected() {
    
        System.debug('-----------------The value of ProductLine selected is : ' + pls);
        System.debug('------In isProductLineSelected --------------- ' );
        prd=NULL;
        module=NULL;
        System.debug('-----------Module is set to NULL '+pls);
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
                list<Product2> productLists = [Select Id, Name, Product_Line__c, Parent_Product__c,Parent_Product__r.Name,(Select Id, Name from Versions__r where Active__c=true order By Name) from Product2 where (Id IN :prodIds or Parent_Product__c IN :prodIds) and Family = 'Software' and Is_Case_Supported__c = true]; 
                System.debug('-----Products found : ' + productLists);
                if(productLists!=NULL && productLists.size()>0) {
                    for(Product2 lP: productLists) {
                       
                        if(lP.Product_Line__c!=NULL) {                           
                            // Product --> version Map
                            if(lP.Versions__r != null) {
                                productVersionMap.put(lP.Id, lP.Versions__r);
                            }
                            if(!productLineMap.containsKey(lP.Product_Line__c)) {
                                List<Product2> ps = new List<Product2>();
                                ps.add(lp);
                                productLineMap.put(lP.Product_Line__c,ps);
                            } else {
                                List<Product2> ps = productLineMap.get(lP.Product_Line__c);
                                ps.add(lP);
                                productLineMap.put(lP.Product_Line__c,ps);   
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

        System.debug('------------in Product Line Items ----------- ' );
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
                        if(module != null && (!module.equalsIgnoreCase('BLANK')) && s.Id == module) {
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
    public List<SelectOption> getModuleNameItems() {
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
    
    
    // get Product items 
    public void getProductNameItems_new() {
        ProductItem = new List<SelectOption>();
        Set<String> prodIds = new Set<String>();
        if(pls!=NULL) {          
            list<Product2> ProductList = [Select Product_Line__c,Name, Parent_Product__c, Parent_Product__r.Name from Product2 where Family = 'Software' and Product_Line__c =: pls and Is_Case_Supported__c = true];
            for(Product2 prod : ProductList) {
                if(prod.Parent_Product__c != null) {    
                    if(!prodIds.contains(prod.Parent_Product__c)) {
                        ProductItem.add(new SelectOption(prod.Parent_Product__c,prod.Parent_Product__r.Name));
                        prodIds.add(prod.Parent_Product__c);
                    }
                } else {
                    if(!prodIds.contains(prod.Id)) {
                        ProductItem.add(new SelectOption(prod.Id,prod.Name));  
                        prodIds.add(prod.Id);  
                    }
                }
            }
        }  
        prodIds.clear(); 
        ProductItem = SortSelectOptions.selectOptionSortByLabel(ProductItem);    
        
    }
    
    // get Module items 
    public void getModuleItems_new() {
        ModuleItem = new List<SelectOption>();
        if(prd!=NULL) {
            list<Product2> ModuleList = [Select  Product_Line__c,Name from Product2 where Family = 'Software' and Parent_Product__c =: prd and Is_Case_Supported__c = true];
            for(Product2 moduleLine : ModuleList) {
                ModuleItem.add(new SelectOption(moduleLine.id,moduleLine.Name));
            } 
        }
        
        ModuleItem = SortSelectOptions.selectOptionSortByLabel(ModuleItem);    
        getProductVersionList();
    }
   
   //method to populate the Module Name Picklist
   public List<SelectOption>  getProductVersionList() {
        List<SelectOption> sortedList = new List<SelectOption>();
        List<SelectOption> selList = new List<SelectOption>(); 
        //List<SelectOptionWrapper> wrapperList = new List<SelectOptionWrapper>();
        List<Version__c> versionList;      
        if(prd!=NULL && !Test.IsRunningTest())
         {
            if(productVersionMap.containsKey(prd)) {
                versionList = productVersionMap.get(prd);                  
            } else {
                versionList = [Select Id,Name from Version__c where Product__c=:prd and Active__c=true  order by Name desc]; 
            }
            System.debug('versionList.....'+versionList);
            for(Version__c v : versionList) {
                //wrapperList.add(new SelectOptionWrapper(new SelectOption(v.Id,v.Name)));
                 selList.add(new SelectOption(v.Id,v.Name));       
            }            
        }
        sortedList = SelectOptionWrapper.selectOptionSortByLabel(selList);
        /*wrapperList.sort();
        for(SelectOptionWrapper sopt :wrapperList) {
            selList.add(sopt.oppy);
        }
        return selList;*/
        //SelectOptionSorter.doSort(sortedList, SelectOptionSorter.FieldToSort.Label);
        return sortedList;
    }
    
    public Pagereference productSelect() {
        String paramStr = '';
        
        
       if(prd != null && prd != '')
       {
           paramStr =  generateFieldsIds('Case', new list<String>{'Product','Product Version','Entitlement Name'});
           Pagereference pageRef = new Pagereference(paramStr);
           pageRef.setRedirect(true);
           return pageRef; 
       }
       else
       {
              ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a product.'));    
       }
                            
       return null;            
    }
    
    // get product Entitlement
    private Entitlement getCaseEntilement(String product2Id) {
        if(accountId != null  && product2Id != null) {
            Date nowDate = Date.today();
            List<Entitlement> caseEntlmnt = [SELECT Id, Name FROM Entitlement WHERE Licensed_Product__c IN (SELECT Id FROM Licensed_Product__c WHERE Account__c = :accountId AND Product_New__c = :product2Id) AND StartDate <= :nowDate  AND EndDate >= :nowDate AND status='Active' LIMIT 1];
           
            if(!caseEntlmnt.isEmpty()) {
                return caseEntlmnt.get(0);                
            } 
        }
        return null;
    } 
 
    // get Child Accounts
    public void getChilds() {
        childAccountIds = new Set<Id>();
        List<Account> childAccountLists = [Select Id from Account where parentId =:accountId ];
        System.debug('childAccountLists' + childAccountLists);
        if(childAccountLists!=NULL && childAccountLists.size()>=1) {
            for(Account a: childAccountLists) {
                childAccountIds.add(a.Id);                
            }
        }       
    }
    
    
    // get Account Entitlements
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


    //Generate fields
    private String generateFieldsIds(String objectName,list<String> fieldsLabelName) { 
        String url = '/' +  Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix() + '/e?nooverride=1';    
        if(null!= fieldsLabelName && fieldsLabelName.size() > 0) {
            PageReference p = new PageReference(url);
            String html = '';
            if(!System.Test.isRunningTest()) {
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
            }
            List<Product2> prodList; 
            List<Version__c> verList = new List<Version__c>();

            if(module != null && module != '')  {  
                prodList = [SELECT Id, Name,Parent_Product__c,Parent_Product__r.Name FROM Product2 WHERE Id =:module];
            } else {
                prodList = [SELECT Id, Name,Parent_Product__c,Parent_Product__r.Name FROM Product2 WHERE Id =:prd]; 
            }
            
            if(version != null && version.trim() != '') {
                verList = [SELECT Id, Name FROM Version__c WHERE Id =:version LIMIT 1];    
            }
            
            String paramStr = ''; 
            if(!prodList.isEmpty()) {
                Entitlement proEntl = getCaseEntilement(prodList.get(0).Id);
                             
                for(String fld:fieldsLabelName){                    
                    if(fld == 'Product'){
                        paramStr += labelToId.get(fld)+'='+ prodList.get(0).Name + '&';
                        paramStr += labelToId.get(fld)+'_lkid='+ prodList.get(0).Id + '&';
                    }else if(fld == 'Product Version' && (!verList.isEmpty())) {
                        paramStr += labelToId.get(fld) + '_lkid=' + verList.get(0).Id + '&';
                        paramStr += labelToId.get(fld) + '=' + verList.get(0).Name;
                    }
                    /*else if(fld == 'Entitlement Name' && proEntl != null) {
                        paramStr += labelToId.get(fld) + '=' + proEntl.Name + '&'; 
                        paramStr += labelToId.get(fld)+'_kid=' + proEntl.Id;   
                    } */
                }
            }
            system.debug('---------->>>>'+paramStr);
            if(paramStr.length() > 0) {
                //paramStr = paramStr.subString(1,paramStr.length());
                //paramStr = '/' + Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?' + paramStr;
                paramStr = url + '&'+ paramStr + '&retURL='+ '/' +  Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix() + '/o';     
                return paramStr;                      
            }
            
        }
        return url;
    }

    
    public Void SaveIdea() {
        
    }
}