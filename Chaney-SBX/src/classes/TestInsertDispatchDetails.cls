/*********************************************************************************************************************
** Module Name   : TestInsertDispatchDetails
** Description   : Test Class for InsertDispatchDetails
** Throws        : N/A
** Calls         : N/A
** Test Class    : N/A
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author      WO#         Description of Action
** 1.0      08/01/2013     KL        XXXX            Initial Version
*******************************************************************************************************************/
@isTest
private class TestInsertDispatchDetails {

    @isTest(SeeAllData=true)
    static void testProcess() {
        Quota__c q = [SELECT id,Name,Quota_Family__c,plant__c,month__c,OwnerId FROM Quota__c WHERE Month__c=2013-01-01 AND OwnerId = '005700000015Atl' LIMIT 1];
        Account a = [SELECT Account_num__C FROM ACCOUNT WHERE Account_num__C != NULL LIMIT 1];
        //Account a = new Account();
        //a.Name  = 'Test Account';
        //a.Account_num__C = '12311';
        //insert a;
        Dispatch_Sale__c ds = new Dispatch_Sale__c();
        ds.Customer_Number__c = a.Account_num__C;
        ds.Account_Number__c =  a.Account_num__C;
        ds.Units_Delivered__c = 12312;
        ds.Delivery_Date__c = Date.newInstance(2013,1,1); 
        ds.source_system__c = 'Dispatch';
        ds.Product__c = [SELECT ID FROM Product2 where name= :q.Quota_Family__c limit 1].id;
        ds.Plant__c = q.plant__c;
        ds.Dispatch_Owner__c = '005700000015Atl';
        insert ds;
    }
}