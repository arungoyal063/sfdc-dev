trigger CopyFinancialSectionOnMPM on Appirio_PSAe__Proj__c (after insert, after update, after delete) {
Set<Id> OppIds = new Set<Id>();
List<Milestone1_Project__c> updateMPMProjList = new List<Milestone1_Project__c>();    
    if( Trigger.isUpdate || Trigger.isInsert ){
      for(Appirio_PSAe__Proj__c pr : Trigger.New){
           oppIds.add(pr.Appirio_PSAe__Opportunity__c); 
      }
      
      List<Milestone1_Project__c> pmpProj = [SELECT Id, Name, Opportunity__c, PSe_Total_Billable_Revenue_Invoiced__c, PSe_TotalBillableRevenue_Pending_Invoice__c, PSe_Total_Billable_Revenue_Logged__c,
                                              PSe_Pct_Complete_By_Revenue__c, PSe_Backlog_To_Deliver__c, PSe_Backlog_To_Invoice__c, PSe_Billing_Alert__c, PSe_Total_Billable_Hours_Invoiced__c,
                                              PSe_Total_Billable_Hours_Uninvoiced__c, PSe_Total_Nonbillable_Hours_Logged__c, PSe_Total_Billable_Hours_Logged__c, PSe_Billable_Hours_Remaining__c
                                              FROM Milestone1_Project__c WHERE Opportunity__c IN: oppIds];

      Map<Id,List<Milestone1_Project__c>> projMap = new Map<Id,List<Milestone1_Project__c>>();
      
      for(Id oppId : OppIds){
          List<Milestone1_Project__c> temp = new List<Milestone1_Project__c>();
          for(Milestone1_Project__c proj : pmpProj){
              if(proj.Opportunity__c == oppId)
                  temp.add(proj);
          }
          projMap.put(oppId,temp);
      }
      
      for(Appirio_PSAe__Proj__c pr : Trigger.New){
           List<Milestone1_Project__c> mp = projMap.get(pr.Appirio_PSAe__Opportunity__c);
           if(mp.size() > 0){
               system.debug('<<<Atulit>>>>' +mp[0].Id);
               mp[0].PSe_Total_Billable_Revenue_Invoiced__c = pr.Appirio_PSAe__Total_Billable_Revenue_Invoiced__c;
               mp[0].PSe_TotalBillableRevenue_Pending_Invoice__c = pr.Appirio_PSAe__Total_Billable_Revenue_Pending_Invoice__c;
               mp[0].PSe_Total_Billable_Revenue_Logged__c = pr.Appirio_PSAe__Total_Billable_Revenue_Logged__c;
               mp[0].PSe_Pct_Complete_By_Revenue__c = pr.Appirio_PSAe__Pct_Complete_By_Revenue__c;
               system.debug('<<<Atulit>>>>' +pr.Appirio_PSAe__Pct_Complete_By_Revenue__c);
               mp[0].PSe_Backlog_To_Deliver__c = pr.Appirio_PSAe__Backlog_In_Dollars__c;
               mp[0].PSe_Backlog_To_Invoice__c = pr.Appirio_PSAe__Backlog_To_Invoice__c;
               mp[0].PSe_Billing_Alert__c = pr.Appirio_PSAe__Billing_Alert__c;
               system.debug('<<<Atulit>>>>' +pr.Appirio_PSAe__Billing_Alert__c);
               mp[0].PSe_Total_Billable_Hours_Invoiced__c = pr.Appirio_PSAe__Total_Billable_Hours_Invoiced__c;
               mp[0].PSe_Total_Billable_Hours_Uninvoiced__c = pr.Appirio_PSAe__Total_Billable_Hours_Uninvoiced__c;
               mp[0].PSe_Total_Nonbillable_Hours_Logged__c = pr.Appirio_PSAe__Total_Nonbillable_Hours_Logged__c;
               mp[0].PSe_Total_Billable_Hours_Logged__c = pr.Appirio_PSAe__Total_Billable_Hours_Logged__c;
               mp[0].PSe_Billable_Hours_Remaining__c = pr.Appirio_PSAe__Billable_Hours_Remaining__c;
               updateMPMProjList.add(mp[0]); 
           }
           
      } 
    }   
    if(updateMPMProjList.size() > 0){
       update updateMPMProjList;
    }

}