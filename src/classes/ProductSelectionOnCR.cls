public with sharing class ProductSelectionOnCR {

    public Id accountId{get;set;}
    public List<Case> caseLists{get;set;}
    public List<Account> childAccountLists{get;set;}
    public List<Entitlement> entitlementLists{get;set;}
    public Boolean entitlementPresent{get;set;}
    public Set<Id> childAccountIds{get;set;}
    public List<String> productLineLists{get;set;}
    public List<String> productNameLists{get;set;}
    public transient List<String> moduleNameLists{get;set;}
    public String version{get;set;}
    public Map<String,List<Product2>> productLineMap{get;set;}
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
    // added code 
    public List<SelectOption> ProductLineItem{get;set;}
    public List<SelectOption> ProductItem{get;set;}
    public List<SelectOption> ModuleItem{get;set;}
    public List<SelectOption> VersionItem{get;set;}
    
    Set<Id> prodIds{get;set;}
    //Constructor
    public ProductSelectionOnCR(ApexPages.StandardController con){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        try {
            prodIds = new Set<Id>();
            CRId = ApexPages.CurrentPage().getParameters().get('id');
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
            
            ProductLineItem = new List<SelectOption>();
                        ProductItem = new List<SelectOption>();
                        ModuleItem = new List<SelectOption>();
                        VersionItem = new List<SelectOption>();
            this.prepareProductLines_New();
            
            String crId = ApexPages.currentPage().getParameters().get('Id');
            fillSelectedProduct(crId);
                       
           
        } catch(Exception e) {
            System.debug('------Exception : ' + e);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to select an Account before selecting the Product'));            
        }
    }
    
    
    /*
        @Param: Change Request Id
        @Desc: Select Already Selected Product on Product Selection
    */
    private void fillSelectedProduct(String crId) {
        if(crId != null && crId != '') {                
            List<Change_Request__C> CRList = [SELECT Id, Product__c, Product__r.Parent_Product__c, Product_Line__c, Product_Name__c, Module__c,Product_Release_Version__c,Found_in_Version__c  FROM Change_Request__C WHERE Id = :crId LIMIT 1]; 
            
            if(!CRList.isEmpty()) {
                Change_Request__C CRRecord = CRList.get(0);
                if(CRRecord.Product_Line__c != null) {
                    pls = CRRecord.Product_Line__c;
                }
                
               getProductNameItems_new();
               
               if(CRRecord.Module__c != null) {
                    if(CRRecord.Product__r.Parent_Product__c != null) {   
                        prd = CRRecord.Product__r.Parent_Product__c;
                        getModuleItems_new(); 
                    }
                    module = CRRecord.Product__c;   
                } else if(CRRecord.Product__c != null) {
                    prd = CRRecord.Product__c;    
                } 
                
               /*if(CRRecord.Product_Release_Version__c != null) {
                    version = CRRecord.Product_Release_Version__c;                    
               }*/
               try{
	               list<Version__c> versionList = new list<Version__c>([Select Id,Name from Version__c where Id=:CRRecord.Found_in_Version__c and Active__c=true]); 
		           if(!versionList.isEmpty()){
		            	version = versionList.get(0).Name;
		           }
               }catch(Exception e){
               		System.debug('Error>>>'+e);
               }
               /*if(CRRecord.Found_in_Version__c != null) {
                    version = '8.6';//CRRecord.Found_in_Version__c;     
                    System.debug('###########version : ' + version);               
               } */              
               getProductVersionList();   
            }          
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
    public void prepareProductLines_New() {
        
            ProductLineItem = new List<SelectOption>();
            
              
            //list<Product2> productLists = [Select Id, Name, Product_Line__c, Parent_Product__c,Parent_Product__r.Name,(Select Id,Name from Versions__r where Active__c=true) from Product2 where Family = 'Software'];
            list<AggregateResult> productLists = [Select  Product_Line__c from Product2 where Family = 'Software'and Product_Line__c != null and Is_Change_Request_Supported__c = true group by Product_Line__c];
            System.debug('...productLists...'+productLists);
            System.debug('...productLists...'+productLists.size());
            for(AggregateResult prodLine : productLists)
            {
                
                ProductLineItem.add(new SelectOption((String)prodLine.get('Product_Line__c'),(String)prodLine.get('Product_Line__c')));
                System.debug('.......'+String.valueOf(prodLine.get('Product_Line__c')));
            }
            
            ProductLineItem = SortSelectOptions.selectOptionSortByLabel(ProductLineItem);
    }
    
    public void getProductNameItems_new() {
        ProductItem = new List<SelectOption>();
        Set<String> prodIds = new Set<String>();
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
        //SelectOptionSorter.doSort(ProductItem, SelectOptionSorter.FieldToSort.Label);
        ProductItem = SortSelectOptions.selectOptionSortByLabel(ProductItem);
    }
    
    public void getModuleItems_new() {
        ModuleItem = new List<SelectOption>();
        
       module = null; 
       version = null;
       System.debug('prd....'+prd);
       
        if(prd!=NULL) {
            list<Product2> ModuleList = [Select  Product_Line__c,Name from Product2 where Family = 'Software' and Parent_Product__c =: prd and Is_Change_Request_Supported__c= true];
            
            System.debug('ModuleList/.....'+ModuleList.size());
             for(Product2 moduleLine : ModuleList)
            {
                ModuleItem.add(new SelectOption(moduleLine.id,moduleLine.Name));
            }
            System.debug('ModuleItem..........'+ModuleItem.size());
        }
       
         
         ModuleItem = SortSelectOptions.selectOptionSortByLabel(ModuleItem);  
        //SelectOptionSorter.doSort(ModuleItem, SelectOptionSorter.FieldToSort.Label);
          //SelectOptionSorter.doReverseSort(ModuleItem);
       // return options;
    }
    /*
    public void prepareProductLines() {
        try {
            List<String> prodLists = new List<String>();
            prodIds = new Set<Id>();
            productLineMap = new Map<String,List<Product2>>();
            System.debug('------In PrepareProductLines --------- ');
            //if(entitlementPresent) 
            {
              
                //List<Licensed_Product__c> productLists = [Select Id,Name, Product_Line__c, Product_New__c, Product_New__r.Name from Licensed_Product__c where Product_Line__c IN :prodLists];
//                list<Product2> productLists = [Select Id, Name, Product_Line__c, Parent_Product__c,Parent_Product__r.Name,(Select Id,Name from Versions__r where Active__c=true) from Product2 where (Id IN :prodIds or Parent_Product__c IN :prodIds) and Family = 'Software']; 
            list<Product2> productLists = [Select Id, Name, Product_Line__c, Parent_Product__c,Parent_Product__r.Name,(Select Id,Name from Versions__r where Active__c=true) from Product2 where Family = 'Software'];
                System.debug('-----Products found : ' + productLists);
                System.debug('-----Products size :'+productLists.size());
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
                            } else {
                                List<Product2> ps = productLineMap.get(lP.Product_Line__c);
                                ps.add(lP);
                                productLineMap.put(lP.Product_Line__c,ps);   
                            }
                        }
                    }
                }
                 
            }  
          
        } catch(Exception e) {
            System.debug('-------Exception ' + e);
        }
    }
    */
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
                        if(module != null && module != 'BLANK'  && s.Id == module) {
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
        //if(prd!=NULL && prodIds != null) 
        if(prd!=NULL)
        {
            List<Product2> moduleProducts = [SELECT Id,Name FROM Product2 WHERE Parent_Product__c = :prd AND Family = 'Software' and Is_Change_Request_Supported__c = true];
            
            System.debug('moduleProducts............'+moduleProducts.size());
            
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
        //if(prd!=NULL && prodIds != null)
        if(prd!=NULL)
         {
            if(productVersionMap.containsKey(prd)) {
                versionList = productVersionMap.get(prd);                  
            } else {
                versionList = [Select Id,Name from Version__c where Product__c=:prd and Active__c=true  order by Name desc]; 
            }
            System.debug('versionList.....'+versionList);
            for(Version__c v : versionList) {
                //wrapperList.add(new SelectOptionWrapper(new SelectOption(v.Name,v.Name)));
                options.add(new SelectOption(v.Name,v.Name));
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
        System.debug('-----Product Line : ' + pls);
        System.debug('-----Product Name : ' + prd);
        System.debug('-----Module : ' + module);
        System.debug('-----version : ' + version);
        
        Product2 prodDetails;
        Change_Request__c crObj;
        try
        {
            System.debug('CRId...............'+CRId);
            //Todo: removed field "Found_in_Release__c"
            crObj = [Select Product__c,Product_Release_Version__c,Found_in_Release__c from  Change_Request__c WHERE ID =: CRId];
            //System.debug('crObj........'+crObj);
            if(module != null) {
                crObj.Product__c = module;
            } else if(prd != null) {
               crObj.Product__c = prd;          
            }
            //crObj.Product_Release_Version__c = version;
            list<Version__c> versionList = new list<Version__c>([Select Id,Name from Version__c where Name=:version and Active__c=true]); 
            if(!versionList.isEmpty()){
            	crObj.Found_in_Version__c = versionList.get(0).Id;
            	version = versionList.get(0).Id;
            }
            update crObj;
        }
        catch (Exception ex)
        {
            System.debug('Exception ex...'+ex.getMessage());
        }
        
        redirectUrl = '/' + crObj.id;
    }
    
 
    static testMethod void ProdSelectionONCRUnitTest() {
         Change_Request__c c = MockTestData.createCRRecord('Test CR');  
         Account a = MockTestData.createAccountRecord('Test',100);
         Account childAcc = MockTestData.createAccountRecord('Test',100);
         Entitlement  en  = MockTestData.createEntlmntRecord('Test', a);
         Licensed_Product__c lp = MockTestData.createLPRecord('Test', a);
         Product2 pro = MockTestData.createProductRecord('Test');        
         pro.Product_Line__c = 'Test';
         update pro;
         
         ApexPages.CurrentPage().getParameters().put('id', c.Id);
         ApexPages.StandardController con = new ApexPages.StandardController(c);
         ProductSelectionOnCR cp = new ProductSelectionOnCR(con);
         cp.doCancel();
         cp.selectProuduct();
         cp.selectProuduct();
         cp.isProductLineSelected();
         cp.isProductSelected();
         cp.getProductLineItems();
         cp.pls = 'Test';
         cp.getProductNameItems();
         cp.getProductNameItems_New();
         cp.getModuleItems_new();
         cp.getProductVersionList();
         cp.prd = pro.Id;
         cp.getModuleNameItems();
         cp.productSelect();
      
         
    }
    
}