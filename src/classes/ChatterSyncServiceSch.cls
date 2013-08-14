/**
	* ChatterSyncServiceSch - <description>
	* @author: Rainmaker Admin Ellucian
	* @version: 1.0
*/

global class ChatterSyncServiceSch implements Schedulable{
	
	global void execute(SchedulableContext sc) {
      ChatterSyncService chatter = new ChatterSyncService(); 
      database.executebatch(chatter); 
    } 

}