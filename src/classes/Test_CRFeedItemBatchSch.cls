/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<CRFeedItemBatchSch>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<12-07-2013>>
// Last Modified Date.....: <<12-07-2013>>
// Description/Requirement: <<Test Classes>>
//---------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class Test_CRFeedItemBatchSch{ 
    public static testMethod void Test_CRFeedItemBatchSchUnitTest() {
        List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
        User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(mockUser){
            Test.StartTest();
            CRFeedItemBatchSch crFIBS = new CRFeedItemBatchSch();
                    String sch = '0 0 23 * * ?';
                    system.schedule('Test CRFeedItemBatchSch', sch, crFIBS);
            Test.stopTest();
        }
    }
}