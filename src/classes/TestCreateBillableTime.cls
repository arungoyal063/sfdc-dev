/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<TestCreateBillableTime>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<22-11-2012>>
// Last Modified Date.....: <<22-11-2012>>
// Description/Requirement: <<Test Class for CreateBillableTime Trigger>>
//---------------------------------------------------------------------------------------------------------------------------*/
@isTest (SeeAllData=true)
private class TestCreateBillableTime {
     static testMethod void CreateBillableTriggerUnitTest() { 
         //Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test'); // Case Created
        Case c = [Select Status, Origin, Priority, Problem_Statement__c, Resolution_Summary__c From Case limit 1];//(Status = 'New', Origin = 'Email', Priority = 'Level 3', Problem_Statement__c = 'Test', Resolution_Summary__c = 'Test');
        //try {
        //    insert c;
        //} catch(Exception e) { System.debug('Error :' + e);}        
        Task newTask = MockTestData.createTaskRecord(c.Id); // Task Created         
        List<Billable_Time__c> btList = [Select b.Task_ID__c, b.Minutes__c, b.Date_Work_Performed__c, b.Case__c From Billable_Time__c b where Task_ID__c =:newTask.Id Limit 1];
        if(!btList.isEmpty()) {
             Billable_Time__c bt = btList.get(0);
             //System.assertEquals(newTask.Billable_Minutes__c, bt.Minutes__c);
            // System.assertEquals(newTask.ActivityDate, bt.Date_Work_Performed__c);
             //System.assertEquals(newTask.Id, bt.Task_ID__c);             
        }         
        Task billTask = MockTestData.createNonBillTaskRecord(c.Id); // Task Created         
        billTask.Billable_Minutes__c = 100;          
        try {
             update billTask;
             update newTask;
             delete newTask;
        } catch(Exception e) {
            System.debug('Error :' + e);
        }   
     }
}