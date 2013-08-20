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
private class TestOpptyQuoteLineItemEditController {

    static testMethod void opptyLineItemEditController_TestMethod1() 
    {
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
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = o.Id;
        oli.Bk__c = 'TT';
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 2;
        oli.Size__c = '160Z';
        oli.Unit_of_Measure__c = 'SF';
        oli.Style_Description__c = 'Test Style';
        oli.UnitPrice = 2;
        insert oli;
        
        OpptyLineItemEditController optyEdit = new OpptyLineItemEditController(new ApexPages.Standardcontroller(oli));
        optyEdit.oli.Color_Description__c = 'Test RED';
        optyEdit.fetchProductCode();
        optyEdit.oli.Color_Description__c = '';
        optyEdit.fetchProductCode();
        optyEdit.oli.Color_Description__c = 'Test RED';
        optyEdit.fetchProductCode();
        optyEdit.saveOLI();
    }
    
    static testMethod void opptyLineItemEditController_TestMethod2() {
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
        
        Product2 pp = new Product2();
        pp.Name = 'Test Product-Color TBD';
        pp.Product_Category__c = 'Test Product';
        pp.SKU__c = 'sku1';
        pp.IsActive = true;
        insert pp;
                       
        PricebookEntry ppbe;
        try {
            ppbe = new PricebookEntry();
            ppbe.Product2Id = pp.Id;
            ppbe.Pricebook2Id = pb.Id;
            ppbe.UnitPrice = 1;
            ppbe.IsActive = true;
            insert ppbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :pp.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                ppbe = entry;
            }
        }
        
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
            pbe.UnitPrice = 1;
            pbe.IsActive = true;
            insert pbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = o.Id;
        oli.Bk__c = 'TT';
        oli.PricebookEntryId = ppbe.Id;
        oli.Quantity = 2;
        oli.Size__c = '160Z';
        oli.Unit_of_Measure__c = 'SF';
        oli.Style_Description__c = 'Test Style';
        oli.UnitPrice = 2;
        insert oli;
        
