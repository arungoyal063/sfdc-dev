/*******************************************************************************************************************
** Module Name   : GTMConsoleExtension
** Description   : Get Record from ConnectGoToMeeting object on the basis of UserID
** Throws        : No
** Calls         : No
** Test Class    : <GTMConsoleExtension_unitTest>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/
public with sharing class GTMConsoleExtension {
    public GTMConsoleExtension(Apexpages.StandardController controller) {
        showAlreadyExisting = false;
        GTMAccessToken__c workingToken;
        try {
            workingToken = [SELECT
                    GTMAccessToken__c.Id,
                    GTMAccessToken__c.User__c,                      
                    GTMAccessToken__c.Expiry_Date__c
                    FROM GTMAccessToken__c
                    WHERE GTMAccessToken__c.User__c =: System.Userinfo.getUserId() LIMIT 1];
                    //Indicate to the user that they already have valid information, but allow them to update
                    if (!(workingToken.Expiry_Date__c == null || workingToken.Expiry_Date__c < Datetime.now())) {
                            showAlreadyExisting = true;
                    }
        }catch(QueryException ex) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
        }
    }
    public Boolean showAlreadyExisting{get;set;}
}