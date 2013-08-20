trigger CalculateBillingHours on Appirio_PSAe__Proj__c (after insert, after update) {

// added code
System.debug('insert Trigger....1....'+TriggerRunOnce.runOnce());
    if(Trigger.isAfter){
    	
    	System.debug('insert Trigger....2');
    	
    	List<Appirio_PSAe__Proj__c> projList = new List<Appirio_PSAe__Proj__c>();
    	Appirio_PSAe__Proj__c project = new Appirio_PSAe__Proj__c();
    	String projectID;
    	String currentID;
    	decimal totalChildHours = 0;
    	decimal Newvalue = 0;
    	decimal oldValue = 0;
    	decimal totalHours = 0;
    	decimal totalInvoiced = 0;
    	decimal totalUninvoiced = 0;
    	decimal totalHoursBillableLogged = 0;
    	decimal totalChildHoursReamaing = 0;
    	for(Appirio_PSAe__Proj__c proj : Trigger.new){
    		projectID = proj.Parent_Project__c;
    		currentID =  proj.Id;
    		Newvalue = proj.Appirio_PSAe__Billable_Hours_Remaining__c;
    	}
    	
    	System.debug('...projectID..'+projectID);
    	if(projectID != null && projectID != '')
    	{
    		// addedc code 
    		projList = [select Appirio_PSAe__Hours_Allocated__c,Appirio_PSAe__Total_Billable_Hours_Invoiced__c,Appirio_PSAe__Total_Billable_Hours_Uninvoiced__c,Appirio_PSAe__Total_Nonbillable_Hours_Logged__c,Appirio_PSAe__Total_Billable_Hours_Logged__c,Child_Billable_Hrs_Remaining__c,Appirio_PSAe__Billable_Hours_Remaining__c from Appirio_PSAe__Proj__c where Parent_Project__c =: projectID];
    		System.debug('projList......'+projList.size());
    		for (Appirio_PSAe__Proj__c proj:projList)
    		{
    			totalChildHours = totalChildHours +  proj.Appirio_PSAe__Hours_Allocated__c;
    			totalInvoiced  = totalInvoiced + proj.Appirio_PSAe__Total_Billable_Hours_Invoiced__c;
    			totalUninvoiced = totalUninvoiced + proj.Appirio_PSAe__Total_Billable_Hours_Uninvoiced__c;
    			totalHoursBillableLogged = totalHoursBillableLogged + proj.Appirio_PSAe__Total_Nonbillable_Hours_Logged__c;
    			totalChildHoursReamaing = totalChildHoursReamaing + proj.Appirio_PSAe__Billable_Hours_Remaining__c;
    		}
    		
    		System.debug('totalChildHours.....'+totalChildHours+'....totalInvoiced'+totalInvoiced+'.....'+totalUninvoiced+'....totalHoursBillableLogged....'+totalHoursBillableLogged+'..................'+totalChildHoursReamaing);
    		
    		project = [select Appirio_PSAe__Hours_Allocated__c,Appirio_PSAe__Total_Billable_Hours_Invoiced__c,Appirio_PSAe__Total_Billable_Hours_Uninvoiced__c,Appirio_PSAe__Total_Nonbillable_Hours_Logged__c,Total_Allo__c,Appirio_PSAe__Total_Billable_Hours_Logged__c,Child_Billable_Hrs_Remaining__c,Appirio_PSAe__Billable_Hours_Remaining__c from Appirio_PSAe__Proj__c where Id =: projectID];
    		System.debug('projList...........'+projList.size());

    		// addded code 
    		project.Total_Allo__c = totalChildHours;
    	 	project.Total_Invoiced_Hours_Allo__c = totalInvoiced;
    	 	project.Total_UNInvoiced_Hours_Allocate_to_Child__c = totalUninvoiced;
    	 	project.Total_NonBillable_Hours_Logged_for_Child__c = totalHoursBillableLogged;
    	 	project.Child_Billable_Hrs_Remaining__c = totalChildHoursReamaing;
    		 
    		/*
    		if(Trigger.isAfter && Trigger.isUpdate)
    		{
    			oldValue  = Trigger.oldMap.get(Trigger.new[0].Id).Appirio_PSAe__Billable_Hours_Remaining__c;	
    		}
    		System.debug('oldValue.....'+oldValue+'...Newvalue......'+Newvalue+'project.Child_Billable_Hrs_Remaining__c.......'+project.Child_Billable_Hrs_Remaining__c);
    		if(Trigger.isUpdate){
    			if(project.Child_Billable_Hrs_Remaining__c == null)
    	 		project.Child_Billable_Hrs_Remaining__c =  - Math.abs(oldValue - Newvalue);
    	 		else
    	 		project.Child_Billable_Hrs_Remaining__c = project.Child_Billable_Hrs_Remaining__c - Math.abs(oldValue - Newvalue);
   	 		
    	 	}else{
    	 		project.Child_Billable_Hrs_Remaining__c = project.Child_Billable_Hrs_Remaining__c + Newvalue;
    	 	}
    	 	 
    	 	*/
    	 	update project;
    	 	 
	    }
	    
	        
}
}