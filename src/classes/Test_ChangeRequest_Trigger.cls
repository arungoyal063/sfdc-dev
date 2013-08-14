/*********************************************************************************************************************
* Module Name   :  Test_ChangeRequest_Trigger Test Class 
* Description   :  Test Class for ChangeRequest_Trigger trigger on change request Object
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      06/08/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest(SeeAllData = true)
public with sharing class Test_ChangeRequest_Trigger {
 	
 	static testMethod void myUnitTest() {
 		User userObj = [SELECT Id, ContactId FROM User WHERE ContactId != null AND IsActive = true LIMIT 1];
    	Contact con = [SELECT Id FROM Contact WHERE Id =: userObj.ContactId LIMIT 1];                
	 	Change_Request__c changeRequest = MockTestData.createCRRecord('Test');
	 	
	 	Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');
	 	c.ContactId = con.Id;
	 	update c;
	 	
	 	Case_Follower__c cfollowerobj = new Case_Follower__C();
	 	cfollowerobj.Case__c = c.id;
	 	cfollowerobj.Follower__c = UserInfo.getUserId();  	
	 	insert cfollowerobj;	 	
	 	
	 	changeRequest.Originating_Case__c = c.Id;
		update changeRequest;	
 	}

}