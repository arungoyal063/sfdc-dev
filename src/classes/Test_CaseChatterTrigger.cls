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
@isTest
private class Test_CaseChatterTrigger {
    //This method is used for update scenario
    static testMethod void myUnitTest() {
    	try{
          List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
          User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
          system.runas(mockuser){    
                  Case_Follower__c follower = new Case_Follower__c();
                  Case c = MockTestData.createCaseRecord('Close2', 'web', 'level 3', 'test1','abc');
		          follower.Case__c = c.id;
		          follower.Follower__c = mockuser.id;
		          //this is used for insert scneario
		          insert follower;
		          //this is used for update scenario
		          update follower;
		 
          }
   		}catch(Exception e){
        	system.debug('this error is generated in Test_CaseChatterTrigger>>>>' + e);
        }
       
    } 
    //this method is used for inserting scenario           
    static testMethod void myUnitTest1() {   	
   	    try{
       	     List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
             User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
           	 system.runas(mockuser){
            	Case_Follower__c follower = new Case_Follower__c();
        	    Case  c  =    MockTestData.createCaseRecord('Open', 'Lead', 'Level 2', 'test1', 'Test2');
	          	follower.Case__c = c.id;
		        follower.Follower__c = mockuser.id;
		        //this is used for insert
		        insert follower;
           	}
         }catch(Exception e ){
           system.debug('this error is generated in Test_CaseChatterTrigger>>>insert method'+ e);
         }
   }
   // this method is used for delete                         
    static testMethod void myUnitTest2() {
       try{
           List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
           User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
           system.runas(mockuser){
   	                Case_Follower__c follower = new Case_Follower__c(); 
                    Case  c  =    MockTestData.createCaseRecord('Close1', 'Lead', 'Level 2', 'test1', 'Test23'); 
                    follower.Case__c = c.id;
		            follower.Follower__c = mockuser.id;
		            //this is used for insert scenario
	                insert follower;
	                //this is used for delete sceario
	              	delete follower;
         	}
       }catch(Exception e){
            system.debug('this error is generated in Test_CaseChatterTrigger>>>delete method'+e); 
       } 
    } 
}