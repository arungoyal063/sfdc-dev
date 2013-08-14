/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<ChatterCleanupService>> 
// Version................: <<1.0>>
// CreatedBy..............: <<Algo>>
// Created Date...........: <<17-07-2013>>
// Last Modified Date.....: <<17-07-2013>>
// Description/Requirement: <<Test Classe for ChatterCleanupService>>
//---------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class Test_ChatterCleanupService {
    static testMethod void myUnitTest() {
    	Change_Request__c cr = MockTestData.createCRRecord('Test');
	    Change_Request_Follower__c cReqFollower = new Change_Request_Follower__c();
        cReqFollower.change_request__c = cr.Id;
        cReqFollower.Follower__c = [Select Id From User Where IsActive=true limit 1].Id;
        insert cReqFollower;
        List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
        User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(mockUser){
	        Test.StartTest();
	        ChatterCleanupService batchRun = new ChatterCleanupService();
            ID batchprocessid = Database.executeBatch(batchRun);
	        Test.StopTest();
        }
    }
}