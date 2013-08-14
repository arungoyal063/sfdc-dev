/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
@IsTest(SeeAllData=true)
private class Test_CasesSyncServiceUnitTest{

     static testmethod void testCaseSyncService() {
		List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
        User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(mockUser){
	        	Test.StartTest();
		
	       	CasesSyncService batchRun = new CasesSyncService();
            ID batchprocessid = Database.executeBatch(batchRun);    
                    
            AsyncApexJob a1 = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :batchprocessid];
            System.debug('\n\nFinal results are: '+a1);
            System.AssertEquals('Queued', a1.status);
            System.AssertEquals(0, a1.NumberOfErrors);
            
            Test.stopTest(); 
        }
		
	}
}