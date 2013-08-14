/*********************************************************************************************************************
* Module Name   :  Test_UpdateCaseMileStone Test Class 
* Description   :  Test Class for UpdateCaseMileStone apex class
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest(seeAllData = true) 
private class Test_UpdateCaseMileStone {
   
    static testMethod void updateCaseMileStoneUnitTest() {
        Case c = MockTestData.createCaseRecord('New', 'Email', 'Level 1', 'Test','Test');   // Case Created 
        c.Milestone_Target_Date__c =  System.now();
        c.Priority='1';       	
       	Account acc = MockTestData.createAccountRecord('hello', 0);
       	Contact con = MockTestData.createContactRecord('ARun', acc.id);
       	con.Phone='233444';
       	c.AccountId=acc.Id;
       	c.ContactId=con.Id; 
       	system.debug('<<<<<<<<<<<<'+con.Phone+c.ContactId+con.Id);
       	Product2 pro = new Product2();
       	c.ProductId=pro.id;
       	pro.Product_Line__c='Banner';
       	pro.Product_Category__c='Student Services';
       	
       	system.debug('<<<<<<<<<<<<<<'+c.Product_Line__c);
       	
        List<Entitlement> entlList = [SELECT Licensed_Product__r.Product_New__c,status,Licensed_Product__c, Id FROM Entitlement WHERE status='Active' AND Entitlement_Type__c = 'Hawaii' LIMIT 1];
        if(!entlList.isEmpty()) {
            c.EntitlementId = entlList.get(0).Id;
            update c;
        }
    }

}