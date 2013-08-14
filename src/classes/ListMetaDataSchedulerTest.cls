@isTest
private class ListMetaDataSchedulerTest {
   static testmethod void testschedule() {
       Test.startTest();
           ListMetaDataScheduler scheduleObj = new ListMetaDataScheduler();
           String CRON_EXP = '0 0 23 * * ?';
           String jobId =  System.schedule('ListView Referesh Schedule', CRON_EXP, scheduleObj);
        
           CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                                 NextFireTime
                                 FROM CronTrigger WHERE id = :jobId];
                                 
          System.assertEquals(CRON_EXP, ct.CronExpression);
       Test.stopTest();
   }
}