/*******************************************************************************************************************
** Module Name   : Test_CaseProductSelection
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

@istest
public class Test_CaseProductSelection {

    static testMethod void ProdSelectionUnitTest() {
    
         User pu = getPortalUser();
         System.runAs(pu) {
           
         Case c = [Select Id , Licensed_Product__c, Licensed_Product__r.Product_New__c from Case Limit 1];
         User puser = [select AccountId, ContactId from User where Id = :pu.Id];
         Account a = [Select Id, Name from Account where Id= :puser.AccountId];
         Contact con = [Select Id, Name from Contact where Id=:puser.ContactId];
         
           ApexPages.CurrentPage().getParameters().put('id', c.Id);
           ApexPages.StandardController ctr = new ApexPages.StandardController(c);
         
           CaseProductSelection cp = new CaseProductSelection(ctr);
           cp.isEditMode = true;
           //cp.selectProuduct();
           cp.selectProuduct();
           cp.isProductLineSelected();
           cp.isProductSelected();
           cp.pls = 'Test';
           cp.prd = c.Licensed_Product__r.Product_New__c;
           cp.productSelect();
           cp.doCancel();
           cp.getEntitlements();
           cp.prepareProductLines();
           cp.getProductLineItems();
           cp.pls = 'Test';
           cp.prd = c.Licensed_Product__r.Product_New__c;           
           cp.getProductNameItems();
           cp.getModuleNameItems();
           cp.getProductNameItems_new();
           cp.getModuleItems_new();
           cp.getProductVersionList();
       }
    }
    
    public static User getPortalUser() {
           Contact con;
           User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
          
           System.runAs (thisUser) {
           
                 Case c = MockTestData.createCaseRecord('open', 'Email', 'Level 3', 'Test','Test');  
                 Account a = MockTestData.createAccountRecord('Test',100);
                 con = MockTestData.createContactRecord('lastname',a.id);              
            
                 Account childAcc = MockTestData.createAccountRecord('Test',100);
                 Entitlement  en  = MockTestData.createEntlmntRecord('Test', a);
                 Licensed_Product__c lp = MockTestData.createLPRecord('Test', a);        
                 Product2 pro = MockTestData.createProductRecord('Test');         
                 Version__c v= MockTestData.createVersionRecord(pro.Id);       
                 pro.Product_Line__c = 'Test';
                 update pro;
                 
                 Product2 childProduct = MockTestData.createProductRecord('Test');
                 childProduct.Product_Line__c = 'Test';
                 childProduct.Parent_Product__c = pro.Id;
                 update childProduct;
                 
                 lp.Product_New__c = pro.Id;
                 update lp;
                 
                 en.Licensed_Product__c = lp.Id;
                 update lp;
                 
                 c.AccountId = a.Id;
                 c.ContactId = con.Id;
                 c.Licensed_Product__c = lp.Id;
                 c.ProductId = pro.Id;
                 update c;
                 
                 childAcc.ParentId = a.Id;        
                 update childAcc;
                 
                 en.StartDate = Date.Today(); 
                 en.EndDate = Date.Today().addDays(10);        
                 update en;
              
           }
          
           Profile p = [SELECT Id FROM profile WHERE name='Ellucian Communities Profile']; 
           //UserRole r = [SELECT Id FROM UserRole WHERE PortalRole='Executive' LIMIT 1];       
           // mock test user
           User pu = new User(alias = 'newUser', email='newuser@tgerm.com',
                 emailencodingkey='UTF-8', lastname='Testing', 
                 languagelocalekey='en_US', localesidkey='en_US', 
                 profileid = p.Id, contactId = con.Id, 
                 timezonesidkey='America/Los_Angeles', username='newuser@tgerm.com' + System.now().getTime());
           Database.insert(pu);
           return pu;
     }
}