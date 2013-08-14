@isTest
private class CreateIdea_UnitTest {

public static Change_Request__c crObj;
public static Associated_Case_Change_Request__c assoInsertObj {get; set;} 

static testMethod void CreateCRIdeatest() {
        
        Community community = [ SELECT Name, Id FROM Community WHERE IsActive = true LIMIT 1];
        
        Product2 crProduct = MockTestData.createProductRecord(community.Name);
        System.debug('crProduct.......'+crProduct);
        Account crAccount = MockTestData.createAccountRecord('Test Account', 2);
        System.debug('crAccount.........'+crAccount);
        
        Case crCase = MockTestData.createCaseRecord('open', 'Web', 'Level 2', 'Test on case Problem Statement', 'Test Summary on case');
        
        if(crProduct.id !=null &&  crAccount.Id != null)
        {
                crCase.ProductId = crProduct.id;
                crCase.AccountId = crAccount.Id;
                update crCase;  
        }

        
                
        CreateIdea.createIdea(crCase.Id);
        // validate for without subject
         CreateIdea.ideaValidate(crCase.Id);
         crCase.Subject  = 'Test Subject';
         update crCase;
        // validate for with Product 
         CreateIdea.ideaValidate(crCase.Id);
        
                         
    }
}