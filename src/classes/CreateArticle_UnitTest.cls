@isTest

private class CreateArticle_UnitTest {

static testMethod void CreateCRIdeatest() {

        Product2 crProduct = MockTestData.createProductRecord('Test product');
        System.debug('crProduct.......'+crProduct);
        Account crAccount = MockTestData.createAccountRecord('Test Account', 2);
        System.debug('crAccount.........'+crAccount);
        
        Case crCase = MockTestData.createCaseRecord('open', 'Web', 'Level 2', 'Test on case Problem Statement', 'Test Summary on case');
        crCase.Subject = 'test Subject';
        crCase.Problem_Statement__c = NULL;
        crCase.Resolution_Summary__c = NULL;
        update crCase;
        createArticle.createArticleValidation(crCase.Id);
        
        try
        {
            update crCase;
            //createArticle.createArticleCase(crCase.Id);
            createArticle.createArticleOnCase(crCase.Id);
        }
        catch(Exception ex)
        {
            System.debug('Error on Create Article'+ex.getMessage());
        }
        
}
}