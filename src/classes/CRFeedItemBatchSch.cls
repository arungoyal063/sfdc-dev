/**
*********************************************************************************************************************
* Module Name   :  CRFeedItemBatchSch
* Description   :  Scheduler for CRFeedItemBatch 
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    : CRFeedItemBatch 
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      02/10/2013     Milligan         1195             Initial Version
*   
*******************************************************************************************************************
**/
global class CRFeedItemBatchSch implements Schedulable {
    global void execute(SchedulableContext sc) {
      CRFeedItemBatch b = new CRFeedItemBatch(); 
      database.executebatch(b); 
    } 
     
    /*static testmethod void testCRFeedItemBatchSch(){          
      Test.startTest();
      String jobId = System.schedule('CR FeedItem batch','0 15 0 * * ?', new CRFeedItemBatchSch());
      // Get the information from the CronTrigger API object     
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
      //Verify the expressions are the same     
      //System.assertEquals( '0 0 9 * * ?',ct.CronExpression);
      // Verify the job has not run    
      System.assertEquals(0, ct.TimesTriggered);

       Test.stopTest();       
    }*/
}