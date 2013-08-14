trigger Case_ActivityHistory_Public on Task (before insert) {
/*********************************************************************************************************************
* Module Name   :  Case_ActivityHistory_Public Trigger
* Description   :  This Trigger is used to set the activity history for an email to the client as publically visible.
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <-->
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author           WO#         Description of Action
* 1.0      06/04/2013      Justin Padilla   Ellucian    Initial Version
*******************************************************************************************************************/
 boolean ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
if (ignoreTriggers==false)
{
    for (Task t:trigger.new)
    {
        //If the Database Type is an email - mark the task publically accessible
        if (t.DB_Activity_Type__c == 'Email')
        {
            t.IsVisibleInSelfService = true;
        }
    }
}
}