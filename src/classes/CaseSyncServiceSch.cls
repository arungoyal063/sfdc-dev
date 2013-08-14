/**
	* CaseSyncServiceSch - <description>
	* @author: Rainmaker Admin Ellucian
	* @version: 1.0
*/

global class CaseSyncServiceSch implements Schedulable{
	
	global void execute(SchedulableContext sc) {
      CasesSyncService follow = new CasesSyncService(); 
      database.executebatch(follow); 
    } 	
    
}