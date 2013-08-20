public with sharing class QuoteLineItemController {
    public List<LineItem> lineItemList {get;set;}
    public Quote quote {get;set;}
    public QuoteLineItem qlineItem {get;set;}
    
    private List<Selectoption> productList = new List<Selectoption>();
    private List<String> pNameList = new List<String>();
    private String p_Name = '';
    private Integer i = 0;
    private Boolean priceBookIdAdded = false;
        // Ajay:Raimaker  
    private transient  List<PricebookEntry> productList23;
    private transient  Map<String,Set<String>> prodNamecatNameSetMap = new Map<String,Set<String>>();
    private transient  Map<String,Set<String>> catNameStyleDespSetMap = new Map<String,Set<String>>(); 
    private transient  Map<String,Set<String>> styleDespBKSetMap = new Map<String,Set<String>>();
    private transient  Map<String,Set<String>> bkSizeSetMap = new Map<String,Set<String>>();
    private transient  Map<String,Set<String>> sizeCOlorDesSetMap = new Map<String,Set<String>>();
    
    //private Boolean showColorDescMsg = true;
    
    public QuoteLineItemController(ApexPages.StandardController sc) {
    	try{
        lineItemList = new List<LineItem>();
        quote = new Quote();
        qlineItem = new QuoteLineItem();
        String id = Apexpages.currentPage().getParameters().get('id');
        if(id != null && id != '') quote = [Select Id, Name, Pricebook2Id From Quote Where Id =: id Limit 1];
        if(opportunity.Pricebook2Id == null) {
        	Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        	quote.Pricebook2Id = pb.Id;
        	priceBookIdAdded = true;
        }
        //Mohan - query to fetch only the active product's and which is having active price book entry
        //AggregateResult[] productList = [Select Product2.Product_Category__c prod From PricebookEntry Where IsActive = true and Product2.IsActive = true and Product2.Product_Category__c != null GROUP BY Product2.Product_Category__c ORDER BY Product2.Product_Category__c];
        /*----
            Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
            Date: 02/23/2013
        -----
        */
        AggregateResult[] productList = [Select Product2.Product_Category__c prod From PricebookEntry Where IsActive = true and Product2.IsActive = true and Product2.Product_Category__c != null GROUP BY Product2.Product_Category__c ORDER BY Product2.Product_Category__c];
        pNameList.add('PLEASE SELECT');
        for(AggregateResult ar : productList) {
            String protertyName = String.valueOf(ar.get('prod'));
            pNameList.add(protertyName);
        }
        /*----
            Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
            Date: 02/23/2013
        -----*/
        }catch(Exception e){System.debug('aja'+e.getMessage());}
            
        try{
            addRow();
        }catch(Exception e){System.debug('aja'+e.getMessage());}
        //showColorDescMsg = true;
    }
    
    public void addRow() {
        if(quote != null) {
            if(quote.Pricebook2Id != null) {
                if(productList.size() == 0) {
                    //productList.add(new Selectoption('', '--None--'));
                    i = 0;
                    for(String s : pNameList) {
                        if(i == 0) {
                            p_Name = 'PLEASE SELECT';
                            i++;
                        }
                        productList.add(new Selectoption(s, s));
                    }
                }
                Integer newRowIndex = lineItemList.size();
                LineItem lItem = new LineItem();
                lItem.prodName = p_Name;
                lItem.prodOptions = productList;
                lItem.rowIndex = newRowIndex;
                lineItemList.add(lItem);
                
                String newRowIndexStr = String.valueOf(newRowIndex);
                System.currentPageReference().getParameters().put('rIndex',newRowIndexStr);
                fetchStyleDesc();
            }// else {
             //   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected Quote is not assigned a Price Book. Kindly set Price Book firstly.');
             //   ApexPages.addMessage(msg);
            //}
        }
        
    }
    
    public void fetchStyleDesc() {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        String pName = lineItemList.get(integer.valueOf(rowIndex)).prodName;
        if(pName != null && pName != '' && pName!='PLEASE SELECT') {
            List<String> styleList = new List<String>();
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).styleDescOptions.clear();
            lineItemList.get(rIndex).bkOptions.clear();
            lineItemList.get(rIndex).sizeOptions.clear();
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).unitMeasureOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
            //lineItemList.get(rIndex).styleDescOptions.add(new Selectoption('', '--None--'));
            i = 0;
            String p_Style = '';
            /*
            ----
                Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
                Date: 02/23/2013
            -----
            */
            catNameStyleDespSetMap = ProductFetch.getStyleDesp(pName);
            List<String> uniquestyleDescList = new List<String>();
            uniquestyleDescList.addAll(catNameStyleDespSetMap.get(pName));
            uniquestyleDescList.sort();
            lineItemList.get(rIndex).styleDescOptions.add(new Selectoption('PLEASE SELECT', 'PLEASE SELECT'));
            for(String ar : uniquestyleDescList) {
                if(i == 0) {
                    p_Style = 'PLEASE SELECT';
                    i++;
                }
                lineItemList.get(rIndex).styleDescOptions.add(new Selectoption(ar, ar));
            }
            
            /*----
                Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
                Date: 02/23/2013
            -----*/
            System.currentPageReference().getParameters().put('rIndex', rowIndex);
            lineItemList.get(rIndex).qli.Style_Description__c = p_Style;
            fetchBk();
        } else {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).styleDescOptions.clear();
            lineItemList.get(rIndex).bkOptions.clear();
            lineItemList.get(rIndex).sizeOptions.clear();
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
        }
    }
    
    public void fetchBk() {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        System.debug('rowIndex:'+rowIndex);
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        if(styleDesc != null && styleDesc != '' && styleDesc != 'PLEASE SELECT') {
            List<String> styleList = new List<String>();
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).bkOptions.clear();
            lineItemList.get(rIndex).sizeOptions.clear();
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).unitMeasureOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
            //lineItemList.get(rIndex).bkOptions.add(new Selectoption('', '--None--'));
            i = 0;
            String p_Bk = '';
            /*----
                Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
                Date: 02/23/2013
            -----*/
            styleDespBKSetMap = ProductFetch.getBK(pName,styleDesc);
            List<String> uniquebkList = new List<String>();
            uniquebkList.addAll(styleDespBKSetMap.get(styleDesc+pName));
            uniquebkList.sort();
            lineItemList.get(rIndex).bkOptions.add(new Selectoption('PLEASE SELECT','PLEASE SELECT'));
            for(String bk : uniquebkList) {
                if(i == 0) {
                    p_Bk = 'PLEASE SELECT';
                    i++;
                }
                lineItemList.get(rIndex).bkOptions.add(new Selectoption(bk, bk));
            }
            
            /*----
                Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
                Date: 02/23/2013
            -----*/
            System.currentPageReference().getParameters().put('rIndex', rowIndex);
            lineItemList.get(rIndex).qli.Bk__c = p_Bk;
            fetchsize();
        } else {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).bkOptions.clear();
            lineItemList.get(rIndex).sizeOptions.clear();
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
        }
    }
    
    public void fetchsize() {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        System.debug('rowIndex:'+rowIndex);
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String bk = lItem.qli.Bk__c;
        if(bk != null && bk != ''&&  bk != 'PLEASE SELECT') {
            List<String> styleList = new List<String>();
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).sizeOptions.clear();
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).unitMeasureOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
            //lineItemList.get(rIndex).sizeOptions.add(new Selectoption('', '--None--'));
            i = 0;
            String p_Size = '';
            /*----
                Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
                Date: 02/23/2013
            -----*/
             bkSizeSetMap = ProductFetch.getProdSize( bk,  styleDesc,  pName);
                
            List<String> uniquesizeList = new List<String>();
            uniquesizeList.addAll(bkSizeSetMap.get(bk+styleDesc+pName));
            uniquesizeList.sort();
            lineItemList.get(rIndex).sizeOptions.add(new Selectoption('PLEASE SELECT', 'PLEASE SELECT'));
            for(String size : uniquesizeList) {
                if(i == 0) {
                    p_Size = 'PLEASE SELECT';
                    i++;
                }
                lineItemList.get(rIndex).sizeOptions.add(new Selectoption(size, size));
            }
            
            /*----
                Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
                Date: 02/23/2013
            -----*/
            System.currentPageReference().getParameters().put('rIndex', rowIndex);
            lineItemList.get(rIndex).qli.size__c = p_Size;
            fetchColorDesc();
        } else {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).sizeOptions.clear();
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
        }
    }
    
    public void fetchColorDesc() {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        System.debug('rowIndex:'+rowIndex);
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String bk = lItem.qli.Bk__c;
        String size = lItem.qli.Size__c;
        if(size != null && size != '' && size != 'PLEASE SELECT') {
            List<String> styleList = new List<String>();
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).unitMeasureOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
            //lineItemList.get(rIndex).colorDescOptions.add(new Selectoption('', '--None--'));
            i = 0;
            String p_Color = '';
            lineItemList.get(rIndex).colorDescOptions.add(new Selectoption('', '--TBD--'));
            /*----
                Ajay:rainmaker Code impletmented to avoid the SOQL Limit reached issue
                Date: 02/23/2013
            -----*/
            sizeCOlorDesSetMap = ProductFetch.getColordes(size,bk,styleDesc,pName);
            List<String> uniquesizeList = new List<String>();
            uniquesizeList.addAll(sizeCOlorDesSetMap.get(size+bk+styleDesc+pName));
            uniquesizeList.sort();
            for(String COlorDes : uniquesizeList) {
                lineItemList.get(rIndex).colorDescOptions.add(new Selectoption(COlorDes, COlorDes));
            }
            System.currentPageReference().getParameters().put('rIndex', rowIndex);
            lineItemList.get(rIndex).qli.Color_Description__c = p_Color;
            fetchUOM();
            //fetchProductCode();
        } else {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).colorDescOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
        }
    }
    
    public void fetchUOM() {
    	String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        System.debug('rowIndex:'+rowIndex);
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String bk = lItem.qli.Bk__c;
        String size = lItem.qli.Size__c;
        String color = lItem.qli.Color_Description__c;
        System.debug('color: '+color);
        if(color == null) {
        	color = '';
        	lItem.qli.Color_Description__c = '';
        }
        if(color != null) {
            List<String> styleList = new List<String>();
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).unitMeasureOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            i = 0;
            String p_UOM = '';
            AggregateResult[] productList;
            if(color != '') {
            	productList = [select Product2.Unit_of_Measurement__c uom From PricebookEntry Where IsActive = true and (Product2.Product_Category__c =: pName AND Product2.Style_Description__c = :styleDesc AND Product2.Bk__c = :bk and Product2.size__c =: size AND Product2.Color_Description__c = :color AND Product2.IsActive = true) and Product2.Unit_of_Measurement__c != null GROUP BY Product2.Unit_of_Measurement__c ORDER BY Product2.Unit_of_Measurement__c];
            } else {
            	productList = [select Product2.Unit_of_Measurement__c uom From PricebookEntry Where IsActive = true and (Product2.Product_Category__c =: pName AND Product2.Style_Description__c = :styleDesc AND Product2.Bk__c = :bk and Product2.size__c =: size AND Product2.IsActive = true) and Product2.Unit_of_Measurement__c != null GROUP BY Product2.Unit_of_Measurement__c ORDER BY Product2.Unit_of_Measurement__c];
            }
            for(AggregateResult ar : productList) {
            	String uom = String.valueOf(ar.get('uom'));
            	if(i == 0) {
                    p_UOM = uom;
                    i++;
                }
                lineItemList.get(rIndex).unitMeasureOptions.add(new Selectoption(uom, uom));
            }
            System.currentPageReference().getParameters().put('rIndex', rowIndex);
            lineItemList.get(rIndex).qli.Unit_of_Measure__c = p_UOM;
            fetchProductCode();
        } else {
            Integer rIndex = integer.valueOf(rowIndex);
            //lineItemList.get(rIndex).unitMeasureOptions.clear();
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
        }
    }
        
    public void fetchProductCode() {
        String rowIndex = System.currentPageReference().getParameters().get('rIndex');
        System.debug('rowIndex:'+rowIndex);
        LineItem lItem = lineItemList.get(integer.valueOf(rowIndex));
        String pName = lItem.prodName;
        String styleDesc = lItem.qli.Style_Description__c;
        String bk = lItem.qli.Bk__c;
        String size = lItem.qli.Size__c;
        String colorDesc = lItem.qli.Color_Description__c;
        String uom = lItem.qli.Unit_of_Measure__c;
        if(colorDesc == null) {
        	colorDesc = '';
        	lItem.qli.Color_Description__c = '';
        }
        List<Product2> pLst;
        List<PricebookEntry> pbeList;
        System.debug('colorDesc 123 ' +  colorDesc);
        Set<Id> productIds = new Set<Id>();
        if(colorDesc != '') 
        {
           //pLst = [select ProductCode, Id, Unit_of_Measurement__c From Product2 Where (Product_Category__c =: pName AND Style_Description__c = :styleDesc AND Color_Description__c = :colorDesc AND Bk__c = :bk AND IsActive = true and size__c =: size)];
           pbeList = [select Id, Product2Id, Product2.ProductCode, Product2.Unit_of_Measurement__c From PricebookEntry Where IsActive = true and (Product2.Product_Category__c =: pName AND Product2.Style_Description__c = :styleDesc AND Product2.Color_Description__c = :colorDesc AND Product2.Bk__c = :bk and Product2.size__c =: size AND Product2.Unit_of_Measurement__c = :uom AND Product2.IsActive = true) and Product2.ProductCode != null ORDER BY Product2.ProductCode];
        }
        else
        {
            //pLst = [select ProductCode, Id, Unit_of_Measurement__c From Product2 Where (Product_Category__c =: pName AND Style_Description__c = :styleDesc AND Bk__c = :bk AND IsActive = true and size__c =: size)];
            pbeList = [select Id, Product2Id, Product2.ProductCode, Product2.Unit_of_Measurement__c From PricebookEntry Where IsActive = true and (Product2.Product_Category__c =: pName AND Product2.Style_Description__c = :styleDesc AND Product2.Bk__c = :bk and Product2.size__c =: size AND Product2.Unit_of_Measurement__c = :uom AND Product2.IsActive = true) and Product2.ProductCode != null ORDER BY Product2.ProductCode];
            for(PricebookEntry pbe : pbeList) {
            	productIds.add(pbe.Product2Id);
            }
        }
        if(pbeList != null && pbeList.size() > 0) {
        	Integer rIndex = integer.valueOf(rowIndex);
        	if(colorDesc != '') {
	            lineItemList.get(rIndex).pCode = pbeList.get(0).Product2.ProductCode;
	            String prodId = pbeList.get(0).Product2Id;
	            lineItemList.get(rIndex).productId = prodId;
        	} else {
        		String customProductName = pName + '-Color TBD';
        		List<PricebookEntry> productBELst = [Select Product2Id From PricebookEntry Where Product2.Name =: customProductName];
        		if(productBELst != null && productBELst.size() > 0) {
        			lineItemList.get(rIndex).productId = productBELst[0].Product2Id;
        		}
        	}
        } else {
            Integer rIndex = integer.valueOf(rowIndex);
            lineItemList.get(rIndex).pCode = '';
            //lineItemList.get(rIndex).listPrice = 0.0;
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
    
    public Pagereference submit() {
        List<QuoteLineItem> qliInsertList = new List<QuoteLineItem>();
        String id = Apexpages.currentPage().getParameters().get('id');
        //PricebookEntry pbe = [Select Id From PricebookEntry limit 1];
        Set<String> pIds = new Set<String>();
        for(LineItem l : lineItemList) {
            if(l.productId != null && l.productId != '') pIds.add(l.productId);
        }
        Map<Id, String> pbeMap = new Map<Id, String>();
        List<PricebookEntry> pbeList = [Select Id, Product2Id From PricebookEntry Where Product2Id IN :pIds and IsActive = true];
        for(PricebookEntry p : pbeList) {
            pbeMap.put(p.Product2Id, p.Id);
        }
        Boolean requiredFieldMissing = false;
        for(LineItem l : lineItemList) {
            System.debug('l: ' + l);
            QuoteLineItem qli = l.qli;
            if((l.prodName != '' || l.prodName != null) && (qli.Style_Description__c != '' || qli.Style_Description__c != null) && (qli.Color_Description__c != '' || qli.Color_Description__c != null) && (qli.Bk__c != '' || qli.Bk__c != null) && (qli.Size__c != '' || qli.Size__c != null)) {
                if(id != null && id != '') qli.QuoteId = id;
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
                //if(requiredFieldMissing) break;
                qliInsertList.add(qli);
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
        String returnUrl = 'https://' + hostName + '/' + id;
        PageReference p = new PageReference(returnUrl);
        p.setRedirect(true);
        return p;
        //return null;
    }
    
    public class LineItem {
        //public Product2 product {get;set;}
        //public Sample_Product__c sProduct {get;set;}
        public QuoteLineItem qli {get;set;}
        public String prodName {get;set;}
        public List<Selectoption> prodOptions {get;set;}
        public List<Selectoption> styleDescOptions {get;set;}
        public List<Selectoption> colorDescOptions {get;set;}
        public List<Selectoption> bkOptions {get;set;}
        public List<Selectoption> sizeOptions {get;set;}
        public List<Selectoption> unitMeasureOptions {get;set;}
        public String pCode {get;set;}
        public Integer rowIndex {get;set;}
        public String productId {get;set;}
        //public Double listPrice {get;set;}
        
        public LineItem() {
            //product = new Product2();
            //sProduct = new Sample_Product__c();
            qli = new QuoteLineItem();
            prodName = '';
            productId = '';
            prodOptions = new List<Selectoption>();
            styleDescOptions = new List<Selectoption>();
            colorDescOptions = new List<Selectoption>();
            bkOptions = new List<Selectoption>();
            sizeOptions = new List<Selectoption>();
            unitMeasureOptions = new List<Selectoption>();
            pCode = '';
            /*
            Schema.Sobjecttype objType = Product2.getSObjectType();
	        Schema.Describesobjectresult sobjRes = objType.getDescribe();
	        Map<String, Schema.Sobjectfield> fieldMap = sobjRes.fields.getMap();
	        List<Schema.PicklistEntry> picklistvalues = fieldMap.get('Unit_of_Measurement__c').getDescribe().getPickListValues();
	        Integer i = 0;
	        for(Schema.PicklistEntry a : picklistvalues) {
	        	if(i == 0) qli.Unit_of_Measure__c = a.getLabel();
	        	unitMeasureOptions.add(new selectOption(a.getLabel(), a.getValue()));
	        	i++;
	      	}*/
	      	
            //listPrice = 0.0;
        }
    }
}