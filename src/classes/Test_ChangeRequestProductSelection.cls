@isTest
public class Test_ChangeRequestProductSelection{

static testMethod void changerequestproductselectionunittest(){
//Change_Request__c cr = new Change_Request__c(Description__c = description);
 Case c = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test1','Test1');   // Case Created 
Change_Request__c cr = MockTestData.createCRRecord('hi, this is for test');   // CR Created 
//Account a = MockTestData.createAccountRecord('Test',100);
  //Community comm = new Community(Name='comm1');     
         
         
         Product2 pro = MockTestData.createProductRecord('Test');        
         pro.Product_Line__c = 'Test';
         update pro;
         
         Product2 childProduct = MockTestData.createProductRecord('Test');
         childProduct.Product_Line__c = 'Test';
         childProduct.Parent_Product__c = pro.Id;
         update childProduct;
         
         
         ApexPages.CurrentPage().getParameters().put('id', c.Id);
         String caseId = ApexPages.currentPage().getParameters().put('caseid', c.ID);
         ApexPages.StandardController con = new ApexPages.StandardController(c);
         ChangeRequestProductSelection_Ext cp = new ChangeRequestProductSelection_Ext(con);
         //ChangeRequestProductSelection_Ext cpp = new ChangeRequestProductSelection_Ext();
         cp.isProductLineSelected();
         cp.isProductSelected();
         cp.prepareProductLines_New();
         cp.prd = pro.Id; 
         cp.pls = 'Test';
         cp.getProductNameItems_new();
         cp.getModuleItems_new();
         cp.getProductVersionList();
         
         cp.odNext();
         
    }
}