@isTest
public with sharing class EmailMessage_Inbound_ActivityHistoryTEST {
/*********************************************************************************************************************
* Module Name   :  Test Class for EmailMessage_Inbound_ActivityHistory Trigger
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author           WO#         Description of Action
* 1.0      07/17/2013      Justin Padilla   Ellucian    Test class for EmailMessage_Inbound_ActivityHistory Trigger
*******************************************************************************************************************/
    static testMethod void TriggerTest()
    {
        //Retrieve a record Type
        RecordType rt = [SELECT RecordType.Id FROM RecordType where RecordType.SobjectType = 'Case' LIMIT 1];
        //Retrieve and Account
        Account account = [SELECT Account.Id FROM Account LIMIT 1];
        //Create a Case
        Case theCase = new Case();
        theCase.RecordTypeId = rt.Id;
        theCase.AccountId = account.Id;
        theCase.Subject = 'TEST';
        insert(theCase);
        //Create an EmailMessage
        EmailMessage email = new EmailMessage();
        email.ParentId = theCase.Id;
        email.Subject = 'TEST';
        email.TextBody = 'TESTING';
        email.Incoming = true;
        insert(email);
    }
    
}