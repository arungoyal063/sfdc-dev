/**
*********************************************************************************************************************
* Module Name   :  AccountTeamEmailBatchSch
* Description   :  Scheduler for AccountTeamEmailBatch 
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    : AccountTeamEmailBatch
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date        	  Author      	   WO#         Description of Action
* 1.0      02/10/2013     Milligan         1149        		Initial Version
*   
*******************************************************************************************************************
**/
global class AccountTeamEmailBatchSch implements Schedulable {
    
    global void execute(SchedulableContext sc) {
      AccountTeamEmailBatch b = new AccountTeamEmailBatch(); 
      database.executebatch(b); 
    } 
     
    static testmethod void testAccountTeamEmailBatchSch(){
          
       Test.startTest();
    //  String jobId = System.schedule('Account Team Email Batch','0 15 0 * * ?', new AccountTeamEmailBatchSch());
      String jobId = System.schedule('Account Team Email Batch','0 5 0 * * ?', new AccountTeamEmailBatchSch());
   // Get the information from the CronTrigger API object 
    
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];

       Test.stopTest();       
    }
}