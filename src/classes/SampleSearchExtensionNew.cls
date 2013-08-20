/*********************************************************************************************************************
* Module Name   :  SampleSearchExtensionNew
* Description   :  Sample_Order__c Controller Extension
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <Test_AccountExtension>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      2/27/2013       Algoworks     1255     Initial Version
*******************************************************************************************************************/
public with sharing class SampleSearchExtensionNew {
        
    //public List<SelectOption> availableFields{get;set;}
    //public List<SelectOption> opraters{get;set;}
    //List of Selected Sample Products
    public List<ExtendedProduct> selectedSampleProducts {get;set;}
    public SOQLQueryFilterResult FilterResult {get; set;}
    public SObject Object2Filter {get; set;}
        
           
    //String for Quick Search
    public string quickSearch{get;set;}
    //List of Filters to Apply
    //public List<SearchCriteria> searchCriteria{get;set;}
    
    //Listing of Search Found Sample Products
    //public List<ExtendedProduct> searchFoundSampleProducts{get;set;}
    //Map of Field Names and Description of that field
    Map<String,Schema.SObjectField> fields;
        
    
        
    public SampleSearchExtensionNew(ApexPages.StandardController controller) 
    {
        selectedSampleProducts = new List<ExtendedProduct>();
        init(true);
        FilterResult = new SOQLQueryFilterResult();
        FilterResult.WhereConditionString = '';
       
        Object2Filter = new Sample_Product__c();
        
    }
    
    public void init(boolean isRunFromConstructor){
        selectedSampleProducts = new List<ExtendedProduct>();
        if(isRunFromConstructor){
                for(Sample_Product__c objSampleProduct:[SELECT color_code__c,style_desc__c, style_code__c, SKU__c, Product_Category__c,size__c, color_desc__c,Active__c From Sample_Product__c WHERE Active__c =:true Limit 50]){
                        selectedSampleProducts.add(new ExtendedProduct(objSampleProduct));
                }
        }
    }
    
     public pageReference onSearch(){
     system.debug('quicksearch'+quickSearch);
     system.debug('FilterResult.WhereConditionString'+FilterResult.WhereConditionString);
     system.debug('FilterResult.WhereConditionString length'+FilterResult.WhereConditionString.length());
     
        String soql = '';
        if(('' == FilterResult.WhereConditionString) && (quickSearch == null && quickSearch.trim() == '')){
                init(true);
                return null;
        }else{ 
            if(quickSearch.trim() != '' && (FilterResult.WhereConditionString == '' || FilterResult.WhereConditionString.length()<2 )){
                    soql = 'SELECT color_code__c,style_desc__c, style_code__c, SKU__c, Product_Category__c,size__c, color_desc__c,Active__c FROM Sample_Product__c WHERE Active__c =true AND color_code__c ='+'\''+String.escapeSingleQuotes(quickSearch.trim())+'\''+' order by color_code__c ';//Product_Category__c like \'%'+String.escapeSingleQuotes(quickSearch)+'%\' OR       
            }else if(FilterResult.WhereConditionString.length() > 1 && quickSearch.trim() == '' ){
                    soql = 'SELECT color_code__c,style_desc__c, style_code__c, SKU__c, Product_Category__c,size__c, color_desc__c,Active__c FROM Sample_Product__c WHERE Active__c =true AND '+FilterResult.WhereConditionString;
            }else if(quickSearch.trim() != '' && FilterResult.WhereConditionString.length()>1){
                soql = 'SELECT color_code__c,style_desc__c, style_code__c, SKU__c, Product_Category__c,size__c, color_desc__c,Active__c FROM Sample_Product__c WHERE Active__c =true AND '+FilterResult.WhereConditionString +' AND color_code__c ='+'\''+String.escapeSingleQuotes(quickSearch.trim())+'\''+' order by color_code__c ';//Product_Category__c like \'%'+String.escapeSingleQuotes(quickSearch)+'%\' OR
            }else{
                soql = 'SELECT color_code__c,style_desc__c, style_code__c, SKU__c, Product_Category__c,size__c, color_desc__c,Active__c FROM Sample_Product__c WHERE Active__c =true';
            }
        }
        try{
            system.debug('-------------------'+soql);
            list<Sample_Product__c> objSampleProduct = Database.query(soql+' LIMIT 50');
            selectedSampleProducts = new list<ExtendedProduct>();
            for(Sample_Product__c sp:objSampleProduct){
                selectedSampleProducts.add(new ExtendedProduct(sp));
            }
        }catch(exception e){
            System.debug('Error:'+e.getMessage());
        }
         system.debug('selectedSampleProducts'+selectedSampleProducts);
        return null;
    }
    
            
    
    public class ExtendedProduct{
        public Boolean Action{get;set;}
        public Sample_Product__c Product{get;set;}
        public ExtendedProduct(Sample_Product__c product)
        {
                this.Action = false;
                this.Product = product;
        }
    }
    
}