/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<createBillableTime>> 
// Version................: <<1.0>>
// Created by.............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<22-11-2012>>
// Last Modified Date.....: <<22-11-2012>>
// Description/Requirement: <<CM#14,CM#15,CM#87>>
//---------------------------------------------------------------------------------------------------------------------------*/
trigger CreateBillableTime on Task (after insert,after Update,after delete) {
 boolean ignoreTriggers = false;
 if(!Test.isRunningTest())
 	ignoreTriggers = [select ignore_triggers__c from User where Id = :UserInfo.getUserId()].ignore_triggers__c;

if (ignoreTriggers==false)
{  
    /*To populate a custom object (Billable Minutes) with data from an Activity record and keep the two records in sync in case the Activity record is modified or deleted.  */
    if(Trigger.isInsert) {
        list<String> ParentIds = new list<String>();
        list<Billable_Time__c> toInsertBillableTime = new list<Billable_Time__c>();
        list<Task> objTasksToUpdateBillTime = new list<Task>();
        for(Task task : Trigger.New) {
            ParentIds.add(task.WhatId);
        }
        map<Id,Case> caseList = new map<Id,Case>([SELECT Id,AccountId FROM Case WHERE Id IN: ParentIds]);
        /*To create Billable time record.*/
        for(Task task : Trigger.New) {
            Case objCase = caseList.get(task.WhatId);
            if(null != objCase && task.Billable_Minutes__c != NULL && task.Billable_Minutes__c != 0){
                Billable_Time__c objBillableTime = new Billable_Time__c();
                objBillableTime.Date_Work_Performed__c = task.ActivityDate;
                objBillableTime.Comments__c = task.Description;
                objBillableTime.Minutes__c = task.Billable_Minutes__c;
                objBillableTime.Case__c = objCase.Id;
                objBillableTime.Account__c = objCase.AccountId;
                objBillableTime.Task_ID__c = task.Id;
                objBillableTime.Type__c = 'Billable';
                toInsertBillableTime.add(objBillableTime);
            }
        }
        try{
        insert toInsertBillableTime;
        
        Map<Id,Task> taskMap = new Map<Id,Task>([Select Id,Billable_Time__c from Task where Id in :Trigger.newMap.keySet()]);
        /*To update Billable_Time__c field from created billable time into task*/
        for(Billable_Time__c bill: toInsertBillableTime) {
            Task ts = taskMap.get(bill.Task_ID__c); 
            ts.Billable_Time__c = String.ValueOf(bill.Id);
            objTasksToUpdateBillTime.add(ts);
        }
        update objTasksToUpdateBillTime;
        }Catch(exception e){trigger.new[0].Billable_Minutes__c.addError(e.getMessage().substringBetween(',',':'));}
    }
    
    /*On Update billable time with task fields (Billable_Minutes__c,ActivityDate,Description)*/
    if(Trigger.isUpdate) {
        list<String> billableTimes = new list<String>(); 
        list<Task> billtaskList = new list<Task>();
        list<Billable_Time__c> toUpdateBillableTime = new list<Billable_Time__c>();
        list<String> ParentIds = new list<String>();
        list<Task> objTasksToUpdateBillTime = new list<Task>();
        
        for(Task task : Trigger.New) {
            if(task.Billable_Time__c != null) {
                billableTimes.add(task.Billable_Time__c);
            } else if(task.Billable_Time__c == null && task.Billable_Minutes__c != NULL && task.Billable_Minutes__c != 0) {
                billtaskList.add(task);
                ParentIds.add(task.WhatId);
            }
        }
        map<Id,Billable_Time__c> billableTimeMap = new map<Id,Billable_Time__c>([select Id,Name from Billable_Time__c where Id IN: billableTimes]);     
        for(Task task : Trigger.New) {
            if(!billableTimeMap.isEmpty() && billableTimeMap.containsKey(task.Billable_Time__c)){  // task.Billable_Minutes__c != NULL && task.Billable_Minutes__c > 0 &&
                Billable_Time__c billObj = billableTimeMap.get(task.Billable_Time__c);
                billObj.Minutes__c = task.Billable_Minutes__c;
                billObj.Date_Work_Performed__c = task.ActivityDate;
                billObj.Comments__c = task.Description;
                toUpdateBillableTime.add(billObj);
            }
        }
        //update toUpdateBillableTime;
        
        // Added code for create new Billable time record when an activity is chnaged from non-billable to billable - blk1
        if(!billtaskList.isEmpty()) {
             map<Id,Case> caseList = new map<Id,Case>([SELECT Id,AccountId FROM Case WHERE Id IN: ParentIds]);
             for(Task task : billtaskList) {
                 Case objCase = caseList.get(task.WhatId);
                 if(objCase != null) {
                    Billable_Time__c objBillableTime = new Billable_Time__c();
                    objBillableTime.Date_Work_Performed__c = task.ActivityDate;
                    objBillableTime.Comments__c = task.Description;
                    objBillableTime.Minutes__c = task.Billable_Minutes__c;
                    objBillableTime.Case__c = objCase.Id;
                    objBillableTime.Account__c = objCase.AccountId;
                    objBillableTime.Task_ID__c = task.Id;
                    objBillableTime.Type__c = 'Billable';
                    toUpdateBillableTime.add(objBillableTime);
                 }
             }  
        }
        try{
        upsert toUpdateBillableTime;
        
        Map<Id,Task> taskMap = new Map<Id,Task>([Select Id,Billable_Time__c from Task where Id in :Trigger.newMap.keySet()]);
         /*To update Billable_Time__c field from created billable time into task*/
        for(Billable_Time__c bill :toUpdateBillableTime) {           
            Task ts = taskMap.get(bill.Task_ID__c);
            if(ts != null ) {
                if(ts.Billable_Time__c == null || ts.Billable_Time__c.trim().equals('')) {
                    ts.Billable_Time__c = String.ValueOf(bill.Id);
                    objTasksToUpdateBillTime.add(ts);
                }  
            }
        }
        update objTasksToUpdateBillTime;
        }Catch(exception e){trigger.new[0].Billable_Minutes__c.addError(e.getMessage().substringBetween(',',':'));}
        // Added code for create new Billable time record when an activity is chnaged from non-billable to billable - blk1
    } 
    
    /*To Delete billable times associated with task.*/
    if(Trigger.isDelete) {
        list<String> billableTimes = new list<String>(); 
        for(Task task : Trigger.Old) {
            billableTimes.add(task.Billable_Time__c);
        }
        List<Billable_Time__c>  objBillableTimeTOBeDelete = [select Id,Name from Billable_Time__c where Id IN: billableTimes];
        if(!objBillableTimeTOBeDelete.isEmpty()){
            try{
            delete objBillableTimeTOBeDelete;
            }Catch(exception e){trigger.new[0].addError(e.getMessage().substringBetween(',',':'));}
        }
    }
    
    /*** Update Parent Case Last Update Details ***/
    Set<String> caseIDSet = new Set<String>();
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            for(Task task :Trigger.new) {
                caseIDSet.add(task.WhatId); 
            }
        }
        
        if(Trigger.isUpdate || Trigger.isDelete) {
            for(Task task :Trigger.old) {
                caseIDSet.add(task.WhatId); 
            }   
        }
        
        String updateBy = UserInfo.getUserId();
        DateTime updateDate = DateTime.now();    
        Boolean updateFlag = CaseModificationUtility.updateCaseModificationActivity(caseIDSet, updateBy, updateDate);
        if(!updateFlag) {
            Trigger.New[0].addError('Error in Parent Case Updation');
        }
    }
    /*** Update Parent Case Last Update Details ***/

}
}