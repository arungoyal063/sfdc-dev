@isTest 
private class TestSampleOrderClass {
    static testMethod void SampleOrderClassUnitTest() {
    
        // setup Account
        Account acc = new Account();
        acc.Name = 'test';
        acc.Type ='Prospect';
        insert acc;
        
        // setup Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();
        insert opp;
        
        Contact con = new Contact();
        con.MailingStreet = 'test';
        con.LastName = 'test';
        con.MailingCity = 'test';
        con.MailingState = 'test';
        con.MailingPostalCode = '121212';
        con.MailingCountry = 'US';
        con.Phone = '12345676890';
        con.Phone_Ext__c = '123';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        Sample_Order__c so = new Sample_Order__c();   
        so.Opportunity__c = opp.Id; 
        so.Contact__c = con.Id;       
        insert so; 
        
        Sample_Product__c sp = new Sample_Product__c();
        sp.Name = 'test';
        sp.Product_Category__c = 'test';
        sp.SKU__c = 'test';
        sp.style_desc__c = 'test';
        sp.color_desc__c = 'test';
        insert sp;
        
        Sample_Product__c sp1 = new Sample_Product__c();
        sp1.Name = 'test1';
        sp1.Product_Category__c = 'test1';
        sp1.SKU__c = 'test1';
        sp1.style_desc__c = 'test1';
        sp1.color_desc__c = 'test1';
        insert sp1;
           
        ApexPages.StandardController std = new ApexPages.StandardController(so);
        SampleOrderClass sobj = new SampleOrderClass(std); 
        SampleOrderClass.getProdCategories();
        SampleOrderClass.getStyles('test');
        SampleOrderClass.getColors('test', 'test');
        SampleOrderClass.getSizes('test', 'test', 'test');
        SampleOrderClass.getSelectedProduct(sp.Id);
        sobj.ReloadContactAddress();
        sobj.productSelected = sp.Id +'~' + sp1.Id;
        sobj.productQuantity = '2~2';
        sobj.submitOrder();
        
    
    }
    
    static testMethod void searchExtUnitTest(){
    
        Sample_Product__c pd= new Sample_Product__c(name='test1',SKU__c='1');
        insert pd;
        ApexPages.StandardController sc = new ApexPages.StandardController(pd);
        SampleSearchExtensionNew a= new SampleSearchExtensionNew(sc);
        a.init(True);
        Sample_Product__c p= new Sample_Product__c();
        p.name='test';
        p.SKU__c='2';
        insert p;
        SampleSearchExtensionNew.ExtendedProduct ac= new SampleSearchExtensionNew.ExtendedProduct(p);
        a.quickSearch='test';
     
        a.onSearch();
        
    
    }
}