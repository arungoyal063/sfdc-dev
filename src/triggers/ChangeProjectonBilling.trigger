trigger ChangeProjectonBilling on Billing_Line_Item__c (after insert, after update) {
    
    // added code
        String projectID;
        boolean flag = false;
        list<Billing_Line_Item__c> billList = new list<Billing_Line_Item__c>();
        Appirio_PSAe__Proj__c projObj = new Appirio_PSAe__Proj__c();

        list<Appirio_PSAe__Proj__c> toUpdateProject = new list<Appirio_PSAe__Proj__c>();
        
        set<Id> accountIds = new Set<Id>();
        for(Billing_Line_Item__c billObj : Trigger.new){            
            projectID = billObj.Project__c;
        }
        projObj = [select Appirio_PSAe__Account__c,Appirio_PSAe__Billable_Hours_Remaining__c,Appirio_PSAe__Project_Stage__c from Appirio_PSAe__Proj__c where id =: projectID];
        System.debug('projObj....'+projObj);
        if(projObj != null)
        {
                accountIds.add(projObj.Appirio_PSAe__Account__c);
        }
         
     // added code 
        billList =  [select Hours__c,Invoice__c,Invoiced__c,Line_Item_Charge__c,Project__c,Timecard__c,Notes__c from Billing_Line_Item__c where Project__c =: projectID and Invoiced__c != 'Invoiced'];
        System.debug('billList......'+billList);
        if(billList.isEmpty())
        {
            flag = true;
            System.debug('flag.....'+flag);
         }  
        
        map<Id,Account> objAccounts = new map<Id,Account>([SELECT Name FROM Account WHERE Id IN: accountIds]);
        System.debug('objAccounts....'+objAccounts);
        
     if((objAccounts != null && !(objAccounts.get(projObj.Appirio_PSAe__Account__c).Name.containsIgnoreCase('rainmaker') || (objAccounts.get(projObj.Appirio_PSAe__Account__c).Name.containsIgnoreCase('Rainmaker')))))
     {
        System.debug('in if....');  
            if(projObj.Appirio_PSAe__Billable_Hours_Remaining__c <= 0 && flag)
             {
                        projObj.Appirio_PSAe__Project_Stage__c = 'Completed';
                        System.debug('......in else');
                        toUpdateProject.add(projObj);
             }
     }
     if(!toUpdateProject.isEmpty()){
            update toUpdateProject;
        }

}