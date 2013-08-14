/**
	* ChatterCleanupServiceSch - <description>
	* @author: Rainmaker Admin Ellucian
	* @version: 1.0
*/

global  class ChatterCleanupServiceSch implements Schedulable {

	global void execute(SchedulableContext sc) {
      ChatterCleanupService chatter = new ChatterCleanupService(); 
      database.executebatch(chatter); 
    } 
}