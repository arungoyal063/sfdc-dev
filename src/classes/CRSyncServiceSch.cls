/**
	* CRSyncServiceSch - <description>
	* @author: Rainmaker Admin Ellucian
	* @version: 1.0
*/
global class CRSyncServiceSch implements Schedulable{
	
	global void execute(SchedulableContext sc) {
      CRSyncService follow = new CRSyncService();
      database.executebatch(follow); 
    } 	
    
    static testmethod void testCRSyncServiceSch(){          
      Test.startTest();
      String jobId = System.schedule('CRSyncServiceSch','0 15 0 * * ?', new CRSyncServiceSch());
      // Get the information from the CronTrigger API object     
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
      //Verify the expressions are the same     
      //System.assertEquals( '0 0 9 * * ?',ct.CronExpression);
      // Verify the job has not run    
      System.assertEquals(0, ct.TimesTriggered);

      Test.stopTest();       
    }
}