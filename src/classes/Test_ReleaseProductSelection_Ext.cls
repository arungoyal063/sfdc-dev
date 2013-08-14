@isTest
public class Test_ReleaseProductSelection_Ext {

static testMethod void ReleaseProductSelection_unittest(){

         Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test1','Test1');   // Case Created 
         Releases__c rl = MockTestData.createReleaseRecord('releasetest1'); // release created

	//Account a = MockTestData.createAccountRecord('Test',100);
  //Community comm = new Community(Name='comm1');     
         
         
         Product2 pro = MockTestData.createProductRecord('Test');        
         pro.Product_Line__c = 'Test';
         update pro;
         
         Product2 childProduct = MockTestData.createProductRecord('Test');
         childProduct.Product_Line__c = 'Test';
         childProduct.Parent_Product__c = pro.Id;
         update childProduct;
         
         rl.Product__c = pro.Id;
         rl.version__c = MockTestData.createVersionRecord(pro.Id).Id;
         update rl;
         
         ApexPages.CurrentPage().getParameters().put('id', rl.Id);
         ApexPages.currentPage().getParameters().put('caseid', c.ID);
         ApexPages.currentPage().getParameters().put('sfdc.override', '1');
         ApexPages.currentPage().getParameters().put('save_new', '1');
         String ReleaseId = ApexPages.currentPage().getParameters().put('Id', rl.ID);
         ApexPages.StandardController con = new ApexPages.StandardController(c);
         ReleaseProductSelection_Ext cp = new ReleaseProductSelection_Ext(con);
         //ChangeRequestProductSelection_Ext cpp = new ChangeRequestProductSelection_Ext();
         cp.isProductLineSelected();
         cp.isProductSelected();
         cp.prepareProductLines_New();
         cp.prd = pro.Id; 
         //cp.getProductNameItems_new();
         cp.getModuleItems_new();
        
         cp.prd = pro.Id;
         cp.pls='Test';
         cp.getProductNameItems_new();
         cp.prd = pro.Id;
         cp.odNext();
         cp.getProductVersionList();
         
         cp.doCancel();
         cp.saveProudct();
        
    }
}