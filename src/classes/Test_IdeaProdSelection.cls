/*******************************************************************************************************************
** Module Name   : ProdSelection
** Description   : Controller for the popup page to help the user select the correct product.
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-02-05  AC                    Initial Version
******************************************************************************************************************/
@isTest(seeAllData=true)  
private class Test_IdeaProdSelection{
     static testMethod void IdeaProdSelection_UnitTest() {
         Case cs = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');   // Case Created  
         Idea idea = MockTestData.createIdeaRecordByCase('Test','Test',cs.Id);                  // Idea Created
          
         ApexPages.StandardController std = new ApexPages.StandardController(idea);
         ProductSelection prod = new ProductSelection(std);
         prod.doCancel();
         prod.selectProuduct();
         prod.selectProuduct();
         prod.isProductLineSelected();
         prod.isProductSelected();
        
     }
    
     static testMethod void IdeaProdSelection_UnitTest1() {
         Case cs = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');   // Case Created  
         Idea idea = MockTestData.createIdeaRecordByCase('Test','Test',cs.Id);                  // Idea Created
         ApexPages.currentPage().getParameters().put('caseid', cs.Id); 
         ApexPages.currentPage().getParameters().put('id', cs.Id);
         ApexPages.StandardController std = new ApexPages.StandardController(idea);
         ProductSelection prod = new ProductSelection(std);
     }
      
     static testMethod void IdeaFromCase_UnitTest() {
         Case cs = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');   // Case Created  
         Idea idea = MockTestData.createIdeaRecordByCase('Test','Test',cs.Id);                  // Idea Created
         
         Product2 pro = MockTestData.createProductRecord('Test');                               // Parent product      
         pro.Product_Line__c = 'Test';  
         update pro;
         
         Version__c v = MockTestData.createVersionRecord(pro.Id);                                // version created
             
         Product2 childProduct = MockTestData.createProductRecord('Test');                       // child Product
         childProduct.Product_Line__c = 'Test';
         childProduct.Parent_Product__c = pro.Id;
         update childProduct;
         
         cs.Subject = 'Test';
         cs.Description = 'Test';
         cs.ProductId = childProduct.Id;
         //update cs;
         
         ApexPages.currentPage().getParameters().put('caseid', cs.Id);
         ApexPages.StandardController std = new ApexPages.StandardController(idea);
         ProductSelection prod = new ProductSelection(std);
         prod.pls = 'Test';
         prod.getProductNameItems_new();
         prod.prd = pro.Id;
         prod.getModuleItems_new();
         prod.module = childProduct.Id;
         prod.version = v.Id;
         prod.productSelect();
         Community comm = [Select Id from Community Limit 1];
         prod.commu = comm.Id;
         //prod.fillIdeaThemes();
         prod.saveIdea();
        
     }
}