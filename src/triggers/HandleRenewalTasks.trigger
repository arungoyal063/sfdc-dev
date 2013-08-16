/**
	* HandleRenewalTasks - <description>
	* @author: Rainmaker Admin
	* @version: 1.0
*/

trigger HandleRenewalTasks on Opportunity bulk (after update) {

	Set<String> accntIds = new Set<String>();
	
	try{
		RecordType rt = [select Id from RecordType where Name like 'Renewal (biNOW/OAN)' and SobjectType = 'Opportunity' limit 1];
		
		for(Opportunity o: Trigger.New){
			if((o.RecordTypeId == rt.Id) && (o.StageName == 'Closed Lost')){
				if(!accntIds.contains(o.AccountId)){
					accntIds.add(o.AccountId);
				}
			}
			 
		}	
		
		if(accntIds.size() > 0){
			Task[] tasksToDelete = [Select T.AccountId, T.Status, T.Subject from Task T WHERE T.Status != 'Completed' AND  T.AccountId IN: accntIds];
			
			delete tasksToDelete;
		}
		
		
	}catch(Exception ex){}

}