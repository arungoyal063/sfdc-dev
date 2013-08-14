/*********************************************************************************************************************
* Module Name   :  Test_ShareRecordWithCommunity Test Class 
* Description   :  Test Class for ShareRecordWithCommunityTrigger trigger on Idea
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
    @isTest(seeAllData=true)
    private class Test_ShareRecordWithCommunity {
        static testMethod void ShareRecordWithCommunityUnitTest() { 
            Profile p = [SELECT Id FROM profile WHERE name='Ellucian Communities Profile' Limit 1];
            List<User> userList = [Select AccountId from User where ProfileId = :p.Id Limit 1];            
            Community_User__c cu = new Community_User__c();
            cu.Account__c = userList.get(0).AccountId;
            Insert cu;
        }
    
    }