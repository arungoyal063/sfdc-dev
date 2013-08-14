/*******************************************************************************************************************
** Module Name   : Test_BatchClassArticlesch
** Description   : Test Class
** Throws        : NA
** Calls         : NA
** Test Class    : BatchClassArticlesch
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                 14/07/2013      algo            
******************************************************************************************************************/
@isTest
private class Test_BatchClassArticlesch {
	
	Static TestMethod void UnitTest(){
		List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
        User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(mockUser){
            Test.StartTest();
            BatchClassArticlesch clsCRON = new BatchClassArticlesch();
            String sch = '0 0 23 * * ?';
            system.schedule('Test BatchClassArticlesch', sch, clsCRON);
            Test.stopTest();
        }
	}
}