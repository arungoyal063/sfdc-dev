public with sharing class OpptyLineItemEditControllerAll{
        
        public Opportunity opp {get;set;}
        public List<Wrapper> wrapList{get;set;}
        
        public List<OpportunityLineItem> optyLineItemList{get;set;}    
        private String pbEntryId = '';    
            
        public OpptyLineItemEditControllerAll(Apexpages.StandardController sc) 
        {   
            string oppId = sc.getId();
            opp = [Select Name, Id, Pricebook2Id  from Opportunity where Id =: oppId];
            
            optyLineItemList = [Select o.Unit_of_Measure__c, o.UnitPrice, o.TotalPrice, o.Style_Description__c, o.SortOrder,o.Size__c, o.Opportunity.Name, o.Sidemark__c, o.ServiceDate, o.Quantity, o.Product_Category__c, o.PricebookEntryId, o.OpportunityId, o.ListPrice, o.Id, o.Description, o.Color_Description__c, o.Bk__c, o.PricebookEntry.Product2Id, o.PricebookEntry.Product2.Name, o.PricebookEntry.UnitPrice,o.PricebookEntry.Product2.ProductCode  From OpportunityLineItem o Where OpportunityId =: opp.Id order by o.Color_Description__c ];
            
            Set<string> prodCatSet = new Set<string>();
            Set<string> styleSet = new Set<string>();
            Set<string> bkSet = new Set<string>();
            Set<string> uomSet = new Set<string>();
            Set<string> sizeSet = new Set<string>();
            for(OpportunityLineItem oli : optyLineItemList)
            {
                if(oli.Product_Category__c != '' && oli.Product_Category__c != null)
                {
                    prodCatSet.add(oli.Product_Category__c);
                }
                if(oli.Style_Description__c != '' && oli.Style_Description__c != null)
                {
                    styleSet.add(oli.Style_Description__c);
                }
                if(oli.Bk__c != '' && oli.Bk__c != null)
                {
                    bkSet.add(oli.Bk__c);
                }
                if(oli.Size__c != '' && oli.Size__c != null)
                {
                    sizeSet.add(oli.Size__c);
                }
                if(oli.Unit_of_Measure__c != '' && oli.Unit_of_Measure__c != null)
                {
                    uomSet.add(oli.Unit_of_Measure__c);
                }
            }
            if(optyLineItemList != null && optyLineItemList.size() > 0) 
            {
                List<PricebookEntry> allProductList = [Select Product2.Color_Description__c, Product2.Product_Category__c, Product2.Style_Description__c, Product2.Bk__c, Product2.Unit_of_Measurement__c, Product2.size__c From PricebookEntry Where IsActive = true and Product2.IsActive = true and Product2.Product_Category__c != null and Product2.Color_Description__c != null and Pricebook2Id = :opp.Pricebook2Id and Product2.Product_Category__c in:prodCatSet and Product2.Style_Description__c in:styleSet and Product2.Bk__c in:bkSet and Product2.Unit_of_Measurement__c in:uomSet and Product2.Size__c in: sizeSet order by Product2.Color_Description__c ];
                wrapList =  new List<Wrapper>();
                
                for(OpportunityLineItem oli: optyLineItemList)
                {
                    Set<string> colorDescSet =  new Set<string>(); //to avoid duplicate values
                    Wrapper w =  new Wrapper();
                    w.oli = oli;
                    w.colorDescOptions = new List<Selectoption>();
                    w.colorDescOptions.add(new Selectoption('', '--TBD--'));

                    for(PricebookEntry pbe : allProductList) 
                    {
                        string prodCat = pbe.Product2.Product_Category__c;
                        string style = pbe.Product2.Style_Description__c;
                        string bk = pbe.Product2.Bk__c;
                        string uom = pbe.Product2.Unit_of_Measurement__c;
                        string size = pbe.Product2.Size__c;
                        if(prodCat.equalsIgnoreCase(oli.Product_Category__c) && style.equalsIgnoreCase(oli.Style_Description__c) && bk.equalsIgnoreCase(oli.Bk__c) && uom.equalsIgnoreCase(oli.Unit_of_Measure__c ) && size.equalsIgnoreCase(oli.Size__c))
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
                    
                    if(oli.Color_Description__c == null || oli.Color_Description__c == '') 
                    {
                        w.isCustomProduct = true;
                    }
                    else
                    {
                        w.isCustomProduct = false;
                    }
                    
                    w.prodName = oli.PricebookEntry.Product2.Name;
                    pbEntryId = oli.PricebookEntryId;
                    if(oli.PricebookEntry.Product2.ProductCode != null) 
                    {
                        w.prodCode = oli.PricebookEntry.Product2.ProductCode;
                    }
                                    
                    wrapList.add(w);
                }
            }       
        }
        
        public void fetchProductCode() 
        {
            String oliId = System.currentPageReference().getParameters().get('oliSelected');
            Wrapper w = null;
            //get wrapper record///
            for(Wrapper w1:wrapList)
            {
                if(w1.oli.id == oliId)//get values
                {
                    w = w1; 
                }
            }
            if(w != null)
            {
                if(w.oli.Color_Description__c != null && w.oli.Color_Description__c != '') 
                {
                    List<PricebookEntry> productPEList = [select Id, Product2Id, Product2.ProductCode, Product2.Name From PricebookEntry Where IsActive = true and (Product2.Product_Category__c =:  w.oli.Product_Category__c AND Product2.Style_Description__c =: w.oli.Style_Description__c AND Product2.Bk__c =:  w.oli.Bk__c and Product2.size__c =: w.oli.Size__c  AND Product2.Color_Description__c =: w.oli.Color_Description__c  AND Product2.Unit_of_Measurement__c =: w.oli.Unit_of_Measure__c AND Product2.IsActive = true)];
                    if(productPEList != null && productPEList.size() > 0) 
                    {
                        w.prodName = productPEList[0].Product2.Name;
                        w.prodCode = productPEList[0].Product2.ProductCode;
                        pbEntryId = productPEList[0].Id;        
                    }
                } 
                else 
                {
                    w.prodName = w.oli.PricebookEntry.Product2.Name;
                    w.prodCode = '';
                    pbEntryId = w.oli.PricebookEntryId;
                }
            }
        }
        
        public Pagereference saveOLI() 
        {
            PageReference p;
            String hostName = Apexpages.currentPage().getHeaders().get('Host');
            String returnUrl = 'https://' + hostName + '/' + opp.Id ;
            List<OpportunityLineItem> oliToInsert =  new List<OpportunityLineItem>();
            List<OpportunityLineItem> oliToUpdate =  new List<OpportunityLineItem>();
            List<OpportunityLineItem> oliToDelete =  new List<OpportunityLineItem>();
            Boolean createOli = false;
            for(wrapper w: wrapList)
            {
                if(w.isCustomProduct && w.oli.PricebookEntryId != pbEntryId)
                {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.Unit_of_Measure__c = w.oli.Unit_of_Measure__c;
                    oli.UnitPrice = w.oli.UnitPrice;
                    oli.Style_Description__c = w.oli.Style_Description__c;
                    oli.Size__c = w.oli.Size__c;
                    oli.Sidemark__c = w.oli.Sidemark__c;
                    oli.ServiceDate = w.oli.ServiceDate;
                    oli.Quantity = w.oli.Quantity;
                    oli.PricebookEntryId = pbEntryId;
                    oli.OpportunityId = w.oli.OpportunityId;
                    oli.Description = w.oli.Description;
                    oli.Color_Description__c = w.oli.Color_Description__c;
                    oli.Bk__c = w.oli.Bk__c;
                    oliToInsert.add(oli);
                    oliToDelete.add(w.oli);
                }
                else
                {
                    oliToUpdate.add(w.oli);
                }
            }
            try 
            {
                delete oliToDelete;
                insert oliToInsert;
                update oliToUpdate;
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
            public OpportunityLineItem oli{get;set;}
            public List<SelectOption> colorDescOptions{get;set;}
            public boolean isCustomProduct{get;set;}
            public string prodName{get;set;}
            public string prodCode{get;set;}
        }
    }