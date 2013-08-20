/*******************************************************************************************************************
** Module Name   : CaseEmailAlert
** Description   : To call the function from the trigger "CaseEmailAlert"
** Throws        : NA
** Calls         : NA
** Test Class    : CaseEmailAlert_UnitTest
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun               Initial Version
******************************************************************************************************************/

public with sharing class CaseEmailAlert {
	public static Boolean isUpadted = false;
	
	
	// will save Escalation_Track__c record  if any update is not done on case object according to criteria
	public static Escalation_Track__c sendMail(Case lCaseObj, String mailNotificationTime)
	{
		system.debug('lCaseObj...'+lCaseObj + 'mailNotificationTime....' + mailNotificationTime);
		Escalation_Track__c escTrac = new Escalation_Track__c();
 		escTrac.Case__c = lCaseObj.id;
 		escTrac.CaseLastModifiedBy__c = string.valueof(lCaseObj.LastModifiedById);
 		escTrac.CaseLastModifiedDate__c = string.valueof(lCaseObj.LastModifiedDate);
 		escTrac.Case_Mail_Notification_Time__c = mailNotificationTime;
 		escTrac.CaseType__c = lCaseObj.Type;
 		escTrac.Case_Priority__c = lCaseObj.Priority;
 		escTrac.Case_Number__c = lCaseObj.CaseNumber;
 		escTrac.Case_Status__c = lCaseObj.Status;
 		escTrac.Case_Account_Manager_Email__c = lCaseObj.Account_Manager_Email__c;
 		escTrac.Case_Engagement_Manager_Email__c = lCaseObj.Engagement_Manager_Email__c;
 		system.debug('>>>>>>>>>Escalation_Track__c>>>>>>>'+ escTrac);         
        return escTrac;
	}
}