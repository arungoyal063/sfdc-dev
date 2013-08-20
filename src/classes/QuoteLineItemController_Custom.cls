public with sharing class QuoteLineItemController_Custom {
    public List<LineItem> lineItemList {get;set;}
    public Quote quote {get;set;}
    public QuoteLineItem qlineItem {get;set;}
    
    private List<Selectoption> productList = new List<Selectoption>();
    
    private List<String> pNameList = new List<String>();
    private String p_Name = '';
    private Integer i = 0;
    private Boolean priceBookIdAdded = false;
    string productName; 
    
    public QuoteLineItemController_Custom(ApexPages.StandardController sc) 
    {
        AddProductSetting__c x = AddProductSetting__c.getInstance();           
        productName = x.Custom_Product_Name__c;
        lineItemList = new List<LineItem>();
        quote = new Quote();
        qlineItem = new QuoteLineItem();
        String qId = Apexpages.currentPage().getParameters().get('addTo');
        if(qId == null) qId = Apexpages.currentPage().getParameters().get('id');
        if(qId != null && qId != '') quote = [Select Id, Name, Pricebook2Id From Quote Where Id =: qId Limit 1];
        if(quote.Pricebook2Id == null) 
        {
            Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
            quote.Pricebook2Id = pb.Id;
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
        if(quote != null) 
        {
            if(quote.Pricebook2Id != null) 
            {
                p_Name = '';
                Integer newRowIndex = lineItemList.size();
                LineItem lItem = new LineItem();
                lItem.prodName = p_Name;                
                lItem.rowIndex = newRowIndex;
                //lineItemList.get(newRowIndex).qli.Product_Category_New__c = p_Name;
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
        lineItemList.get(rIndex).qli.Style_Description__c = p_Style;
        fetchBk();
    }
    
    public void fetchBk() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');        
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String p_Bk = '';        
         Integer rIndex = integer.valueOf(rowIndex);
        System.currentPageReference().getParameters().put('rIndex', rowIndex);
        lineItemList.get(rIndex).qli.Bk__c = p_Bk;
        fetchsize();        
    }
    
    public void fetchsize() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');       
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String bk = lItem.qli.Bk__c;
        String p_Size = '';    
 Integer rIndex = integer.valueOf(rowIndex);        
        System.currentPageReference().getParameters().put('rIndex', rowIndex);
        lineItemList.get(rIndex).qli.size__c = p_Size;
        fetchColorDesc();        
    }
    
    public void fetchColorDesc() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');       
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String bk = lItem.qli.Bk__c;
        String size = lItem.qli.Size__c;
        String p_Color = '';
         Integer rIndex = integer.valueOf(rowIndex);
        System.currentPageReference().getParameters().put('rIndex', rowIndex);
        lineItemList.get(rIndex).qli.Color_Description__c = p_Color;
        fetchProductCode();        
    }
        
    public void fetchProductCode() 
    {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');        
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String bk = lItem.qli.Bk__c;
        String size = lItem.qli.Size__c;
        String colorDesc = lItem.qli.Color_Description__c;       
        List<Product2> pLst = [select ProductCode, Id, Unit_of_Measurement__c From Product2 Where Name =:productName];
        if(pLst != null && pLst.size() > 0) 
        {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).pCode = plst.get(0).ProductCode;
            String prodId = plst.get(0).Id;
            lineItemList.get(rIndex).productId = prodId;            
            //String unitMsre = plst.get(0).Unit_of_Measurement__c;           
            String unitMsre = '';           
            if(unitMsre != null && unitMsre != '') lineItemList.get(rIndex).qli.Unit_of_Measure__c = unitMsre;          
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
      List<QuoteLineItem> qliInsertList = new List<QuoteLineItem>();
        String qId = Apexpages.currentPage().getParameters().get('addTo');
        if(qId == null) qId = Apexpages.currentPage().getParameters().get('id');        
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
            QuoteLineItem qli = l.qli; 
            l.prodName = qli.Product_Category_New__c;       
            if((l.prodName != '' && l.prodName != null) && (qli.Style_Description__c != '' && qli.Style_Description__c != null) && (qli.Bk__c != '' && qli.Bk__c != null) && (qli.Size__c != '' && qli.Size__c != null))
            {
                if(qId != null && qId != '') qli.QuoteId = qId;                
                if(l.productId != null && l.productId != '' && pbeMap.get(l.productId) != null) qli.PricebookEntryId = pbeMap.get(l.productId);
                else continue;
                if(qli.UnitPrice == null) {
                    requiredFieldMissing = true;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Selling Price cannot be null');
                    ApexPages.addMessage(msg);
                    break;
                }
                if(qli.Quantity == null) {
                    requiredFieldMissing = true;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be null');
                    ApexPages.addMessage(msg);
                    break;
                }
                System.debug('add qli');
                qliInsertList.add(qli);
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
        if(qliInsertList.size() > 0) {
            insert qliInsertList;
            if(priceBookIdAdded) {
                update quote;
            }           
        }
        String hostName = Apexpages.currentPage().getHeaders().get('Host');
        String returnUrl = 'https://' + hostName + '/' + qId;
        PageReference p = new PageReference('/'+qId);
        p.setRedirect(true);
        return p;        
    }
    
    public class LineItem 
    {
        public QuoteLineItem qli {get;set;}
        public String prodName {get;set;}        
        public String pCode {get;set;}
        public Integer rowIndex {get;set;}
        public String productId {get;set;}
        public LineItem() 
        {
            qli = new QuoteLineItem();
            prodName = '';
            productId = '';        
            pCode = '';
            qli.Unit_of_Measure__c = '';            
        }
    }
}