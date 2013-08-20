/*******************************************************************************************************************
** Module Name   : CaseEmailAlert_UnitTest
** Description   : To call the function from the trigger "CaseEmailAlert"
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun               Initial Version
******************************************************************************************************************/

@isTest(SeeAllData = true)
public with sharing class CaseEmailAlertTrigger_UnitTest 
{
    Static TestMethod Void caseEmailAlertTrigger_Test()
    {
        RecordType rt = [SELECT id FROM RecordType WHERE sobjecttype = 'case' AND name = 'Customer Request' LIMIT 1 ];
        BusinessHours Bh = [SELECT id FROM BusinessHours where IsActive = true AND IsDefault = true];
        Case ca = new Case();
        ca.RecordTypeId = rt.id;
        ca.Priority = 'Medium';
        ca.Type = 'Problem';
        ca.Reason = 'Training';
        ca.Status = 'New';
       
        ca.BusinessHoursId = Bh.id;
        ca.New_Unread_Email__c = false;
        insert ca;
            ca.New_Unread_Email__c = true;
            ca.CaseLastUpdationTime__c = System.Now().addHours(-2);
            update ca;       
    } 
    Static TestMethod Void caseEmailAlertTrigger_TestFor5Hours()
    {
        RecordType rt = [SELECT id FROM RecordType WHERE sobjecttype = 'case' AND name = 'Customer Request' LIMIT 1 ];
        BusinessHours Bh = [SELECT id FROM BusinessHours where IsActive = true AND IsDefault = true];
        Case ca = new Case();
        ca.RecordTypeId = rt.id;
        ca.Priority = 'Medium';
        ca.Type = 'Problem';
        ca.Reason = 'Training';
        ca.Status = 'New';
       
        ca.BusinessHoursId = Bh.id;
        ca.New_Unread_Email__c = false;
        insert ca;
            ca.New_Unread_Email__c = true;
            ca.CaseLastUpdationTime__c = System.Now().addHours(-4);
            update ca;       
    } 
    Static TestMethod Void caseEmailAlertTrigger_TestFor3Hours()
    {
        RecordType rt = [SELECT id FROM RecordType WHERE sobjecttype = 'case' AND name = 'Customer Request' LIMIT 1 ];
        BusinessHours Bh = [SELECT id FROM BusinessHours where IsActive = true AND IsDefault = true];
        Case ca = new Case();
        ca.RecordTypeId = rt.id;
        ca.Priority = 'Medium';
        ca.Type = 'Problem';
        ca.Reason = 'Training';
        ca.Status = 'New';
       
        ca.BusinessHoursId = Bh.id;
        ca.New_Unread_Email__c = false;
        insert ca;
            ca.New_Unread_Email__c = true;
            ca.CaseLastUpdationTime__c = System.Now().addHours(-8);
            update ca;       
    }
    Static TestMethod Void caseEmailAlertTrigger_TestFor4Hours()
    {
        RecordType rt = [SELECT id FROM RecordType WHERE sobjecttype = 'case' AND name = 'Customer Request' LIMIT 1 ];
        BusinessHours Bh = [SELECT id FROM BusinessHours where IsActive = true AND IsDefault = true];
        Case ca = new Case();
        ca.RecordTypeId = rt.id;
        ca.Priority = 'Medium';
        ca.Type = 'Problem';
        ca.Reason = 'Training';
        ca.Status = 'New';
       
        ca.BusinessHoursId = Bh.id;
        ca.New_Unread_Email__c = false;
        insert ca;
            ca.New_Unread_Email__c = true;
            ca.CaseLastUpdationTime__c = System.Now().addHours(-24);
            update ca;       
    } 
   
}