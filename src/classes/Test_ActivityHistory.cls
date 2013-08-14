/*********************************************************************************************************************
* Module Name   :  Test_ActivityHistory Test Class 
* Description   :  Test Class for ActivityHistory Case Standard Controller Extension
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      22/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest
private class Test_ActivityHistory{
    static testMethod void activityHistoryUnitTest() {
        Case c = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');   // Case Created 
        Task t = MockTestData.createTaskRecord(c.Id);                                          // Task Created
        ApexPages.CurrentPage().getParameters().put('id',c.Id);
        ApexPages.StandardController controller = new  ApexPages.StandardController(c);
        ActivityHistory act = new ActivityHistory(controller); 
    }
	
	static testMethod void activityHistoryUnitTest1() {
        Case c = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');   // Case Created 
        Task t = MockTestData.createTaskRecord(c.Id);                                          // Task Created
        ApexPages.CurrentPage().getParameters().put('id',c.Id);
        ApexPages.StandardController controller = new  ApexPages.StandardController(c);
        ActivityHistory act = new ActivityHistory(controller); 
        PageReference pr = act.logACall();
    }
}