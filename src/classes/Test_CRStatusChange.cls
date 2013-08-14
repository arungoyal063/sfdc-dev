/*********************************************************************************************************************
* Module Name   :  Test_CRStatusChange Test Class 
* Description   :  Test Class for CRStatusChange trigger on change request Object
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      18/07/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest/*(seeAllData = true)*/
public with sharing class Test_CRStatusChange {
	
	static testMethod void myUnitTest() { 
         Change_Request__c changeRequest = MockTestData.createCRRecord('Test');  // change request Created
         try {
         	changeRequest.Status__c = 'Cancelled';
			update changeRequest;                  
         } catch(Exception e) {System.debug('Error :' + e);}
     }

}