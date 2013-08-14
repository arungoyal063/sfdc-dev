/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<updateCaseStatus>> 
// Version................: <<1.0>>
// Created by.............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<13-06-2013>>
// Last Modified Date.....: <<13-06-2013>>
// Description/Requirement: <<>>
// AMC 06/27/2013 Add logic to not execute trigger if Ignore Triggers is checked
//---------------------------------------------------------------------------------------------------------------------------*/
trigger updateCaseStatus on Task (after insert, after update) {
boolean ignoreTriggers = [select ignore_triggers__c from User where Id = :UserInfo.getUserId()].ignore_triggers__c;

if (ignoreTriggers==false)
{    
      Set<String> caseIds = new Set<String>();
        
        for(Task ts: Trigger.New) {
            if(Trigger.isInsert && ts.WhatId != null) {
                if(ts.IsVisibleInSelfService && ts.Subject != null && !ts.Subject.contains('Has Been Received -'))//Has Been Logged -'))
                caseIds.add(ts.whatId);                
            }
            //check if the activity is changed to public
            if(Trigger.isUpdate) {
                Task tsOld = Trigger.oldMap.get(ts.Id);
                if(tsOld != null && tsOld.IsVisibleInSelfService != ts.IsVisibleInSelfService && ts.IsVisibleInSelfService) {
                    caseIds.add(ts.whatId);
                }                                
            }   
        }
        
        list<Case> caseStatusUpdate = [SELECT Id, Status, Sub_Status__c FROM Case WHERE Id IN :caseIds];        
        list<Case> tempCaseStatusUpdate = new list<Case>();
        //ts.IsVisibleInSelfService = true;
        for(Case cas:caseStatusUpdate){       
            //if(ts.IsVisibleInSelfService){
               cas.Status = 'Client Action Required';
               cas.Sub_Status__c = '';
               //cas.Completion_Date__c = system.now();  code has been moved to "Case_MilestoneComplete_OnEmail" trigger on LINE no 138
            //}
            
            tempCaseStatusUpdate.add(cas);
        }
        if(!tempCaseStatusUpdate.isEmpty()){
            try{
                update tempCaseStatusUpdate;
            }            
            catch(Exception e){
            
            }
        }
}
}