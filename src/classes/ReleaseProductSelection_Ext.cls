/*******************************************************************************************************************
** Module Name   : ReleaseProductSelection_Ext
** Description   : Controller to help user select the correct product from Release Page.
** Throws        : NA
** Calls         : NA
** Test Class    : Test_ChangeRequestProductSelection
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-02-05  AC                    Initial Version
******************************************************************************************************************/
public with sharing class ReleaseProductSelection_Ext { 

    public String selectedRecordType{get;set;} 
    public String version{get;set;}
    public String productLineSelected{get;set;}
    public String productNameSelected{get;set;}
    public Boolean isProdLineSelected{get;set;}
    public Boolean isProdSelected{get;set;}
    public String pls{get;set;}
    public String prd{get;set;}
    public String module{get;set;}
    public Product2 finalProductSelected{get;set;}
    public String editButtonLabel{get;set;}
    private Map<String,List<Version__c>> productVersionMap;
    public String fProductSelected{get;set;} //to show the selected product on the VF page
    public List<SelectOption> productLineOptions = new List<SelectOption>();
    public String redirectUrl {get; private set;}
    private Entitlement caseEntitlement;
    private Map<String, String> paramMap;
    public Boolean isEditMode{get; set;}
    public List<SelectOption> ProductLineItem{get;set;}
    public List<SelectOption> ProductItem{get;set;}
    public List<SelectOption> ModuleItem{get;set;}
    public List<SelectOption> VersionItem{get;set;}
    public List<SelectOption> commList{get;set;}
    public Releases__c relRecord;
     
    // constructor
    public ReleaseProductSelection_Ext(ApexPages.StandardController controller) {
         try {
            productVersionMap = new Map<String,List<Version__c>>();           
            fProductSelected= NULL;
            editButtonLabel = 'Edit';
            isProdSelected = false;
            isProdLineSelected = false;
            productLineSelected = NULL;
            productNameSelected = NULL;
            pls = NULL;
            prd = NULL;
            module = NULL;
            finalProductSelected = NULL;
            isEditMode = false;
            
            ProductLineItem = new List<SelectOption>();
            ProductItem = new List<SelectOption>();
            ModuleItem = new List<SelectOption>();
            VersionItem = new List<SelectOption>();  
            
            if(ApexPages.currentPage().getParameters().size() > 0){          
                 paramMap = ApexPages.currentPage().getParameters();
                 if(paramMap.containsKey('sfdc.override')) {
                    paramMap.remove('sfdc.override');
                 } 
                 if(paramMap.containsKey('save_new')) {
                    paramMap.remove('save_new');
                 }     
            }
            
            this.prepareProductLines_New();
            String releaseId = ApexPages.currentPage().getParameters().get('Id');
            fillSelectedProduct(releaseId);
              
        } catch(DMLException e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));                
        } catch(Exception e) {
            System.debug('------Exception : ' + e);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));            
        }
    }
    
    
     /*
        @Param: Release Id
        @Desc:  Show Already Selected Product on Product Selection
    */
    private void fillSelectedProduct(String releaseId) {
        if(releaseId != null && releaseId != '') {
            isEditMode = true;                
            List<Releases__c> relList = [SELECT Id, Product__c, Product__r.Parent_Product__c, Product_Line__c, Product_Name__c, Module__c, Version__c  FROM Releases__c WHERE Id = :releaseId LIMIT 1];  
            
             if(!relList.isEmpty()) {
                relRecord = relList.get(0);
                if(relRecord.Product_Line__c != null) {
                    pls = relRecord.Product_Line__c;
                }
                getProductNameItems_new();
        
                if(relRecord.Product__r.Parent_Product__c != null) {   
                    prd = relRecord.Product__r.Parent_Product__c;
                }                    
                else if(relRecord.Product__c != null) {
                    prd = relRecord.Product__c;    
                } 
                getModuleItems_new();
               
                if(relRecord.Module__c != null) {
                   module = relRecord.Product__c; 
                }                
                if(relRecord.Version__c != null) {
                    version = relRecord.Version__c;                    
                } 
                getProductVersionList();   
            }          
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
    
    // get Product Lines
    public void prepareProductLines_New() {
        ProductLineItem = new List<SelectOption>();
        list<AggregateResult> productLists = [Select  Product_Line__c from Product2 where Family = 'Software'and Product_Line__c != null and Is_Change_Request_Supported__c = true group by Product_Line__c];
       
        for(AggregateResult prodLine : productLists) {
            ProductLineItem.add(new SelectOption((String)prodLine.get('Product_Line__c'),(String)prodLine.get('Product_Line__c')));
        }
        ProductLineItem = SortSelectOptions.selectOptionSortByLabel(ProductLineItem);    
    }
    
      
    // get Product Item Names
    public void getProductNameItems_new() {
        ProductItem = new List<SelectOption>();
        Set<String> prodIds = new Set<String>();
        prd = null;
        if(pls!=NULL) {          
            list<Product2> ProductList = [Select Product_Line__c,Name, Parent_Product__c, Parent_Product__r.Name from Product2 where Family = 'Software' and Product_Line__c =: pls and Is_Change_Request_Supported__c = true];
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
    
    // get Product Modules
    public void getModuleItems_new() {
        module = null;
        version = null;
        ModuleItem = new List<SelectOption>();
        if(prd!=NULL) {
            list<Product2> ModuleList = [Select  Product_Line__c,Name from Product2 where Family = 'Software' and Parent_Product__c =: prd and Is_Change_Request_Supported__c = true];
            for(Product2 moduleLine : ModuleList) {
                ModuleItem.add(new SelectOption(moduleLine.id,moduleLine.Name));
            } 
        }
        ModuleItem = SortSelectOptions.selectOptionSortByLabel(ModuleItem);
        getProductVersionList();
    }
   
    
   
    //method to populate the Module Name Picklist
   public void getProductVersionList() {
        List<SelectOption> sortedList = new List<SelectOption>();
        VersionItem = new List<SelectOption>();
        //List<SelectOptionWrapper> wrapperList = new List<SelectOptionWrapper>();  
        List<Version__c> versionList;      
        
        if(prd!=NULL)
         {
            if(productVersionMap.containsKey(prd)) {
                versionList = productVersionMap.get(prd);                  
            } else {
                versionList = [Select Id,Name from Version__c where Product__c=:prd and Active__c=true  order by Name desc]; 
            }
                                  
            for(Version__c v : versionList) {
                //wrapperList.add(new SelectOptionWrapper(new SelectOption(v.Id,v.Name)));
                VersionItem.add(new SelectOption(v.Id,v.Name));
            }
        }
        
        sortedList = SelectOptionWrapper.selectOptionSortByLabel(VersionItem);
        VersionItem = sortedList;
        /*wrapperList.sort();
        for(SelectOptionWrapper sopt :wrapperList) {
            VersionItem.add(sopt.oppy);
        }*/
   }
    
    
    public Pagereference odNext() {
        System.debug('-----Product Line : ' + pls);
        System.debug('-----Product Name : ' + prd);
        System.debug('-----Module : ' + module);
        
            if(prd != null){
                //Map<String, String>   fieldValueMap = new Map<String, String>();   
                //fieldValueMap.put('Product',prd);  
                //String CRurl = getUrlFieldMapped(fieldValueMap);         
                //Pagereference idaePage = new Pagereference(CRurl +'&retUrl=' + Change_request__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
                Pagereference pr = new Pagereference(generateFieldsIds('Releases__c',new list<String>{'Product','Version'}));
                if(!paramMap.isEmpty()) {
                    pr.getParameters().putAll(paramMap);
                }
                pr.setRedirect(true);
                return pr;
            }
            else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a product!'));    
            }                            
            return null;            
    }
    
    //Generate fields
    private String generateFieldsIds(String objectName,list<String> fieldsLabelName) { 
        String url = '/' +  Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix() + '/e?nooverride=1';    
        if(null!= fieldsLabelName && fieldsLabelName.size() > 0) {
            PageReference p = new PageReference(url);
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
            }
            
            List<Product2> prodList;
            List<Version__c> verList; 
            if(module != null && module != '')  {  
                prodList = [SELECT Id, Name,Parent_Product__c,Parent_Product__r.Name FROM Product2 WHERE Id =:module];
            } else {
                prodList = [SELECT Id, Name,Parent_Product__c,Parent_Product__r.Name FROM Product2 WHERE Id =:prd]; 
            }
            
            if(version != null) {
                verList = [SELECT Id, Name FROM Version__c WHERE Id =:version LIMIT 1];
            }
            if(!prodList.isEmpty()) {
                String paramStr = '';              
                for(String fld:fieldsLabelName) {
                    
                    if(fld == 'Product'){
                        paramStr += labelToId.get(fld)+'_lkid='+ prodList.get(0).Id + '&';
                        paramStr += labelToId.get(fld)+'='+ prodList.get(0).Name + '&';
                        
                    }else if(fld == 'Version' && verList != null && (!verList.isEmpty())) {
                        paramStr += labelToId.get(fld) + '_lkid=' + verList.get(0).Id + '&';
                        paramStr += labelToId.get(fld) + '=' + verList.get(0).Name;
                    }
                }
                system.debug('---------->>>>'+paramStr);
                if(paramStr.length() > 0) {
                    //paramStr = paramStr.subString(1,paramStr.length());
                    //paramStr = '/' + Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?' + paramStr;
                    
                    if(selectedRecordType != null && selectedRecordType.trim() != '') {
                        url += '&RecordType=' +  selectedRecordType;
                    }
                    paramStr = url +'&'+ paramStr + '&retURL='+ '/' +  Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix() + '/o';     
                    return paramStr;                      
                }
            }
        }
        return url;
    }

    //Record Types for CR
    public list<selectOption> getRecordTypes {
        get{
            if(getRecordTypes == null) {
                getRecordTypes = new list<selectOption>();
                for(RecordType  rt:[Select SobjectType, Name, Id From RecordType WHERE SobjectType ='Releases__c']){
                
                    getRecordTypes.add(new selectOption(rt.Id,rt.Name));
                } 
            }
            return getRecordTypes;
        }private set;
    }
    
    public void doCancel() {
         if(relRecord != null) {   
            if(relRecord.Product_Line__c != null) {
                pls = relRecord.Product_Line__c;
            }
            getProductNameItems_new();
    
            if(relRecord.Product__r.Parent_Product__c != null) {   
                prd = relRecord.Product__r.Parent_Product__c;
            }                    
            else if(relRecord.Product__c != null) {
                prd = relRecord.Product__c;    
            } 
            getModuleItems_new();
           
            if(relRecord.Module__c != null) {
               module = relRecord.Product__c; 
            }                
            if(relRecord.Version__c != null) {
                version = relRecord.Version__c;                    
            } 
            getProductVersionList();   
        }              
    }
    
    public void saveProudct() {
        System.debug('-----Product Line : ' + pls);
        System.debug('-----Product Name : ' + prd);
        System.debug('-----Module : ' + module);
         
        try
        {
            if(module != null) {
                relRecord.Product__c = module;
            } else if(prd != null) {
               relRecord.Product__c = prd;          
            }
            if(version != null) {
                relRecord.Version__c = version; 
            }
            update relRecord;
        }
        catch (Exception ex)
        {
            System.debug('Exception ex...' + ex.getMessage());
        }
        redirectUrl = '/' + relRecord.id;
    }
}