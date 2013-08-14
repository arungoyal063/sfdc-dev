/*******************************************************************************************************************
** Module Name   : Test_ChatterSyncService
** Description   : Test Class
** Throws        : NA
** Calls         : NA
** Test Class    : ChatterSyncService
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun              
******************************************************************************************************************/
@isTest
private class Test_ChatterSyncService {

    private static testmethod void testSyncService() {
    	
    	List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
        User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(mockUser){
	        Test.StartTest();
	        ChatterSyncService upc =  new ChatterSyncService();       
	       	ID batchprocessid = Database.executeBatch(upc);
	        Test.StopTest();
        }
        
        
    	/*Test.StartTest();
		List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
		User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
		system.runAs(mockUser){
			ChatterSyncService batchRun = new ChatterSyncService();
	        ID batchprocessid = Database.executeBatch(batchRun, 1);    
	        //AsyncApexJob a1 = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchprocessid];
	        //System.debug('\n\nFinal results are: '+a1);
	        //System.AssertEquals('Queued', a1.status);
	        //System.AssertEquals(0, a1.NumberOfErrors);
		}
		Test.stopTest();*/
	}
}