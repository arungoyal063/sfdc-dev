public with sharing class OpptyLineItemController_Custom
{
    public List<LineItem> lineItemList {get;set;}
    public Opportunity opportunity {get;set;}
    public OpportunityLineItem olineItem {get;set;}
    
    private List<Selectoption> productList = new List<Selectoption>();
    
    private List<String> pNameList = new List<String>();
    private String p_Name = '';
    private Integer i = 0;
    private Boolean priceBookIdAdded = false;
    string productName; 
    
    public OpptyLineItemController_Custom(ApexPages.StandardController sc) 
    {
        AddProductSetting__c x = AddProductSetting__c.getInstance();           
        productName = x.Custom_Product_Name__c;
        lineItemList = new List<LineItem>();
        opportunity = new Opportunity();
        olineItem = new OpportunityLineItem();
        String opId = Apexpages.currentPage().getParameters().get('addTo');
        if(opId == null) opId = Apexpages.currentPage().getParameters().get('id');
        if(opId != null && opId != '') opportunity = [Select Id, Name, Pricebook2Id From Opportunity Where Id =: opId Limit 1];
        if(opportunity.Pricebook2Id == null) 
        {
            Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
            opportunity.Pricebook2Id = pb.Id;
            priceBookIdAdded = true;
        }     
        AggregateResult[] productList = [select count(Id), Name prod From Product2 Where IsActive = true and Name =: productName GROUP BY Name ORDER BY Name];
        System.debug('SIZE CHECK ' + productList.size());
        for(AggregateResult ar : productList) {
            String protertyName = String.valueOf(ar.get('prod'));
            pNameList.add(protertyName);
        }
        addRow();
    }
    
    public void addRow() 
    {
        if(opportunity != null) 
        {
            if(opportunity.Pricebook2Id != null) 
            {
                p_Name = '';
                Integer newRowIndex = lineItemList.size();
                LineItem lItem = new LineItem();
                lItem.prodName = p_Name;                
                lItem.rowIndex = newRowIndex;
                //lineItemList.get(newRowIndex).oli.Product_Category_New__c = p_Name;
                lineItemList.add(lItem);
                String newRowIndexStr = String.valueOf(newRowIndex);
                System.currentPageReference().getParameters().put('rIndex',newRowIndexStr);
                fetchStyleDesc();
            }
        }        
    }
    
    public void fetchStyleDesc() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        String pName = lineItemList.get(integer.valueOf(rowIndex)).prodName;            
        String p_Style = '';
          Integer rIndex = integer.valueOf(rowIndex);
        System.currentPageReference().getParameters().put('rIndex', rowIndex);
        lineItemList.get(rIndex).oli.Style_Description__c = p_Style;
        fetchBk();
    }
    
    public void fetchBk() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');        
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.oli.Style_Description__c;
        String p_Bk = '';        
         Integer rIndex = integer.valueOf(rowIndex);
        System.currentPageReference().getParameters().put('rIndex', rowIndex);
        lineItemList.get(rIndex).oli.Bk__c = p_Bk;
        fetchsize();        
    }
    
    public void fetchsize() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');       
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.oli.Style_Description__c;
        String bk = lItem.oli.Bk__c;
        String p_Size = '';    
 Integer rIndex = integer.valueOf(rowIndex);        
        System.currentPageReference().getParameters().put('rIndex', rowIndex);
        lineItemList.get(rIndex).oli.size__c = p_Size;
        fetchColorDesc();        
    }
    
    public void fetchColorDesc() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');       
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.oli.Style_Description__c;
        String bk = lItem.oli.Bk__c;
        String size = lItem.oli.Size__c;
        String p_Color = '';
         Integer rIndex = integer.valueOf(rowIndex);
        System.currentPageReference().getParameters().put('rIndex', rowIndex);
        lineItemList.get(rIndex).oli.Color_Description__c = p_Color;
        fetchProductCode();        
    }
        
    public void fetchProductCode() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');        
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.oli.Style_Description__c;
        String bk = lItem.oli.Bk__c;
        String size = lItem.oli.Size__c;
        String colorDesc = lItem.oli.Color_Description__c;       
        List<Product2> pLst = [select ProductCode, Id, Unit_of_Measurement__c From Product2 Where Name =:productName];
        if(pLst != null && pLst.size() > 0) 
        {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).pCode = plst.get(0).ProductCode;
            String prodId = plst.get(0).Id;
            lineItemList.get(rIndex).productId = prodId;            
            //String unitMsre = plst.get(0).Unit_of_Measurement__c;           
            String unitMsre = '';           
            if(unitMsre != null && unitMsre != '') lineItemList.get(rIndex).oli.Unit_of_Measure__c = unitMsre;          
        }       
        else 
        {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).pCode = '';         
        }
    }
    
    public void deleteRow() {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        System.debug('rowIndex:'+rowIndex);
        if(rowIndex != null && rowIndex != '') {
            List<LineItem> temp = new List<LineItem>();
            temp = lineItemList;
            temp.remove(integer.valueOf(rowIndex));
            //lineItemList.clear();
            lineItemList = temp;
        }
    }
    
    public Pagereference submit() 
    {
      List<OpportunityLineItem> oliInsertList = new List<OpportunityLineItem>();
        String opId = Apexpages.currentPage().getParameters().get('addTo');
        if(opId == null) opId = Apexpages.currentPage().getParameters().get('id');        
        Set<String> pIds = new Set<String>();       
        for(LineItem l : lineItemList) {
            if(l.productId != null && l.productId != '') pIds.add(l.productId);
        }
        System.debug('LINE ITEM 1 ' + pIds.size());
        Map<Id, String> pbeMap = new Map<Id, String>();
        List<PricebookEntry> pbeList = [Select Id, Product2Id From PricebookEntry Where Product2Id IN :pIds];
        for(PricebookEntry p : pbeList) {
            pbeMap.put(p.Product2Id, p.Id);
        }
        Boolean requiredFieldMissing = false;
        for(LineItem l : lineItemList) 
        {
            OpportunityLineItem oli = l.oli; 
            l.prodName = oli.Product_Category_New__c;       
            if((l.prodName != '' && l.prodName != null) && (oli.Style_Description__c != '' && oli.Style_Description__c != null) && (oli.Bk__c != '' && oli.Bk__c != null) && (oli.Size__c != '' && oli.Size__c != null))
            {
                if(opId != null && opId != '') oli.OpportunityId = opId;                
                if(l.productId != null && l.productId != '' && pbeMap.get(l.productId) != null) oli.PricebookEntryId = pbeMap.get(l.productId);
                else continue;
                if(oli.UnitPrice == null) {
                    requiredFieldMissing = true;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Selling Price cannot be null');
                    ApexPages.addMessage(msg);
                    break;
                }
                if(oli.Quantity == null) {
                    requiredFieldMissing = true;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be null');
                    ApexPages.addMessage(msg);
                    break;
                }
                System.debug('add oli');
                oliInsertList.add(oli);
            }
            else
            {
                requiredFieldMissing = true;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the values for Product Category, Style Description, BK and Size before proceeding.');
                ApexPages.addMessage(msg);  
break;              
            }
        }
        if(requiredFieldMissing) return null;
        if(oliInsertList.size() > 0) {
            insert oliInsertList;
            if(priceBookIdAdded) {
                update opportunity;
            }           
        }
        String hostName = Apexpages.currentPage().getHeaders().get('Host');
        String returnUrl = 'https://' + hostName + '/' + opId;
        PageReference p = new PageReference('/'+opId);
        p.setRedirect(true);
        return p;        
    }
    
    public class LineItem 
    {
        public OpportunityLineItem oli {get;set;}
        public String prodName {get;set;}        
        public String pCode {get;set;}
        public Integer rowIndex {get;set;}
        public String productId {get;set;}
        public LineItem() 
        {
            oli = new OpportunityLineItem();
            prodName = '';
            productId = '';        
            pCode = '';
            oli.Unit_of_Measure__c = '';            
        }
    }
}