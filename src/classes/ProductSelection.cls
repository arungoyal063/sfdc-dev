/*******************************************************************************************************************
** Module Name   : ProdSelection
** Description   : Controller for the popup page to help the user select the correct product.
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-02-05  AC                    Initial Version
******************************************************************************************************************/

    public with sharing class ProductSelection { 
   
    public List<SelectOption> themeOptions{get; set;}    
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
 
    public List<SelectOption> ProductLineItem{get;set;}
    public List<SelectOption> ProductItem{get;set;}
    public List<SelectOption> ModuleItem{get;set;}
    public List<SelectOption> VersionItem{get;set;}
    public List<SelectOption> commList{get;set;}
    public String commu{get;set;}
    public String selComm{get;set;}
    public String selTheme{get;set;}
    public Idea ideaRecord{get;set;}
    private Map<String,Community> communityMap;
    private String caseId;
   
    public ProductSelection(ApexPages.StandardController stdController){
        try {
            ideaRecord = (Idea)stdController.getRecord(); 
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
            themeOptions = new List<SelectOption>();
            
            caseId = ApexPages.currentPage().getParameters().get('caseid');
            if(caseId != null && caseId != '') {
            	communityMap = new Map<String,Community>();
		        List<community> tempCommList = [SELECT Id, Name,IsActive,Description FROM Community WHERE IsActive = true];
		        for(community comm : tempCommList){
		            communityMap.put(comm.Name,comm); 
		        }
                caseId = ApexPages.currentPage().getParameters().get('caseid');
                List<Case> caseList = [SELECT Id,Resolution_Summary__c,AccountId,Subject,Problem_Statement__c,ProductId, Product.Name, Product.Idea_Community__c, Description, Product_Version__c, Product_Version__r.Name FROM Case WHERE Id = :caseId];
                
                if(!caseList.isEmpty() && caseList.get(0).ProductId != null) {
                      List<Community> commList = [SELECT Name,IsActive,Description FROM Community WHERE Name =: caseList.get(0).Product.Idea_Community__c and IsActive = true LIMIT 1];
                      if(commList.isEmpty()) {
                      	  //START added for ISSUE#245 - Ideas Created from Product, Not Module 
                      	  list<Product2> tempProductList = [Select Module__c, Name, Idea_Community__c, Parent_Product__c, Parent_Product__r.Idea_Community__c from Product2 where Id=:caseList.get(0).Product.Id];
		              	  if(tempProductList[0].Module__c && tempProductList[0].Parent_Product__c != null && tempProductList[0].Parent_Product__r.Idea_Community__c != null){
		 					selComm = communityMap.get(tempProductList[0].Parent_Product__r.Idea_Community__c).Name;
		                  }
		                  else{
		                    selComm = communityMap.get('Catch All').Name;
		                  }
		                  //END added for ISSUE#245 - Ideas Created from Product, Not Module
		                  //commList  = [SELECT Name,IsActive,Description FROM Community WHERE Name =:selComm and IsActive = true LIMIT 1];
                      }
                      else{
                      	selComm = commList.get(0).Name;
                      }
                      if(!commList.isEmpty()) {
                          ideaRecord.Case__c = caseList.get(0).Id;
                          ideaRecord.CommunityId = commList.get(0).Id;
                          
                          ideaRecord.Title = caseList.get(0).Subject;
                          ideaRecord.Body  = caseList.get(0).Description;
                          
                          if((caseList.get(0).Resolution_Summary__c != null) && (!caseList.get(0).Resolution_Summary__c.trim().equals(''))) {
                               ideaRecord.Business_Purpose__c =  caseList.get(0).Resolution_Summary__c;
                          } else {
                              ideaRecord.Business_Purpose__c =  'Created from Case. Please update this field.';        
                          }
                          
                          if(caseList.get(0).ProductId !=null)
                              ideaRecord.Idea_Product__c  = caseList.get(0).ProductId;
                          
                          if(caseList.get(0).Product_Version__c !=null)
                              ideaRecord.Version__c  = caseList.get(0).Product_Version__c;
          
                          if(caseList.get(0).AccountId !=null)
                               ideaRecord.Institution__c  = caseList.get(0).AccountId;
                               
                          
                               
                          ideaRecord.Status  = 'New';
                          commu = commList.get(0).Id;
                          //selComm = commList.get(0).Name;
                          //fillIdeaThemes();
                      }   
                }
            } else {
                this.prepareProductLines_New();
                this.fetchcommList();
            }
        } catch(Exception e) {
            System.debug('------Exception : ' + e);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to select an Account before selecting the Product'));            
        }
    }
    
    
    public Pagereference doCancel() {
        pls = NULL;
        prd = NULL;
        module = NULL; 
        if(caseId != null && caseId != '') {
            Pagereference cPage = new Pagereference('/' + caseId);
            cPage.setRedirect(true);
            return cPage;   
        }
        Pagereference cPage1 = new Pagereference('/ideas/ideaList.apexp');
        cPage1.setRedirect(false);
        return cPage1;
        //return null;
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
             SelectOptionSorter.doSort(ProductLineItem, SelectOptionSorter.FieldToSort.Label);
    }
    
     public void fetchcommList() {
        commList = new List<SelectOption>();
        communityMap = new Map<String,Community>();
        communityMap = new Map<String,Community>([SELECT Name,IsActive,Description FROM Community WHERE IsActive = true]);
        for(String commId: communityMap.keySet()) {
            commList.add(new SelectOption(commId,communityMap.get(commId).Name));
        }
        
        commList = SortSelectOptions.selectOptionSortByLabel(commList); 
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
       
        ProductItem = SortSelectOptions.selectOptionSortByLabel(ProductItem);  
    }
    
    public void getModuleItems_new() {
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
        VersionItem = new List<SelectOption>(); 
        List<Version__c> versionList;      
        if(prd!=NULL)
         {
            if(productVersionMap.containsKey(prd)) {
                versionList = productVersionMap.get(prd);                  
            } else {
                versionList = [Select Id,Name from Version__c where Product__c=:prd and Active__c=true  order by Name desc]; 
            }
            System.debug('versionList.....'+versionList);
            for(Version__c v : versionList) {
                VersionItem.add(new SelectOption(v.Id,v.Name));        
            }
            //SelectOptionSorter.doSort(VersionItem, SelectOptionSorter.FieldToSort.Label);            
        }
    }
    
    public Pagereference productSelect() {
        String paramStr = '';
        System.debug('-----Product Line : ' + pls);
        System.debug('-----Product Name : ' + prd);
        System.debug('-----Module : ' + module);
        System.debug('-----commu : ' + commu);
        
       //fillIdeaThemes();
        
        communityMap = new Map<String,Community>();
        List<community> commList = [SELECT Id, Name,IsActive,Description FROM Community WHERE IsActive = true];
        for(community comm : commList){
            communityMap.put(comm.Name,comm); 
        } 
        list<Product2> ProductList = [Select Product_Line__c,Name,Idea_Community__c, Parent_Product__c, Parent_Product__r.Name from Product2 where Family = 'Software' and Id=:prd and Product_Line__c =: pls and Is_Change_Request_Supported__c = true];
                
        if(prd != null && ProductList[0].Idea_Community__c != null)
           {
                //ideaRecord= new Idea();
                if(module != null) {
                     ideaRecord.Idea_Product__c = module;    
                } else {
                    ideaRecord.Idea_Product__c = prd;
                }
                
                if(version != null && version != '') {
                    ideaRecord.Version__c =  version;
                }
                system.debug(ProductList[0].Idea_Community__c);
                ideaRecord.CommunityId = communityMap.get(ProductList[0].Idea_Community__c).Id;
                selComm = communityMap.get(ProductList[0].Idea_Community__c).Name;
                /*selComm
                if(!communityMap.isEmpty() && communityMap.containsKey(ideaRecord.CommunityId)) {
                    selComm = communityMap.get(ideaRecord.CommunityId).Name;
                }*/
                Pagereference idaePage = new Pagereference('/apex/CreateIdea');
                idaePage.setRedirect(false);
                return idaePage;
            }
            else
            {               
                if(!ProductList.isEmpty() && ProductList[0].Idea_Community__c == null){
                    //ideaRecord= new Idea();
                    if(module != null) {
                         ideaRecord.Idea_Product__c = module;    
                    } else {
                        ideaRecord.Idea_Product__c = prd;
                    }                   
                    if(version != null && version != ''){
                    	System.debug('>>>>>>>>>>>>'+version);
                        ideaRecord.Version__c =  version;
                    }
                    //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Product does not contain an Idea Zone.'));  
                    if(!Test.isRunningTest()){
                    	ideaRecord.CommunityId = communityMap.get('Catch All').Id;
                    }
                    selComm = communityMap.get('Catch All').Name;
                    Pagereference idaePage = new Pagereference('/apex/CreateIdea');
                    idaePage.setRedirect(false);
                    return idaePage;
                }
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a product for Idea.'));    
            }
                            
            return null;            
    }
 // code for Idea Creation
 
 

    public PageReference saveIdea() {
        
        if(ideaRecord != null) {
            if(ideaRecord.Title == null || ideaRecord.Title.trim().equals('')) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter Title!'));   
                
            } 
            else if(ideaRecord.Business_Purpose__c == null || ideaRecord.Business_Purpose__c.trim().equals('')) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter Business Purpose!'));         
                
            }
            else{
                try {
                    if(selTheme != null && selTheme.trim() != '') {
                        //ideaRecord.IdeaThemeId = selTheme;
                    }
                    insert ideaRecord;
                    PageReference page = new PageReference('/ideas/viewIdea.apexp?id='+ ideaRecord.Id);
                    page.setRedirect(true);
                    return page;
                } catch(Exception e) {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));   
                }
            }  
        }
         return null;
    }
     
    
    // fill Idea Themes according  to Community
    /*public void fillIdeaThemes() {
         if(commu != null) {
            themeOptions = new List<SelectOption>(); 
            themeOptions.add(new SelectOption('','-- Select --'));
            List<IdeaTheme> themeList = [Select Id,Title from IdeaTheme where CommunityId = :commu];    
            System.debug('**' + themeList);
            for(IdeaTheme theme :themeList) {
                themeOptions.add(new SelectOption(theme.Id, theme.Title));
            }   
        }
    }*/
    
}