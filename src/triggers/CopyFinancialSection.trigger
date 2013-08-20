trigger CopyFinancialSection on Milestone1_Project__c (before insert ) {
    Set<Id> OppIds = new Set<Id>();
    
    if( Trigger.isUpdate || Trigger.isInsert ){
      for(Milestone1_Project__c mp : Trigger.New){
           oppIds.add(mp.Opportunity__c); 
      }
      
      List<Appirio_PSAe__Proj__c> psaeProj = [SELECT Id, Name, Appirio_PSAe__Opportunity__c, Appirio_PSAe__Total_Billable_Revenue_Invoiced__c, Appirio_PSAe__Total_Billable_Revenue_Pending_Invoice__c, Appirio_PSAe__Total_Billable_Revenue_Logged__c,
                                              Appirio_PSAe__Pct_Complete_By_Revenue__c, Appirio_PSAe__Backlog_In_Dollars__c, Appirio_PSAe__Backlog_To_Invoice__c, Appirio_PSAe__Billing_Alert__c, Appirio_PSAe__Total_Billable_Hours_Invoiced__c,
                                              Appirio_PSAe__Total_Billable_Hours_Uninvoiced__c, Appirio_PSAe__Total_Nonbillable_Hours_Logged__c, Appirio_PSAe__Total_Billable_Hours_Logged__c, Appirio_PSAe__Billable_Hours_Remaining__c
                                              FROM Appirio_PSAe__Proj__c WHERE Appirio_PSAe__Opportunity__c IN: oppIds];
      Map<Id,List<Appirio_PSAe__Proj__c>> projMap = new Map<Id,List<Appirio_PSAe__Proj__c>>();
      
      for(Id oppId : OppIds){
          List<Appirio_PSAe__Proj__c> temp = new List<Appirio_PSAe__Proj__c>();
          for(Appirio_PSAe__Proj__c proj : psaeProj){
              if(proj.Appirio_PSAe__Opportunity__c == oppId)
                  temp.add(proj);
          }
          projMap.put(oppId,temp);
      }
      
      for(Milestone1_Project__c mp : Trigger.New){
           List<Appirio_PSAe__Proj__c> pr = projMap.get(mp.Opportunity__c);
           if(pr.size() > 0){
               system.debug('<<<Atulit>>>>' +pr[0].Id);
               mp.PSe_Total_Billable_Revenue_Invoiced__c = pr[0].Appirio_PSAe__Total_Billable_Revenue_Invoiced__c;
               mp.PSe_TotalBillableRevenue_Pending_Invoice__c = pr[0].Appirio_PSAe__Total_Billable_Revenue_Pending_Invoice__c;
               mp.PSe_Total_Billable_Revenue_Logged__c = pr[0].Appirio_PSAe__Total_Billable_Revenue_Logged__c;
               mp.PSe_Pct_Complete_By_Revenue__c = pr[0].Appirio_PSAe__Pct_Complete_By_Revenue__c;
               system.debug('<<<Atulit>>>>' +pr[0].Appirio_PSAe__Pct_Complete_By_Revenue__c);
               mp.PSe_Backlog_To_Deliver__c = pr[0].Appirio_PSAe__Backlog_In_Dollars__c;
               mp.PSe_Backlog_To_Invoice__c = pr[0].Appirio_PSAe__Backlog_To_Invoice__c;
               mp.PSe_Billing_Alert__c = pr[0].Appirio_PSAe__Billing_Alert__c;
               system.debug('<<<Atulit>>>>' +pr[0].Appirio_PSAe__Billing_Alert__c);
               mp.PSe_Total_Billable_Hours_Invoiced__c = pr[0].Appirio_PSAe__Total_Billable_Hours_Invoiced__c;
               mp.PSe_Total_Billable_Hours_Uninvoiced__c = pr[0].Appirio_PSAe__Total_Billable_Hours_Uninvoiced__c;
               mp.PSe_Total_Nonbillable_Hours_Logged__c = pr[0].Appirio_PSAe__Total_Nonbillable_Hours_Logged__c;
               mp.PSe_Total_Billable_Hours_Logged__c = pr[0].Appirio_PSAe__Total_Billable_Hours_Logged__c;
               mp.PSe_Billable_Hours_Remaining__c = pr[0].Appirio_PSAe__Billable_Hours_Remaining__c;
           } 
      } 
    } 
   

}