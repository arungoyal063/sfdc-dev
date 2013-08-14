/*******************************************************************************************************************
** Module Name   : ListMetaDataScheduler
** Description   : Apex Scheduler for Refreshing of Listview Metadata
** Throws        : NA
** Calls         : NA
** Test Class    : ListMetaDataSchedulerTest
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-16-07  Rainmaker             Initial Version
******************************************************************************************************************/

public class ListMetaDataScheduler implements Schedulable {
   public void execute(SchedulableContext SC) {
       List<LisViewtMetaDataBatch.Item> itemsList = new List<LisViewtMetaDataBatch.Item>();
       LisViewtMetaDataBatch.Item scheduleItem = new LisViewtMetaDataBatch.Item();
       itemsList.add(scheduleItem);
       LisViewtMetaDataBatch.run(itemsList); 
   }  
}