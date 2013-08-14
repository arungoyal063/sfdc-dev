@istest(SeeAllData=true)
public class Test_ESCUserControllerExt {
    static testMethod void ESCUserControllerExt_UnitTest() {
         User pu = MockTestData.getPortalUser();    
         System.runas(pu) {         	
     	               
            Community_User__c ESCUser = new Community_User__c();
            ESCUser.Account__c = pu.AccountId;
            Insert ESCUser;            
            
             ApexPages.StandardController std = new ApexPages.StandardController(ESCUser);
             ESCUserControllerExt escObj = new ESCUserControllerExt(std); 
             escObj.redirectOnload();
             //Community_User__c ESCUser = [SELECT Id, RelatedUserId__c FROM Community_User__c 
                                                                         //WHERE RelatedUserId__c =:pu.Id LIMIT 1];
         }
    } 
}