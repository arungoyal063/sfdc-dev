trigger CreateAssignmentbyWO on Work_Order__c (after insert, after update) {
    
    System.debug('run....Once...');
    if(TriggerRunOnce.runOnce()) 
    { 
    String woId;
    String woHour;
    String woName;
    String woStage;
    String woProjectID;
    String resource;
    String check; 
    
    Work_Order__c workOrder;
    Appirio_PSAe__Assignment__c assignObj = new Appirio_PSAe__Assignment__c();
    Appirio_PSAe__Proj__c parentProject;
    Appirio_PSAe__Resource__c resourceObj;
      
   for (Work_Order__c wo : Trigger.new)   
   {
   		workOrder = wo;
   	 	woId = wo.Id;
    	woHour = wo.Budgeted_Hours__c;
    	woName = wo.Name;
    	woStage = wo.Stage__c;
    	woProjectID = wo.Project__c;
    	resource =  wo.Technical_Lead__c;
    	check = wo.CreateAssign__c;
   }
   
    System.debug('check.....'+check);
     
    if(woStage == 'Client Approved' && check != 'true')
    {
    parentProject = [select Rate__c,Appirio_PSAe__Total_Nonbillable_Hours_Logged__c,Appirio_PSAe__Total_Billable_Hours_Logged__c,Child_Billable_Hrs_Remaining__c,Appirio_PSAe__Billable_Hours_Remaining__c from Appirio_PSAe__Proj__c where Id =: woProjectID];
    
    System.debug('parentProject.....'+parentProject);
    if(resource != null && resource != '')
    {
        try
        {
            resourceObj = [select Id,Appirio_PSAe__Salesforce_User__c from Appirio_PSAe__Resource__c where Appirio_PSAe__Salesforce_User__c =: resource limit 1];
        }
        catch(Exception ex)
            {
                System.debug('in catch'+resourceObj);
            if(resourceObj == null)
            {
                        System.debug('nul resource');
                        Trigger.new[0].addError('Error : This TechLead user does not have any resource.');
                        
            }
            }
    }
    System.debug('resourceObj.........'+resourceObj);
    
        if(parentProject != null && parentProject.Rate__c != null)
                    assignObj.Appirio_PSAe__Rate_Per_Hour__c = parentProject.Rate__c;
            
            // added project 
            assignObj.Appirio_PSAe__Projects__c = woProjectID;
    
            // added other fields
            assignObj.Appirio_PSAe__Description__c = woName;
            assignObj.Work_Order__c = woId;
            assignObj.Appirio_PSAe__Total_Assignment_Hours__c = Decimal.valueOf(woHour);
            assignObj.Appirio_PSAe__Start_Date__c = System.today(); 
            assignObj.Appirio_PSAe__End_Date__c =  System.today().addDays(30);
            assignObj.Appirio_PSAe__Status__c = 'Scheduled';
            // validation for Resource 
            if(resourceObj != null)
            assignObj.Appirio_PSAe__Resource__c =  resourceObj.Id;
             
            try
            {
                insert assignObj; 
            }
            catch(Exception ex)
            {
                    Integer firstIndex = ex.getMessage().indexOf('first error:');
                    String msg = ex.getMessage().substring(firstIndex+12);
                    Trigger.new[0].addError('Error : '+msg);
            }
            
            // update Work Order
    	workOrder = [select CreateAssign__c,Id from Work_Order__c where id=: woId];
    	workOrder.CreateAssign__c = 'true';
    	update workOrder;
    }
    
    }
}