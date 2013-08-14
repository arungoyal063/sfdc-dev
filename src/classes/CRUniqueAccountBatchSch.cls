/**
*********************************************************************************************************************
* Module Name   :  CRUniqueAccountBatchSch
* Description   :  Scheduler for CRUniqueAccountBatch 
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    : CRUniqueAccountBatch 
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      05/06/2013     Milligan         362              Initial Version
*   
*******************************************************************************************************************
**/
global class CRUniqueAccountBatchSch implements Schedulable {
    
    global void execute(SchedulableContext sc) {
      CRUniqueAccountBatch b = new CRUniqueAccountBatch(); 
      database.executebatch(b); 
    } 
      
    /*static testmethod void testCRUniqueAccountBatch(){
          
      Test.startTest();
      String jobId = System.schedule('CRUniqueAccountBatch','0 15 0 * * ?', new CRUniqueAccountBatchSch());
   // Get the information from the CronTrigger API object 
    
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];

     //Verify the expressions are the same 
    
      System.assertEquals( '0 0 9 * * ?',ct.CronExpression);

   // Verify the job has not run 
    
      System.assertEquals(0, ct.TimesTriggered);

       Test.stopTest();       
    }*/
}