trigger checkAssignmentHours on Appirio_PSAe__Timecard__c (before insert,before update) {


  //   Profile pf = [SELECT Id,Name FROM Profile WHERE Id =:Userinfo.getProfileId() limit 1]; 
    if(!processController.isProcessed)
        {
    for(Appirio_PSAe__Timecard__c tc : Trigger.new)
    {
         List<Appirio_PSAe__Assignment__c> currAssign = [SELECT id, Appirio_PSAe__Remaining_Billable_Hours__c, Appirio_PSAe__End_Date__c,Appirio_PSAe__Actual_Billable_Hours__c,Appirio_PSAe__Total_Assignment_Hours__c        
                                                     FROM Appirio_PSAe__Assignment__c
                                                     WHERE id =: tc.Appirio_PSAe__Assignment__c];

        if(currAssign.size()>0)
        { 
        if(Trigger.isInsert){
            processController.isProcessed = true;
        }
        
//        if((currAssign[0].Appirio_PSAe__Remaining_Billable_Hours__c < tc.Appirio_PSAe__Week_Total_Hrs__c) && pf.Name != 'System Administrator')        
            if(currAssign[0].Appirio_PSAe__Remaining_Billable_Hours__c < tc.Appirio_PSAe__Week_Total_Hrs__c)
            {
             //   tc.adderror('Your assignment does not have enough hours.  Contact the Project Manager.'+currAssign[0].Appirio_PSAe__Remaining_Billable_Hours__c +'  fds fds '+tc.Appirio_PSAe__Week_Total_Hrs__c+'....currAssign....'+currAssign);
                tc.adderror('Your assignment does not have enough hours.  Contact the Project Manager.');
            }
            else if(currAssign[0].Appirio_PSAe__Remaining_Billable_Hours__c == tc.Appirio_PSAe__Week_Total_Hrs__c || currAssign[0].Appirio_PSAe__End_Date__c == date.today())
            {
                currAssign[0].Appirio_PSAe__Status__c = 'Closed';
                
            }
          }  
        }
    }
}