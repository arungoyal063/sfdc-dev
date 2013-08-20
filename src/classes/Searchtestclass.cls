@isTest
public class Searchtestclass{
    static testMethod void runtest(){
    
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