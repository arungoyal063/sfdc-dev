@isTest (SeeAllData=true)
private class CreateCROnIdea_UnitTest {

public static Change_Request__c crObj;
public static Idea ideaObj;
public static String ideaId;  
public static Associated_Case_Change_Request__c assoInsertObj {get; set;}

    
    static testMethod void CreateCRIdeatest() {
        
        // No need to create community
        /*
        Community crComm = new Community();
        crComm.Name ='test Comm';
        crComm.IsActive = true;
        crComm.Description ='test ';
        insert crComm; 
        */
        
        Community community = [ SELECT Name, Id FROM Community WHERE IsActive = true LIMIT 1];
        Product2 crProduct = MockTestData.createProductRecord('Test Product');
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
         
        try { 
            /*Ideas_v2__c ideav2 = MockTestData.createIdeaV2Record('Test');
            Product2 pro = MockTestData.createProductRecord('Test');    
            Account a = MockTestData.createAccountRecord('Test',100);     
            ideav2.Product__c = pro.Id;
            ideav2.Version__c = '1.0'; 
            ideav2.Institution__c = a.Id; 
            ideav2.Originating_Case__c = crCase.Id;
            ideav2.Description__c = 'Test Idea';
            update ideav2;
            */
            Idea objidea = MockTestData.createIdeaRecord('Test Idea','test bussiness',null);
            //PageRefere pageRef = Page.CreateCR;        
            Apexpages.currentpage().getparameters().put('ideaID' , ''+objidea.Id);
            CreateCROnIdea bsExt = new CreateCROnIdea(new ApexPages.StandardController(objidea));
            bsExt.RedirectToCR();
        } catch(Exception ex) {
            System.debug('Error on insert of Idea'+ ex.getMessage());    
        }
        /*System.debug('crCase........'+crCase);
        Idea crIdea = new  Idea();
        crIdea.Case__c =crCase.Id;
        crIdea.Title = 'Test Idea';
        crIdea.Body = 'Test body';
        crIdea.Product__c = crProduct.Id;
        crIdea.Institution__c = crAccount.Id;
        crIdea.Business_Purpose__c = 'Test';
        if(community.Id != null)
            crIdea.CommunityId = community.Id;
        try
        {
            insert crIdea;
        }
        catch(Exception ex)
        {
            System.debug('Error on insert of Idea'+ex.getMessage());    
        }*/
        
    }

}