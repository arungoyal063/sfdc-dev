/*********************************************************************************************************************
* Module Name   :   UpdateCaseModification_OnRelatedCase Trigger
* Description   :  
* Throws        :  
* Calls         :  
* Test Class    :  TestUpdateCaseModification_OnRelatedCase
* 
* Organization  :  Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      07/17/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest
private class TestUpdateCaseModification_OnRelatedCase {
//Test for Insert
	static testMethod void myTestMethod1() {
	   try{
	       Case c1 = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');
	       Case c2 = MockTestData.createCaseRecord('Open', 'Email', 'Level 2', 'Test1','Test1');
	       //To Check insert senario
	       Case_to_case_junction_object__c cToC = MockTestData.createCaseJunctionRecord(c1.Id, c2.Id);
	       
	   }catch(Exception e){
	   		System.debug('Error in TestUpdateCaseModification_OnRelatedCase >>>>>  myTestMethod1 '+e);
	   }
	}  
//Test for Delete
    static testMethod void myTestMethod2() {
		try{
	       Case c1 = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test3','Test');
	       Case c2 = MockTestData.createCaseRecord('Open', 'Email', 'Level 2', 'Test4','Test1');
	       //To Check insert senario
	       Case_to_case_junction_object__c cToC = MockTestData.createCaseJunctionRecord(c1.Id, c2.Id);
	       //To Check delete senario
	       delete cToc;
   		}
       catch(Exception e){
   			System.debug('Error in TestUpdateCaseModification_OnRelatedCase >>>>>  myTestMethod2 '+e);
   		}
	}
//Test for Negative Test
	static testMethod void myTestMethod3() {
		try{
	       Account a1 = MockTestData.createAccountRecord('Acc1', 100);
	       Case c2 = MockTestData.createCaseRecord('Open', 'Email', 'Level 2', 'Test4','Test1');
	       //To Check insert senario
	       Case_to_case_junction_object__c cToC = MockTestData.createCaseJunctionRecord(a1.Id, c2.Id);
	       //To Check delete senario
	       update cToc;
   		}
       catch(Exception e){
   			System.debug('Error in TestUpdateCaseModification_OnRelatedCase >>>>>  myTestMethod3 '+e);
   		}
	}
}