        OpptyLineItemEditController optyEdit = new OpptyLineItemEditController(new ApexPages.Standardcontroller(oli));
        optyEdit.oli.Color_Description__c = 'Test RED';
        optyEdit.fetchProductCode();
        optyEdit.oli.Color_Description__c = '';
        optyEdit.fetchProductCode();
        optyEdit.oli.Color_Description__c = 'Test RED';
        optyEdit.fetchProductCode();
        optyEdit.saveOLI();
    }
    
    static testMethod void quoteLineItemEditController_TestMethod1() {
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
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = q.Id;
        qli.Bk__c = 'TT';
        qli.PricebookEntryId = pbe.Id;
        qli.Quantity = 2;
        qli.Size__c = '160Z';
        qli.Unit_of_Measure__c = 'SF';
        qli.Style_Description__c = 'Test Style';
        qli.UnitPrice = 2;
        insert qli;
        
        QuoteLineItemEditController quoteEdit = new QuoteLineItemEditController(new ApexPages.Standardcontroller(qli));
        quoteEdit.qli.Color_Description__c = 'Test RED';
        quoteEdit.fetchProductCode();
        quoteEdit.qli.Color_Description__c = '';
        quoteEdit.fetchProductCode();
        quoteEdit.qli.Color_Description__c = 'Test RED';
        quoteEdit.fetchProductCode();
        quoteEdit.saveOLI();
    }
    
    static testMethod void quoteLineItemEditController_TestMethod2() {
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
        
        Product2 pp = new Product2();
        pp.Name = 'Test Product-Color TBD';
        pp.Product_Category__c = 'Test Product';
        pp.SKU__c = 'sku1';
        pp.IsActive = true;
        insert pp;
                       
        PricebookEntry ppbe;
        try {
            ppbe = new PricebookEntry();
            ppbe.Product2Id = pp.Id;
            ppbe.Pricebook2Id = pb.Id;
            ppbe.UnitPrice = 1;
            ppbe.IsActive = true;
            insert ppbe;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :pp.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                ppbe = entry;
            }
        }
        
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
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = q.Id;
        qli.Bk__c = 'TT';
        qli.PricebookEntryId = ppbe.Id;
        qli.Quantity = 2;
        qli.Size__c = '160Z';
        qli.Unit_of_Measure__c = 'SF';
        qli.Style_Description__c = 'Test Style';
        qli.UnitPrice = 2;
        insert qli;
        
        QuoteLineItemEditController quoteEdit = new QuoteLineItemEditController(new ApexPages.Standardcontroller(qli));
        quoteEdit.qli.Color_Description__c = 'Test RED';
        quoteEdit.fetchProductCode();
        quoteEdit.qli.Color_Description__c = '';
        quoteEdit.fetchProductCode();
        quoteEdit.qli.Color_Description__c = 'Test RED';
        quoteEdit.fetchProductCode();
        quoteEdit.saveOLI();
    }
    //Test Case for Edit All
    static testMethod void OpptyLineItemEditControllerAll_TestMethod1() {
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
        p1.Product_Category__c = 'Test Product1';
        p1.ProductCode = 'TP1';
        p1.Bk__c = 'TT';
        p1.Color_Description__c = 'Test BLUE';
        p1.IsActive = true;
        p1.Size__c = '160Z1';
        p1.Style_Description__c = 'Test Style11';
        p1.SKU__c = 'sku1';
        p1.Unit_of_Measurement__c = 'SF1';
        insert p1;
                       
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
                        
        PricebookEntry pbe1;
        try {
            pbe1 = new PricebookEntry();
            pbe1.Product2Id = p1.Id;
            pbe1.Pricebook2Id = pb.Id;
            pbe1.UnitPrice = 10;
            pbe1.IsActive = true;
            insert pbe1;
        } catch (Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p1.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe1 = entry;
            }
        }
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = o.Id;
        oli.Bk__c = 'TT';
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 2;
        oli.Size__c = '160Z';
        oli.Unit_of_Measure__c = 'SF';
        oli.Style_Description__c = 'Test Style';
        oli.UnitPrice = 2;
        oli.Color_Description__c = 'Test Red';
        insert oli;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = o.Id;
        oli1.Bk__c = 'TT';
        oli1.PricebookEntryId = pbe1.Id;
        oli1.Quantity = 2;
        oli1.Size__c = '160Z';
        oli1.Unit_of_Measure__c = 'SF';
        oli1.Style_Description__c = 'Test Style';
        oli1.UnitPrice = 2;
        oli1.Color_Description__c = '';
        insert oli1;
        
        Apexpages.currentPage().getParameters().put('id',o.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(o);
        OpptyLineItemEditControllerAll optty = new OpptyLineItemEditControllerAll(sc);
       
        if(optty.wrapList.get(0).oli.Color_Description__c == '' || optty.wrapList.get(0).oli.Color_Description__c == null)
        optty.wrapList.get(0).oli.Color_Description__c = 'Test BLUE';
        else
        optty.wrapList.get(1).oli.Color_Description__c = 'Test BLUE';
        optty.fetchProductCode();
        optty.saveOLI();
    }
    
    //Test Case for Edit All for Quote
    static testMethod void quoteLineItemEditControllerAll_TestMethod1() {
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
        p1.Product_Category__c = 'Test Product1';
        p1.ProductCode = 'TP1';
        p1.Bk__c = 'TT';
        p1.Color_Description__c = 'Test BLUE';
        p1.IsActive = true;
        p1.Size__c = '160Z1';
        p1.Style_Description__c = 'Test Style11';
        p1.SKU__c = 'sku1';
        p1.Unit_of_Measurement__c = 'SF1';
        insert p1;
                       
        PricebookEntry pbe;
        try {
            pbe = new PricebookEntry();
            pbe.Product2Id = p.Id;
            pbe.Pricebook2Id = pb.Id;
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            insert pbe;
        } catch(Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe = entry;
            }
        }
                        
        PricebookEntry pbe1;
        try {
            pbe1 = new PricebookEntry();
            pbe1.Product2Id = p1.Id;
            pbe1.Pricebook2Id = pb.Id;
            pbe1.UnitPrice = 10;
            pbe1.IsActive = true;
            insert pbe1;
        } catch(Exception ex) {
            System.debug('Entry has already been created for the following product in standard pricebook: ' + ex.getMessage());
            for (PricebookEntry entry : [SELECT Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id = :p1.Id AND Pricebook2Id = :pb.Id LIMIT 1]) {
                pbe1 = entry;
            }
        }
        
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.OpportunityId = o.Id;
        q.Pricebook2Id = pb.Id;
        insert q;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = q.Id;
        qli.Bk__c = 'TT';
        qli.PricebookEntryId = pbe.Id;
        qli.Quantity = 2;
        qli.Size__c = '160Z';
        qli.Unit_of_Measure__c = 'SF';
        qli.Style_Description__c = 'Test Style';
        qli.UnitPrice = 2;
        qli.Color_Description__c = 'Test Red';
        insert qli;
        
        QuoteLineItem qli1 = new QuoteLineItem();
        qli1.QuoteId = q.Id;
        qli1.Bk__c = 'TT';
        qli1.PricebookEntryId = pbe1.Id;
        qli1.Quantity = 2;
        qli1.Size__c = '160Z';
        qli1.Unit_of_Measure__c = 'SF';
        qli1.Style_Description__c = 'Test Style';
        qli1.UnitPrice = 2;
        qli1.Color_Description__c = '';
        insert qli1;
        
        Apexpages.currentPage().getParameters().put('id',q.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(q);
        QuoteLineItemEditControllerAll qouteObj = new QuoteLineItemEditControllerAll(sc);
       
        if(qouteObj.wrapList.get(0).qli.Color_Description__c == '' || qouteObj.wrapList.get(0).qli.Color_Description__c == null)
        qouteObj.wrapList.get(0).qli.Color_Description__c = 'Test BLUE';
        else
        qouteObj.wrapList.get(1).qli.Color_Description__c = 'Test BLUE';
        qouteObj.fetchProductCode();
        qouteObj.saveQLI();
    }
}