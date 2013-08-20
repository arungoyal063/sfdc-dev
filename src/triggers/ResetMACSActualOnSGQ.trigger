trigger ResetMACSActualOnSGQ on MACS_Data__c (after delete) {

	Set<String> SGList = new Set<String>();
    Set<String> YrList = new Set<String>();
    for(MACS_Data__c o : Trigger.old)
    {
    	SGList.add(String.valueOf(o.Carp_DM__c));
        YrList.add(String.valueOf(o.Cal_Year__c));
    }
    //List<Sales_Group_Quota__c> finalList = [Select Id, Actual_MACS__c from Sales_Group_Quota__c];
    List<Sales_Group_Quota__c> finalList = [Select Actual_MACS__c, Actual__c, Year__c, X11th_p_Total__c, Chairman_s_Club_Goal__c, Sales_Group_Id_New__c, Stretch_Goal__c, Super_Stretch_Goal__c from Sales_Group_Quota__c where Year__c in :YrList AND Sales_Group_Id_New__c in :SGList];
    
    for(Sales_Group_Quota__c g : finalList)
    {
        g.Actual_MACS__c = 0;
    }
    
    if(finalList.size() > 0)
    {
	    try{update finalList;}
	    catch(System.Exception e){}
    }
}