/*******************************************************************************************************************
** Module Name   : Test_BatchClassArticle
** Description   : Test Class
** Throws        : NA
** Calls         : NA
** Test Class    : batchClassArticle
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun              
******************************************************************************************************************/
@isTest
private class Test_BatchClassArticle {

    static testMethod void myUnitTest() {
        List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
        User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(mockUser){
	        Test.StartTest();
	        batchClassArticle upc =  new batchClassArticle();       
	       	ID batchprocessid = Database.executeBatch(upc);
	        Test.StopTest();
        }
    }
}