public with sharing class QuoteLineItemEditControllerAll {
        
        public Quote qte {get;set;}
        public List<Wrapper> wrapList{get;set;}
        
        public List<QuoteLineItem> quoteLineItemList{get;set;}    
        private String pbEntryId = '';    
            
        public QuoteLineItemEditControllerAll(Apexpages.StandardController sc) 
        {   
            string quotId = sc.getId();
            qte = [Select Name, Id, Pricebook2Id  from Quote where Id =: quotId];
            
            quoteLineItemList = [Select q.Unit_of_Measure__c, q.UnitPrice, q.TotalPrice, q.Style_Description__c, q.Size__c, q.Quote.Name, q.Sidemark__c, q.ServiceDate, q.Quantity, q.Product_Category__c, q.PricebookEntryId, q.QuoteId, q.ListPrice, q.Id, q.Description, q.Color_Description__c, q.Bk__c, q.PricebookEntry.Product2Id, q.PricebookEntry.Product2.Name, q.PricebookEntry.UnitPrice,q.PricebookEntry.Product2.ProductCode  From QuoteLineItem q Where QuoteId =: qte.Id order by q.Color_Description__c ];
            
            Set<string> prodCatSet = new Set<string>();
            Set<string> styleSet = new Set<string>();
            Set<string> bkSet = new Set<string>();
            Set<string> uomSet = new Set<string>();
            Set<string> sizeSet = new Set<string>();
            for(QuoteLineItem qli : quoteLineItemList)
            {
                if(qli.Product_Category__c != '' && qli.Product_Category__c != null)
                {
                    prodCatSet.add(qli.Product_Category__c);
                }
                if(qli.Style_Description__c != '' && qli.Style_Description__c != null)
                {
                    styleSet.add(qli.Style_Description__c);
                }
                if(qli.Bk__c != '' && qli.Bk__c != null)
                {
                    bkSet.add(qli.Bk__c);
                }
                if(qli.Size__c != '' && qli.Size__c != null)
                {
                    sizeSet.add(qli.Size__c);
                }
                if(qli.Unit_of_Measure__c != '' && qli.Unit_of_Measure__c != null)
                {
                    uomSet.add(qli.Unit_of_Measure__c);
                }
            }
            if(quoteLineItemList != null && quoteLineItemList.size() > 0) 
            {
                List<PricebookEntry> allProductList = [Select Product2.Color_Description__c, Product2.Product_Category__c, Product2.Style_Description__c, Product2.Bk__c, Product2.Unit_of_Measurement__c, Product2.size__c From PricebookEntry Where IsActive = true and Product2.IsActive = true and Product2.Product_Category__c != null and Product2.Color_Description__c != null and Pricebook2Id = :qte.Pricebook2Id and Product2.Product_Category__c in:prodCatSet and Product2.Style_Description__c in:styleSet and Product2.Bk__c in:bkSet and Product2.Unit_of_Measurement__c in:uomSet and Product2.Size__c in: sizeSet order by Product2.Color_Description__c ];
                wrapList =  new List<Wrapper>();
                
                for(QuoteLineItem qli: quoteLineItemList)
                {
                    Set<string> colorDescSet =  new Set<string>(); //to avoid duplicate values
                    Wrapper w =  new Wrapper();
                    w.qli = qli;
                    w.colorDescOptions = new List<Selectoption>();
                    w.colorDescOptions.add(new Selectoption('', '--TBD--'));

                    for(PricebookEntry pbe : allProductList) 
                    {
                        string prodCat = pbe.Product2.Product_Category__c;
                        string style = pbe.Product2.Style_Description__c;
                        string bk = pbe.Product2.Bk__c;
                        string uom = pbe.Product2.Unit_of_Measurement__c;
                        string size = pbe.Product2.Size__c;
                        if(prodCat.equalsIgnoreCase(qli.Product_Category__c) && style.equalsIgnoreCase(qli.Style_Description__c) && bk.equalsIgnoreCase(qli.Bk__c) && uom.equalsIgnoreCase(qli.Unit_of_Measure__c ) && size.equalsIgnoreCase(qli.Size__c))
                        {
                            String colorDesc = pbe.Product2.Color_Description__c;
                            colorDescSet.add(colorDesc);
                        }
                    }
                    //Need sorted list of Color Description
                    List<string> colorDescLst =  new List<string>();
                    colorDescLst.addAll(colorDescSet);
                    colorDescLst.sort();
                    
                    for(string s: colorDescLst)
                    {
                        w.colorDescOptions.add(new Selectoption(s, s));
                    }
                    
                    if(qli.Color_Description__c == null || qli.Color_Description__c == '') 
                    {
                        w.isCustomProduct = true;
                    }
                    else
                    {
                        w.isCustomProduct = false;
                    }
                    
                    w.prodName = qli.PricebookEntry.Product2.Name;
                    pbEntryId = qli.PricebookEntryId;
                    if(qli.PricebookEntry.Product2.ProductCode != null) 
                    {
                        w.prodCode = qli.PricebookEntry.Product2.ProductCode;
                    }
                                    
                    wrapList.add(w);
                }
            }       
        }
        
        public void fetchProductCode() 
        {
            String qliId = System.currentPageReference().getParameters().get('qliSelected');
            Wrapper w = null;
            //get wrapper record///
            for(Wrapper w1:wrapList)
            {
                if(w1.qli.id == qliId)//get values
                {
                    w = w1; 
                }
            }
            if(w != null)
            {
                if(w.qli.Color_Description__c != null && w.qli.Color_Description__c != '') 
                {
                    List<PricebookEntry> productPEList = [select Id, Product2Id, Product2.ProductCode, Product2.Name From PricebookEntry Where IsActive = true and (Product2.Product_Category__c =:  w.qli.Product_Category__c AND Product2.Style_Description__c =: w.qli.Style_Description__c AND Product2.Bk__c =:  w.qli.Bk__c and Product2.size__c =: w.qli.Size__c  AND Product2.Color_Description__c =: w.qli.Color_Description__c  AND Product2.Unit_of_Measurement__c =: w.qli.Unit_of_Measure__c AND Product2.IsActive = true)];
                    if(productPEList != null && productPEList.size() > 0) 
                    {
                        w.prodName = productPEList[0].Product2.Name;
                        w.prodCode = productPEList[0].Product2.ProductCode;
                        pbEntryId = productPEList[0].Id;        
                    }
                } 
                else 
                {
                    w.prodName = w.qli.PricebookEntry.Product2.Name;
                    w.prodCode = '';
                    pbEntryId = w.qli.PricebookEntryId;
                }
            }
        }
        
        public Pagereference saveQLI() 
        {
            PageReference p;
            String hostName = Apexpages.currentPage().getHeaders().get('Host');
            String returnUrl = 'https://' + hostName + '/' + qte.Id ;
            List<QuoteLineItem> qliToInsert =  new List<QuoteLineItem>();
            List<QuoteLineItem> qliToUpdate =  new List<QuoteLineItem>();
            List<QuoteLineItem> qliToDelete =  new List<QuoteLineItem>();
            Boolean createOli = false;
            for(wrapper w: wrapList)
            {
                if(w.isCustomProduct && w.qli.PricebookEntryId != pbEntryId)
                {
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.Unit_of_Measure__c = w.qli.Unit_of_Measure__c;
                    qli.UnitPrice = w.qli.UnitPrice;
                    qli.Style_Description__c = w.qli.Style_Description__c;
                    qli.Size__c = w.qli.Size__c;
                    qli.Sidemark__c = w.qli.Sidemark__c;
                    qli.ServiceDate = w.qli.ServiceDate;
                    qli.Quantity = w.qli.Quantity;
                    qli.PricebookEntryId = pbEntryId;
                    qli.QuoteId = w.qli.QuoteId;
                    qli.Description = w.qli.Description;
                    qli.Color_Description__c = w.qli.Color_Description__c;
                    qli.Bk__c = w.qli.Bk__c;
                    qliToInsert.add(qli);
                    qliToDelete.add(w.qli);
                }
                else
                {
                    qliToUpdate.add(w.qli);
                }
            }
            try 
            {
                delete qliToDelete;
                insert qliToInsert;
                update qliToUpdate;
                p = new PageReference(returnUrl);            
            } 
            catch(Exception ex) 
            {
                String errMsg = ex.getMessage();            
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
                ApexPages.addMessage(msg);
                p = null;
            }
            return p;
        }
        public class wrapper
        {
            public QuoteLineItem qli{get;set;}
            public List<SelectOption> colorDescOptions{get;set;}
            public boolean isCustomProduct{get;set;}
            public string prodName{get;set;}
            public string prodCode{get;set;}
        }
    }