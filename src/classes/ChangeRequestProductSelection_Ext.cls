/*******************************************************************************************************************
** Module Name   : ChangeRequestProductSelection_Ext
** Description   : Controller to help user select the correct product from Change Request Page.
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
public with sharing class ChangeRequestProductSelection_Ext { 
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
    
      
    public ChangeRequestProductSelection_Ext(ApexPages.StandardController controller) {
         try {
            
           
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
            this.prepareProductLines_New(); 
        } catch(Exception e) {
            System.debug('------Exception : ' + e);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));            
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
        
        ProductItem = SortSelectOptions.selectOptionSortByLabel(ProductItem);
    }
    
    public void getModuleItems_new() {
        ModuleItem = new List<SelectOption>();
        if(prd!=NULL) {
            list<Product2> ModuleList = [Select  Product_Line__c,Name from Product2 where Family = 'Software' and Parent_Product__c = :prd and Is_Change_Request_Supported__c = true];
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
            System.debug('versionList.....'+versionList);
                      
            for(Version__c v : versionList) {
                //wrapperList.add(new SelectOptionWrapper(new SelectOption(v.Name,v.Name)));
                VersionItem.add(new SelectOption(v.Name,v.Name));
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
        System.debug('-----commu : ' + commu);
                
            if(prd != null){
                //Map<String, String>   fieldValueMap = new Map<String, String>();   
                //fieldValueMap.put('Product',prd);  
                //String CRurl = getUrlFieldMapped(fieldValueMap);         
                //Pagereference idaePage = new Pagereference(CRurl +'&retUrl=' + Change_request__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
                Pagereference pr = new Pagereference(generateFieldsIds('Change_Request__c',new list<String>{'Product','Found in Release','Found in Version'}));
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
            list<Version__c > versionList1;
            List<Product2> prodList; 
            if(module != null && module != '')  {  
                prodList = [SELECT Id, Name,Parent_Product__c,Parent_Product__r.Name FROM Product2 WHERE Id =:module];
            } else {
                prodList = [SELECT Id, Name,Parent_Product__c,Parent_Product__r.Name FROM Product2 WHERE Id =:prd]; 
            }
            if(version != null && version !=''){
               versionList1 = [Select Id,Name from Version__c where Name=:version and Active__c = true]; 
            }
            String paramStr = '';              
            for(String fld:fieldsLabelName){
                
                if(fld == 'Product'){
                    paramStr += labelToId.get(fld)+'_lkid='+ prodList.get(0).Id + '&';
                    paramStr += labelToId.get(fld)+'='+ prodList.get(0).Name + '&';
                }/*else if(fld == 'Found in Release' && version != null) {                
                    paramStr += labelToId.get(fld) + '=' + version;
                }*/
                if(fld == 'Found in Version' && version != null) {                
                    paramStr += labelToId.get(fld)+'_lkid='+versionList1.get(0).Id +'&';//productVersionMap.get(prodList.get(0).Name).get(0).Id;
                    paramStr += labelToId.get(fld) + '='+versionList1.get(0).Name;
                }
            }
            system.debug('---------->>>>'+paramStr);
            if(paramStr.length() > 0) {
                //paramStr = paramStr.subString(1,paramStr.length());
                //paramStr = '/' + Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?' + paramStr;
                paramStr = url + '&RecordType=' +  selectedRecordType  +'&'+ paramStr + '&retURL='+ '/' +  Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix() + '/o';     
                return paramStr;                      
            }
            
        }
        return url;
    }

    //Record Types for CR
    public list<selectOption> getRecordTypes{
        get{
            if(getRecordTypes == null){
                getRecordTypes = new list<selectOption>();
				Schema.DescribeSObjectResult d = Schema.SObjectType.Change_Request__c; 
				Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
				for(RecordType rt1:[SELECT Id,Name FROM RecordType WHERE SobjectType='Change_Request__c']){
					Schema.RecordTypeInfo rtById =  rtMapById.get(rt1.id);
					if(rtById.isAvailable()){ 
						getRecordTypes.add(new selectOption(rtById.getRecordTypeId(),rtById.getName()));
						if(rtById.isDefaultRecordTypeMapping()){
							selectedRecordType = rtById.getRecordTypeId();
						}
					}
				}
                /*for(RecordType  rt:[Select SobjectType, Name, Id From RecordType WHERE SobjectType ='Change_Request__c']){
                    getRecordTypes.add(new selectOption(rt.Id,rt.Name));
                    if(rt.Name.equalsIgnoreCase('Defect')) {
                        selectedRecordType = rt.Id;
                    }
                }*/ 
            }
            return getRecordTypes;
        }private set;
    }
}