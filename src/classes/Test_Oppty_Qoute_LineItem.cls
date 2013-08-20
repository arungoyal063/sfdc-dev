/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_Oppty_Qoute_LineItem {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        List<RecordType> aRecType = [Select Id From RecordType Where sObjectType='Account'];
        Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.RecordTypeId = aRecType.get(0).Id;
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Oppty';
        o.AccountId = a.Id;
        o.StageName = 'Samples Submitted';
        o.CloseDate = Date.today().addDays(5);
        o.Pricebook2Id = pb.Id;
        insert o;
        System.debug('o: '+o);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Category__c = 'Test Product';
        p.ProductCode = 'TP';
        p.Bk__c = 'TT';
        p.Color_Description__c = 'Test RED';
        p.IsActive = true;
        p.Size__c = '160Z';
        p.Style_Description__c = 'Test Style';
        p.SKU__c = 'sku';
        p.Unit_of_Measurement__c = 'SF';
        insert p;        
        
        Product2 p1 = new Product2();
        p1.Name = 'Test Product1';
        p1.Product_Category__c = 'Test Product';
        p1.ProductCode = 'TP';
        p1.Bk__c = 'TT';
        p1.Color_Description__c = 'Test RED';
        p1.IsActive = true;
        p1.Size__c = '160Z';
        p1.Style_Description__c = 'Test Style';
        p1.SKU__c = 'sku1';
        p1.Unit_of_Measurement__c = 'SF';
        insert p1;
           
        List<Product2> op = [SELECT name, ID, Product_Category__c FROM Product2 where Name = 'Test Product1' LIMIT 1];       
        op[0].Product_Category__c = 'Modular';       
        update op;
        p1.IsActive = false;
        //op[0].Product_Category__c = 'Modular';       
        update op;
        Delete op;
           
        PricebookEntry pbe;
        try {            
            pbe = new PricebookEntry();
            pbe.Product2Id = p.Id;
            pbe.Pricebook2Id = pb.Id;
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            insert pbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
        
        Apexpages.currentPage().getParameters().put('id',o.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(o);
        OpptyLineItemController optty = new OpptyLineItemController(sc);
        optty.opportunity.Pricebook2Id = pb.Id;
        optty.addRow();
        System.currentPageReference().getParameters().put('rIndex', '0');
        optty.lineItemList.get(0).prodName = 'Test Product';
        optty.fetchStyleDesc();
        optty.lineItemList.get(0).prodName = '';
        optty.fetchStyleDesc();
        optty.lineItemList.get(0).prodName = 'Test Product';
        optty.fetchStyleDesc();
        
        optty.lineItemList.get(0).oli.Style_Description__c = 'Test Style';
        optty.fetchBk();
        optty.lineItemList.get(0).oli.Style_Description__c = '';
        optty.fetchBk();
        optty.lineItemList.get(0).oli.Style_Description__c = 'Test Style';
        optty.fetchBk();
        
        optty.lineItemList.get(0).oli.Bk__c = 'TT';
        optty.fetchsize();
        optty.lineItemList.get(0).oli.Bk__c = '';
        optty.fetchsize();
        optty.lineItemList.get(0).oli.Bk__c = 'TT';
        optty.fetchsize();
        
        optty.lineItemList.get(0).oli.Size__c = '160Z';
        optty.fetchColorDesc();
        optty.lineItemList.get(0).oli.Size__c = '';
        optty.fetchColorDesc();
        optty.lineItemList.get(0).oli.Size__c = '160Z';
        optty.fetchColorDesc();
        
        optty.lineItemList.get(0).oli.Color_Description__c = 'Test RED';
        optty.fetchUOM();
        optty.lineItemList.get(0).oli.Color_Description__c = '';
        optty.fetchUOM();
        optty.lineItemList.get(0).oli.Color_Description__c = 'Test RED';
        optty.fetchUOM();
        
        optty.lineItemList.get(0).oli.Unit_of_Measure__c = 'SF';
        optty.fetchProductCode();
        
        optty.lineItemList.get(0).oli.Quantity = 19;
        optty.lineItemList.get(0).oli.UnitPrice = 14;
        
        Apexpages.currentPage().getParameters().put('id',o.Id);
        optty.submit();
    }
    
    
    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        
        List<RecordType> aRecType = [Select Id From RecordType Where sObjectType='Account'];
        Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.RecordTypeId = aRecType.get(0).Id;
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Oppty';
        o.AccountId = a.Id;
        o.StageName = 'Samples Submitted';
        o.CloseDate = Date.today().addDays(5);
        o.Pricebook2Id = pb.Id;
        insert o;
        System.debug('o: '+o);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Category__c = 'Test Product';
        p.ProductCode = 'TP';
        p.Bk__c = 'TT';
        p.Color_Description__c = 'Test RED';
        p.IsActive = true;
        p.Size__c = '160Z';
        p.Style_Description__c = 'Test Style';
        p.SKU__c = 'sku';
        p.Unit_of_Measurement__c = 'SF';
        insert p;
        
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.OpportunityId = o.Id;
        q.Pricebook2Id = pb.Id;
        insert q;
        
        PricebookEntry pbe;
        try {
            pbe = new PricebookEntry();
            pbe.Product2Id = p.Id;
            pbe.Pricebook2Id = pb.Id;
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            insert pbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
        
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(q);
        QuoteLineItemController qte = new QuoteLineItemController(sc);
        
        test.startTest();
    
        qte.quote.Pricebook2Id = pb.Id;
        qte.addRow();
        System.currentPageReference().getParameters().put('rIndex', '0');
        qte.lineItemList.get(0).prodName = 'Test Product';
        qte.fetchStyleDesc();
        qte.lineItemList.get(0).prodName = '';
        qte.fetchStyleDesc();
        qte.lineItemList.get(0).prodName = 'Test Product';
        qte.fetchStyleDesc();
        
        qte.lineItemList.get(0).qli.Style_Description__c = 'Test Style';
        qte.fetchBk();
        qte.lineItemList.get(0).qli.Style_Description__c = '';
        qte.fetchBk();
        qte.lineItemList.get(0).qli.Style_Description__c = 'Test Style';
        qte.fetchBk();
        
        qte.lineItemList.get(0).qli.Bk__c = 'TT';
        qte.fetchsize();
        qte.lineItemList.get(0).qli.Bk__c = '';
        qte.fetchsize();
        qte.lineItemList.get(0).qli.Bk__c = 'TT';
        qte.fetchsize();
        
        qte.lineItemList.get(0).qli.Size__c = '160Z';
        qte.fetchColorDesc();
        qte.lineItemList.get(0).qli.Size__c = '';
        qte.fetchColorDesc();
        qte.lineItemList.get(0).qli.Size__c = '160Z';
        qte.fetchColorDesc();
        
        qte.lineItemList.get(0).qli.Color_Description__c = 'Test RED';
        qte.fetchUOM();
        qte.lineItemList.get(0).qli.Color_Description__c = '';
        qte.fetchUOM();
        qte.lineItemList.get(0).qli.Color_Description__c = 'Test RED';
        qte.fetchUOM();
        
        qte.lineItemList.get(0).qli.Unit_of_Measure__c = 'SF';
        qte.fetchProductCode();
        
        qte.lineItemList.get(0).qli.Quantity = 19;
        qte.lineItemList.get(0).qli.UnitPrice = 14;
        
        Apexpages.currentPage().getParameters().put('id',q.Id);
        qte.submit();
        
        Apexpages.currentPage().getParameters().put('id',q.Id);
        Apexpages.Standardcontroller sc1 = new Apexpages.Standardcontroller(o);
        QuoteLineItemController_Custom quote_custom = new QuoteLineItemController_Custom(sc1);
        quote_custom.quote.Pricebook2Id = pb.Id;
        quote_custom.addRow();
        System.currentPageReference().getParameters().put('rIndex', '0');
        quote_custom.lineItemList.get(0).prodName = 'Test Product 1';
        quote_custom.fetchStyleDesc();
        quote_custom.lineItemList.get(0).prodName = '';
        quote_custom.fetchStyleDesc();
        quote_custom.lineItemList.get(0).prodName = 'Test Product 1';
        quote_custom.fetchStyleDesc();
        
        quote_custom.lineItemList.get(0).qli.Style_Description__c = 'Test Style';
        quote_custom.fetchBk();
        quote_custom.lineItemList.get(0).qli.Style_Description__c = '';
        quote_custom.fetchBk();
        quote_custom.lineItemList.get(0).qli.Style_Description__c = 'Test Style';
        quote_custom.fetchBk();
        
        quote_custom.lineItemList.get(0).qli.Bk__c = 'TT';
        quote_custom.fetchsize();
        quote_custom.lineItemList.get(0).qli.Bk__c = '';
        quote_custom.fetchsize();
        quote_custom.lineItemList.get(0).qli.Bk__c = 'TT';
        quote_custom.fetchsize();
        
        quote_custom.lineItemList.get(0).qli.Size__c = '160Z';
        quote_custom.fetchColorDesc();
        quote_custom.lineItemList.get(0).qli.Size__c = '';
        quote_custom.fetchColorDesc();
        quote_custom.lineItemList.get(0).qli.Size__c = '160Z';
        quote_custom.fetchColorDesc();
        
        quote_custom.lineItemList.get(0).qli.Color_Description__c = 'Test RED';
        quote_custom.fetchProductCode();
        quote_custom.lineItemList.get(0).qli.Color_Description__c = '';
        quote_custom.fetchProductCode();
        quote_custom.lineItemList.get(0).qli.Color_Description__c = 'Test RED';
        quote_custom.fetchProductCode();
        
        quote_custom.lineItemList.get(0).qli.Quantity = 19;
        quote_custom.lineItemList.get(0).qli.UnitPrice = 14;
        
        Apexpages.currentPage().getParameters().put('id',q.Id);
        quote_custom.submit();
        test.stopTest();
        /*Apexpages.Standardcontroller sc1 = new Apexpages.Standardcontroller(q);
        QuoteLineItemController qte1 = new QuoteLineItemController(sc1);
        qte1.quote.Pricebook2Id = pb.Id;
        qte1.addRow();
        System.currentPageReference().getParameters().put('rIndex', '0');
        qte1.lineItemList.get(0).prodName = 'Test Product';
        qte1.fetchStyleDesc();
        
        qte1.lineItemList.get(0).qli.Style_Description__c = 'Test Style';
        qte1.fetchColorDesc();
        qte1.lineItemList.get(0).qli.Color_Description__c = 'Test RED';
        qte1.fetchBk();
        qte1.lineItemList.get(0).qli.Bk__c = 'TT';
        qte1.fetchsize();
        qte1.lineItemList.get(0).qli.Size__c = '160Z';
        qte1.fetchProductCode();
        qte1.lineItemList.get(0).qli.Quantity = 19;
        qte1.lineItemList.get(0).qli.UnitPrice = 14;
        Apexpages.currentPage().getParameters().put('id',q.Id);
        qte1.submit();
        */
    }
   
   
   static testMethod void testOpptyLineItem(){
        
       // create account
    Account a1 = new Account();
    a1.name = 'James Miller';
    insert(a1);
    
    
    Opportunity opp = new Opportunity();    
    opp.AccountId = a1.Id;  
    opp.StageName = 'Prospective Project';  
    opp.Name = 'testOpp';
    opp.Market_Segment__c = 'Corporate';
    opp.Type = 'New Customer';
    opp.CloseDate = System.Today()+7;
    opp.StageName = 'Qualification';
    opp.Type_of_Products_on_Project__c = 'Both Hard and Soft Surfaces';
    insert opp;

     ApexPages.CurrentPage().getParameters().put('id', opp.Id);
     ApexPages.StandardController con = new ApexPages.StandardController(opp);
     OpptyLineItemController cp = new OpptyLineItemController(con);
        
    }
    
    
    static testMethod void testOpptyLineItem_custom(){
        
       // create account
    Account a1 = new Account();
    a1.name = 'James Miller';
    insert(a1);
    
    
    Opportunity opp = new Opportunity();    
    opp.AccountId = a1.Id;  
    opp.StageName = 'Prospective Project';  
    opp.Name = 'testOpp';
    opp.Market_Segment__c = 'Corporate';
    opp.Type = 'New Customer';
    opp.CloseDate = System.Today()+7;
    opp.StageName = 'Qualification';
    opp.Type_of_Products_on_Project__c = 'Both Hard and Soft Surfaces';
    insert opp;

        ///////Added by Megha to create test case of OpptyLineItemController_Custom controller/////////
        Apexpages.currentPage().getParameters().put('id',opp.Id);
        Apexpages.Standardcontroller sc1 = new Apexpages.Standardcontroller(opp);
        OpptyLineItemController_Custom optty_custom = new OpptyLineItemController_Custom(sc1);
        try
        {
            optty_custom.deleteRow();
            optty_custom.submit();
        }
        catch(Exception ex)
        {
            System.debug('.....Exception'+ex.getMessage());
        }
    }
    static testMethod void myUnitTest2() {
        //QUOTE CONTROLLER TEST
        List<RecordType> aRecType = [Select Id From RecordType Where sObjectType='Account'];
        Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.RecordTypeId = aRecType.get(0).Id;
        insert a;
        
        Contact c = new Contact();
        c.LastName = 'Test Contact';
        c.AccountId = a.Id;
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Oppty';
        o.AccountId = a.Id;
        o.StageName = 'Samples Submitted';
        o.CloseDate = Date.today().addDays(5);
        o.Pricebook2Id = pb.Id;
        insert o;
        System.debug('o: '+o);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Category__c = 'Test Product';
        p.ProductCode = 'TP';
        p.Bk__c = 'TT';
        p.Color_Description__c = 'Test RED';
        p.IsActive = true;
        p.Size__c = '160Z';
        p.Style_Description__c = 'Test Style';
        p.SKU__c = 'sku';
        insert p;
        
        PricebookEntry pbe;
        try {
            pbe = new PricebookEntry();
            pbe.Product2Id = p.Id;
            pbe.Pricebook2Id = pb.Id;
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            insert pbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
        
        OpportunityLineItem olItem = new OpportunityLineItem();
        olItem.PricebookEntryId = pbe.Id;
        olItem.Bk__c = 'TT';
        olItem.Color_Description__c = 'Test RED';
        olItem.OpportunityId = o.Id;
        olItem.Quantity = 2;
        olItem.UnitPrice = 10;
        insert olItem;
        
        Quote q = new Quote();
        ApexPages.currentPage().getParameters().put('oppid',o.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(q);
        QuoteController qc = new QuoteController(sc);
        qc.q.Name = 'Test quote';
        qc.populateAddress();
        qc.q.Contact_Name__c = c.Id;
        qc.populateAddress();
        qc.saveQuote();
    }
    
    static testMethod void myUnitTest3() {
        //QUOTE CONTROLLER TEST
        List<RecordType> aRecType = [Select Id From RecordType Where sObjectType='Account'];
        Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.RecordTypeId = aRecType.get(0).Id;
        insert a;
        
        Contact c = new Contact();
        c.LastName = 'Test Contact';
        c.AccountId = a.Id;
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Oppty';
        o.AccountId = a.Id;
        o.StageName = 'Samples Submitted';
        o.CloseDate = Date.today().addDays(5);
        o.Pricebook2Id = pb.Id;
        insert o;
        System.debug('o: '+o);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Category__c = 'Test Product';
        p.ProductCode = 'TP';
        p.Bk__c = 'TT';
        p.Color_Description__c = 'Test RED';
        p.IsActive = true;
        p.Size__c = '160Z';
        p.Style_Description__c = 'Test Style';
        p.SKU__c = 'sku';
        insert p;
        
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.OpportunityId = o.Id;
        q.Pricebook2Id = pb.Id;
        insert q;
        
        ApexPages.currentPage().getParameters().put('id',q.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(q);
        QuoteEditController qc = new QuoteEditController(sc);
        //qc.q.ContactId = null;
        qc.populateAddress();
        qc.q.Contact_Name__c = c.Id;
        qc.populateAddress();
        qc.saveQuote();
    }
    
    static testMethod void myUnitTest4() {
        List<RecordType> aRecType = [Select Id From RecordType Where sObjectType='Account'];
        Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.RecordTypeId = aRecType.get(0).Id;
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Oppty';
        o.AccountId = a.Id;
        o.StageName = 'Samples Submitted';
        o.CloseDate = Date.today().addDays(5);
        o.Pricebook2Id = pb.Id;
        insert o;
        System.debug('o: '+o);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Category__c = 'Test Product';
        p.ProductCode = 'TP';
        p.Bk__c = 'TT';
        p.Color_Description__c = 'Test RED';
        p.IsActive = true;
        p.Size__c = '160Z';
        p.Style_Description__c = 'Test Style';
        p.SKU__c = 'sku';
        p.Unit_of_Measurement__c = 'SF';
        insert p;
          
        PricebookEntry pbe;     
        try {        
            pbe = new PricebookEntry();
            pbe.Product2Id = p.Id;
            pbe.Pricebook2Id = pb.Id;
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            insert pbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
        
        Apexpages.currentPage().getParameters().put('id',o.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(o);
        OpptyLineItemController optty = new OpptyLineItemController(sc);
        optty.opportunity.Pricebook2Id = pb.Id;
        optty.addRow();
        System.currentPageReference().getParameters().put('rIndex','1');
        optty.deleteRow();
    }
    /*
    static testMethod void myUnitTest5() {
        List<RecordType> aRecType = [Select Id From RecordType Where sObjectType='Account'];
        Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.RecordTypeId = aRecType.get(0).Id;
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Oppty';
        o.AccountId = a.Id;
        o.StageName = 'Samples Submitted';
        o.CloseDate = Date.today().addDays(5);
        o.Pricebook2Id = pb.Id;
        insert o;
        System.debug('o: '+o);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Category__c = 'Test Product';
        p.ProductCode = 'TP';
        p.Bk__c = 'TT';
        p.Color_Description__c = 'Test RED';
        p.IsActive = true;
        p.Size__c = '160Z';
        p.Style_Description__c = 'Test Style';
        p.SKU__c = 'sku';
        p.Unit_of_Measurement__c = 'SF';
        insert p;
        
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.OpportunityId = o.Id;
        q.Pricebook2Id = pb.Id;
        insert q;
        
        PricebookEntry pbe;
        try {
            pbe = new PricebookEntry();
            pbe.Product2Id = p.Id;
            pbe.Pricebook2Id = pb.Id;
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            insert pbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(q);
        QuoteLineItemController qte = new QuoteLineItemController(sc);
        qte.quote.Pricebook2Id = pb.Id;
      //  qte.addRow();
       // System.currentPageReference().getParameters().put('rIndex','1');
      //  qte.deleteRow();
    }
    
    */
  static testMethod void myUnitTest_New1() {
    
     Account a = new Account();
        a.Name = 't';
        insert a;
        Contact cont = new Contact();
        cont.AccountId = a.id;
        cont.LastName = 'test Contact';
        insert cont;  
        
        ApexPages.currentPage().getParameters().put('id',cont.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(cont);
        ContactListExtension contactOnj = new ContactListExtension(sc);
        ContactListExtension.Wrapper wrapperObj = new ContactListExtension.Wrapper();
        contactOnj.keyword = 't';
        contactOnj.SearchContacts2(); 
        contactOnj.resetEmailList();
        
        contactOnj.keyword = 'test';
        contactOnj.SearchContacts2();
        contactOnj.addSelected();
        contactOnj.sendEmail();
        contactOnj.sendEmail2();
    }  
  
  static testMethod void myUnitTest_New2() {
    
    // TO DO: implement unit test
        
        List<RecordType> aRecType = [Select Id From RecordType Where sObjectType='Account'];
        Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.RecordTypeId = aRecType.get(0).Id;
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Oppty';
        o.AccountId = a.Id;
        o.StageName = 'Samples Submitted';
        o.CloseDate = Date.today().addDays(5);
        o.Pricebook2Id = pb.Id;
        insert o;
        System.debug('o: '+o);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Category__c = 'Test Product';
        p.ProductCode = 'TP';
        p.Bk__c = 'TT';
        p.Color_Description__c = 'Test RED';
        p.IsActive = true;
        p.Size__c = '160Z';
        p.Style_Description__c = 'Test Style';
        p.SKU__c = 'sku';
        p.Unit_of_Measurement__c = 'SF';
        insert p;
           
        PricebookEntry pbe;
        try {            
            pbe = new PricebookEntry();
            pbe.Product2Id = p.Id;
            pbe.Pricebook2Id = pb.Id;
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            insert pbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
        
       
        
        ///////Added by Megha to create test case of OpptyLineItemController_Custom controller/////////
        Apexpages.currentPage().getParameters().put('id',o.Id);
        Apexpages.Standardcontroller sc1 = new Apexpages.Standardcontroller(o);
        OpptyLineItemController_Custom optty_custom = new OpptyLineItemController_Custom(sc1);
        optty_custom.opportunity.Pricebook2Id = pb.Id;
        optty_custom.addRow();
        System.currentPageReference().getParameters().put('rIndex', '0');
        optty_custom.lineItemList.get(0).prodName = 'Test Product 1';
        optty_custom.fetchStyleDesc();
        optty_custom.lineItemList.get(0).prodName = '';
        optty_custom.fetchStyleDesc();
        optty_custom.lineItemList.get(0).prodName = 'Test Product 1';
        optty_custom.fetchStyleDesc();
        
        optty_custom.lineItemList.get(0).oli.Style_Description__c = 'Test Style';
        optty_custom.fetchBk();
        optty_custom.lineItemList.get(0).oli.Style_Description__c = '';
        optty_custom.fetchBk();
        optty_custom.lineItemList.get(0).oli.Style_Description__c = 'Test Style';
        optty_custom.fetchBk();
        
        optty_custom.lineItemList.get(0).oli.Bk__c = 'TT';
        optty_custom.fetchsize();
        optty_custom.lineItemList.get(0).oli.Bk__c = '';
        optty_custom.fetchsize();
        optty_custom.lineItemList.get(0).oli.Bk__c = 'TT';
        optty_custom.fetchsize();
        
        optty_custom.lineItemList.get(0).oli.Size__c = '160Z';
        optty_custom.fetchColorDesc();
        optty_custom.lineItemList.get(0).oli.Size__c = '';
        optty_custom.fetchColorDesc();
        optty_custom.lineItemList.get(0).oli.Size__c = '160Z';
        optty_custom.fetchColorDesc();
        
        optty_custom.lineItemList.get(0).oli.Color_Description__c = 'Test RED';
        optty_custom.fetchProductCode();
        optty_custom.lineItemList.get(0).oli.Color_Description__c = '';
        optty_custom.fetchProductCode();
        optty_custom.lineItemList.get(0).oli.Color_Description__c = 'Test RED';
        optty_custom.fetchProductCode();
        
        optty_custom.lineItemList.get(0).oli.Quantity = 19;
        optty_custom.lineItemList.get(0).oli.UnitPrice = 14;
        
        Apexpages.currentPage().getParameters().put('id',o.Id);
        optty_custom.submit();
    }   
    
 static testMethod void TriggerTest() {
    
    //for trigger SetDodgeProjectOwnerBI
    
    Dodge_Queue__c dQueueObj = new Dodge_Queue__c();
    dQueueObj.Queue_Name__c = 'test queue';
    dQueueObj.ZipCode__c = '2504';
    insert dQueueObj;
     
    Dodge_Project__c doObj = new Dodge_Project__c();
    doObj.Address_Line_1__c = 'test';
    doObj.ZipCode__c = '2504';
    doObj.Dodge_Report_Number__c = '12';
    doObj.Dodge_Report_Version_Number__c =  '12'; 
    doObj.Report_ID__c = '23';
    doObj.Title__c = 'test title';
    doObj.Country__c = 'USA';
    insert doObj; 
    
    // for UpdateTheNetValueToSGQ trigger 
    Sales_Group_Quota__c salesObj = new Sales_Group_Quota__c();
     salesObj.Actual_MACS__c = 12;
     salesObj.Year__c = '2013';
     salesObj.Actual__c = 23;
     salesObj.Actual__c = 34;
     salesObj.Sales_Group_Id_New__c = '1212';
     insert salesObj;
     
     Order_Shipment__c orderObj = new Order_Shipment__c();
     orderObj.Carrier_Description__c = 'test data';
     orderObj.Net_Total_Value__c = 122;
     orderObj.Carrier_Description__c = 'test data';
     orderObj.Document_Number__c = '1234';  
     orderObj.Sales_Group_Id__c = '1212';
     orderObj.Billing_Date__c = System.today();
     
     insert orderObj;

    }
    
    static testMethod void TriggerTest1() {
     Sales_Group_Quota__c salesObj1 = new Sales_Group_Quota__c();
     salesObj1.Actual_MACS__c = 12;
     insert salesObj1;
    
             
     Order_Shipment__c orderObj1 = new Order_Shipment__c();
     orderObj1.Carrier_Description__c = 'test data';
     orderObj1.Net_Total_Value__c = 122;
     orderObj1.Carrier_Description__c = 'test data';
     orderObj1.Document_Number__c = '1234';  
     orderObj1.Sales_Group_Id__c = '121222';
     orderObj1.Billing_Date__c = System.today();
     
     insert orderObj1;
    }
        
       
}