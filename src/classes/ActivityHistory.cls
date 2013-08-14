public class ActivityHistory {
    
    public list<Case> objCase {get;set;}
    public String activityHistoryId{get;set;}
    public boolean isSelfService{get;set;}
    
    public ActivityHistory(ApexPages.StandardController controller) {
        objCase  = [SELECT(SELECT Id, AccountId, WhoId, WhatId, Subject, IsTask, ActivityDate, OwnerId, Status, 
                           Priority, ActivityType, IsClosed, IsAllDayEvent, IsVisibleInSelfService, DurationInMinutes, 
                           Location, Description, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                           CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, 
                           X30_Min_Meeting_Outcome__c, Meeting_Notes__c, Products_of_Interest__c, Billable_Minutes__c, 
                           Billable_Time__c, Siebel_Row_ID__c, DB_Activity_Type__c FROM ActivityHistories) 
                   FROM Case c where id=:ApexPages.CurrentPage().getParameters().get('id')];
                   
    }   
    
    public PageReference logACall() {
        List<RecordType> taskRecordList = [SELECT Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName='Support' LIMIT 1];
        if(!taskRecordList.isEmpty() && !Test.isRunningTest()) {            
            PageReference page = new PageReference('/00T/e?title=Call&what_id='+ objCase.get(0).Id + '&followup=1&tsk5=Call&retURL='+ objCase.get(0).Id  +' &RecordType=' + taskRecordList.get(0).Id + '&ent=Task') ;
            page.setRedirect(true);
            return page;            
        }
        return null;
    } 
    /*make Public
    public pageReference makePublic(){
        list<Case> objCase = new list<Case>();
        objCase.addAll([SELECT (SELECT IsVisibleInSelfService FROM ActivityHistories WHERE id=:activityHistoryId) FROM Case WHERE id=:ApexPages.CurrentPage().getParameters().get('id')]);
        if(!objCase.isEmpty()){
            if(objCase.get(0).ActivityHistories.size() > 0){
                objCase.get(0).IsVisibleInSelfService = false;//isSelfService?false:true;
                update objCase;
            }
        }                
        return new pageReference('/apex/ActivityHistory?id='+objCase.get(0).Id);
    }*/
}