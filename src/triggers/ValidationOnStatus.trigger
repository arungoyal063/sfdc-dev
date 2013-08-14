/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<ValidationOnStatus>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<22-11-2012>>
// Last Modified Date.....: <<22-11-2012>>
// Description/Requirement: <<1-Issue a warning when a case has a "closed" status, there is billable time, and an attempt is made to update the case to any "open" status when the previous billing month is closed. This would only be applicable when the account/product record indicates that bill time is being tracked
                             2-Issue warning when a case is closed with a 'Change Request Open' or 'Change Request Closed' status and there is billable time - this would only be applicable when the account/product record indicates that bill time is being tracked. 
                             3-Issue warning when a case is closed with a 'Change Request Open' or 'Change Request Closed' status and there is No Chnage Request associated with the Case. 
                             4-Insert case entitlement into case based on selected case product.>>
//---------------------------------------------------------------------------------------------------------------------------*/
trigger ValidationOnStatus on Case(before Update,after update,after insert) {
    boolean ignoreTriggers = false;
    if(!Test.isRunningTest()){
        ignoreTriggers= [select ignore_triggers__c from User where id = :UserInfo.getUserId()].ignore_triggers__c;
    }
if (ignoreTriggers==false)
{
if(trigger.isBefore && !Test.isRunningTest())
{   
       //   
      //SM change
     // get User Profile List to insert Case Comment on Priority Change by Ellucian Support Center Default Profile
     List<Profile> profileList = [SELECT p.Name, p.Id FROM Profile p WHERE Name='Ellucian Communities Profile' LIMIT 1];
    
    Map<ID,Integer> caseCRMap = new Map<ID,Integer>();
    AggregateResult[] groupedResults = [Select Originating_Case__c,Count(Name) CRCount from Change_Request__c WHERE Originating_Case__c IN: Trigger.newMap.keySet() Group By Originating_Case__c];
    
    for(AggregateResult ar :groupedResults) {
        caseCRMap.put((ID)ar.get('Originating_Case__c'),(Integer)ar.get('CRCount'));
    }
    
    groupedResults = [Select Case__c,Count(Name) CRCount from Associated_Case_Change_Request__c WHERE Case__c IN: Trigger.newMap.keySet() Group By Case__c];
    //For Issue #152 - Closed Case w/ CR's Validation
    for(Case caseObj:trigger.new){
        Case oldCaseObj = trigger.oldMap.get(caseObj.Id);
        if(oldCaseObj != null && caseObj.Status == 'Closed' && oldCaseObj.Status != caseObj.Status){
            for(AggregateResult a:groupedResults){
                if(a.get('Case__c') == caseObj.Id && a.get('CRCount')!=0){
                    caseObj.addError('Status should be either "Change Request Open" OR "Change Request Closed" because there are Associated Change Requests on this Case.');
                }
             }
        }   
    }
    for(AggregateResult ar :groupedResults) {
        if(caseCRMap.containskey((ID)ar.get('Case__c'))) {
            caseCRMap.put((ID)ar.get('Case__c'), caseCRMap.get((ID)ar.get('Case__c')) + (Integer)ar.get('CRCount'));
        } else {
            caseCRMap.put((ID)ar.get('Case__c'),(Integer)ar.get('CRCount'));
        }
    }
    
    Set<Id> productIds = new Set<Id>();    
    set<Id> accountIds = new set<Id>();
    for (Case c : Trigger.New) {
        accountIds.add(c.AccountId);
        
        if(c.ProductId != null) {
            productIds.add(c.ProductId);    
        }
    }
    
    Date nowDate = Date.today();
    Map<String,Map<String, String>> AccProEntlMap = new Map<String, Map<String, String>>();
    List<Entitlement> EntlmntList  = new List<Entitlement>();
    if((!productIds.isEmpty()) && (!accountIds.isEmpty())) {
        EntlmntList = [SELECT Id, Product_ID__c, AccountId FROM Entitlement WHERE Licensed_Product__c IN (SELECT Id FROM Licensed_Product__c WHERE Account__c IN :accountIds AND Product_New__c IN :productIds) AND StartDate <= :nowDate  AND EndDate >= :nowDate AND status='Active'];
    }
    
    for(Entitlement en :EntlmntList) {
        Map<String, String> tempMap;
        if(AccProEntlMap.containsKey(en.AccountId)) {
            tempMap = AccProEntlMap.get(en.AccountId); 
        } else {
            tempMap = new Map<String, String>();
        } 
        if(en.Product_ID__c != null) { 
            tempMap.put(en.Product_ID__c, en.Id); 
            AccProEntlMap.put(en.AccountId, tempMap);   
        }     
    }
    map<Id,Account> caseAccountMap = new map<Id,Account>([SELECT Name,Billable_Minutes__c FROM Account WHERE Id IN:accountIds]); 
    map<Id,Case> objCases = new map<Id,Case>([Select (Select Id, Change_Request__r.Date_Resolved__c, IsDeleted, Name, CurrencyIsoCode, Change_Request__c, Case__c, Relationship__c, Record_Type__c, CR_Full_Hierarchy__c, CR_Status__c, CR_Summary__c, CR_Found_In_Release__c, CR_Resolved_in_Release__c, CR_Priority__c From Associated_Records__r Order BY LastModifiedDate Limit 1 ) From Case where Id In: Trigger.newMap.KeySet()]);
    for (Case c : Trigger.New) {
        /*Added code for updating CR Closed Date */
        //List<Associated_Case_Change_Request__c> accr = [SELECT Id, Name, Change_Request__r.Date_Resolved__c FROM Associated_Case_Change_Request__c WHERE Case__c =: c.Id Order BY LastModifiedDate Limit 1];
        if(c.Status == 'Change Request Closed' && c.Sub_Status__c == 'Defect' && c.Change_Request_Closed_Date__c == null && objCases.get(c.Id).Associated_Records__r.size()>0){
            c.Change_Request_Closed_Date__c = objCases.get(c.Id).Associated_Records__r[0].Change_Request__r.Date_Resolved__c; 
        }
        /* Added code for 1nd requirement CM#71*/
        Boolean errorFlag = false;
        String timeElapsedMsg = 'You are not authorized to update or re-open this case due to the time elapsed since it was closed. Please open a new case for assistance with your issue.';
        
        if((c.Status != 'Change Request Closed') && (c.Total_Billable_Minutes__c > 0) && (Trigger.oldMap.get(c.Id).Status == 'Closed') && (c.Status !='Closed') && (c.ClosedDate != null)){                                                                // 
            if((dateTime.now().year() > c.ClosedDate.year()) || ((dateTime.now().year() == c.ClosedDate.year()) && (dateTime.now().month() > c.ClosedDate.month()))){
                System.debug('if condition');
                c.addError(timeElapsedMsg);
                errorFlag = true;
            }
        } else if((c.Status != 'Change Request Closed') && (Trigger.oldMap.get(c.Id).Status == 'Closed') && (c.Status !='Closed') && (c.ClosedDate != null)){  
            if(c.ClosedDate.date().daysBetween(Date.Today()) > 30) {
                 c.addError(timeElapsedMsg);
                 System.debug('Else if  condition &&&&& ');
                 system.debug(timeElapsedMsg);
                 errorFlag = true;
            }
        }
        
        if((c.Total_Billable_Minutes__c > 0) && (Trigger.oldMap.get(c.Id).Status == 'Change Request Closed') && (c.Status !='Change Request Closed') && (c.ClosedDate != null)){                                                                // 
            if((dateTime.now().year() > c.ClosedDate.year()) || ((dateTime.now().year() == c.ClosedDate.year()) && (dateTime.now().month() > c.ClosedDate.month()))){
                System.debug('if condition');
                c.addError(timeElapsedMsg);
                errorFlag = true;
            }
        } else if((Trigger.oldMap.get(c.Id).Status == 'Change Request Closed') && (c.Status !='Change Request Closed') && (c.ClosedDate != null)){  
            if(c.ClosedDate.date().daysBetween(Date.Today()) > 30) {
                 c.addError(timeElapsedMsg);
                 System.debug('Else if  condition &&&&& ');
                 system.debug(timeElapsedMsg);
                 errorFlag = true;
            }
        }  
        
        if((c.Total_Billable_Minutes__c > 0) && (Trigger.oldMap.get(c.Id).Status == 'Change Request Open') && (c.Status !='Change Request Closed') && (c.Status !='Change Request Open') && (c.ClosedDate != null)){                                                                // 
            if((dateTime.now().year() > c.ClosedDate.year()) || ((dateTime.now().year() == c.ClosedDate.year()) && (dateTime.now().month() > c.ClosedDate.month()))){
                System.debug('if condition');
                c.addError(timeElapsedMsg);
                errorFlag = true;
            }
        } else if((Trigger.oldMap.get(c.Id).Status == 'Change Request Open') && (c.Status !='Change Request Open') && (c.Status !='Change Request Closed')&& (c.ClosedDate != null)){  
            if(c.ClosedDate.date().daysBetween(Date.Today()) > 30) {
                 c.addError(timeElapsedMsg);
                 System.debug('Else if  condition &&&&& ');
                 system.debug(timeElapsedMsg);
                 errorFlag = true;
            }
        }           
                                                         
        /* Added code for 2nd requirement CM#73*/
        if((Trigger.oldMap.get(c.Id).Status == 'Change Request Open' || Trigger.oldMap.get(c.Id).Status == 'Change Request Closed') && c.Status == 'Closed' && caseAccountMap.get(c.AccountId).Billable_Minutes__c  > 0){
             c.addError('You are not authorise to Close this Case,Please contact your Administrator!');
             errorFlag = true;
        }
        /* Added code for 3rd requirement CM#72 */
        if((c.Status ==  'Change Request Open' || c.Status ==  'Change Request Closed') && (!caseCRMap.containsKey(c.Id)))  {
            
            //SM Change July 29
            if ((!profileList.isEmpty()) && UserInfo.getProfileId().equals(profileList.get(0).Id))
            {
                // Do nothing
                System.debug('This is a Community User- Do not execute code!');
            } else
            {
                c.addError( c.Status + ' Status : No Change Request Associated With the Case!');
                errorFlag = true;
            }           


        }
        
        // fill case entitlement
        if(!errorFlag) {
            if(c.AccountId != null && AccProEntlMap.containsKey(c.AccountId)) {
                 Map<String, String> tempMap = AccProEntlMap.get(c.AccountId);
                 
                 if(c.ProductId != null && tempMap != null && tempMap.containsKey(c.ProductId)) {
                     c.EntitlementId = tempMap.get(c.ProductId);
                 } else {
                     c.EntitlementId = null;    
                 }
            }  else {
                c.EntitlementId = null;
            }  
        } 
       
   }
   
}

if(Trigger.isAfter) {
    if(TriggerRunOnce.runOnce()) {
    
        Set<ID> ownerIds = new Set<ID>();
        Set<ID> MScaseIdSet = new Set<ID>(); // Case Id Set for Closed Cases
        
        // get User Profile List to insert Case Comment on Priority Change by Ellucian Support Center Default Profile
        List<Profile> profileList = [SELECT p.Name, p.Id FROM Profile p WHERE Name='Ellucian Communities Profile' LIMIT 1];
        
        //Comment List for case priority change
        List<CaseComment> prCommentList = new  List<CaseComment>(); 
        
        for(Case c : Trigger.New) {
            ownerIds.add(c.OwnerId); 
            
            // if case is closed that is previosuly not closed then complete its all milestone
            if(c.isClosed && Trigger.oldMap!= null && (!Trigger.oldMap.get(c.Id).isClosed)) {
                MScaseIdSet.add(c.Id);
            } 
        }
        Map<ID,User> ownerMap = new  Map<ID,User>([SELECT Id, Phone, TimeZoneSidKey, Region__c, Team__c,Manager.Name, Department from User where ID IN :ownerIds]);
        List<Case> caseList = [SELECT Id, LastModifiedDate, LastModifiedById, Last_Updated__c, Last_Updated_By__c,MileStone_Target_Date__c,OwnerId,Owner_Time_Zone__c, Owner_phone_number__c,Priority FROM Case WHERE Id IN :Trigger.newMap.keySet()];
        
        for(Case c :caseList) {
            ownerIds.add(c.OwnerId);
            c.Last_Updated_By__c = c.LastModifiedById;
            c.Last_Updated__c = c.LastModifiedDate;
            if(ownerMap.containsKey(c.OwnerId)) {
                /*Commented by as per David Suggestion on 12/07/2013 
                c.Owner_Time_Zone__c = ownerMap.get(c.OwnerId).TimeZoneSidKey;
                c.Owner_phone_number__c = ownerMap.get(c.OwnerId).Phone;
                c.Owner_Department__c = ownerMap.get(c.OwnerId).Department;
                c.Owner_Director__c = ownerMap.get(c.OwnerId).Manager.Name;
                c.Owner_Region__c = ownerMap.get(c.OwnerId).Region__c;
                c.Owner_Team__c = ownerMap.get(c.OwnerId).Team__c;*/
                
            } else {
                /*Commented by as per David Suggestion on 12/07/2013
                c.Owner_Time_Zone__c = '';
                c.Owner_phone_number__c = '';    
                c.Owner_Department__c = '';
                c.Owner_Director__c = '';
                c.Owner_Region__c = '';
                c.Owner_Team__c = '';*/
            }
            
            /*priority chnage works only in update case and for Ellucian Support Center Default Profile*/
            if ((!profileList.isEmpty()) &&
                   UserInfo.getProfileId().equals(profileList.get(0).Id) && 
                   Trigger.isUpdate &&
                   (Trigger.oldMap.get(c.Id).Priority != c.Priority)){
                    
                prCommentList.add(CaseModificationUtility.retPriorityComment(c.Id));        
            }
        }
        try {
            
            update caseList;
            
            // Complete Case Milestone for closed cases
            if(!MScaseIdSet.isEmpty()) {
                CaseModificationUtility.completeCaseMilestones(MScaseIdSet);
            }
            
            // insert Case Comment for priority change by community user
            if(!prCommentList.isEmpty()) { 
                insert prCommentList;
            }
        } catch(DMLException e) {
            Trigger.new[0].addError(e.getDMLMessage(0));    
        } catch(Exception e) {
            Trigger.new[0].addError(e.getMessage());
        }
        
        // update case milestone target date and completion date in future method
        UpdateCaseMileStone.updateMileStoneTargetDate(Trigger.NewMap.keySet());
    }
   
}
/* Added code for  requirement CR#40 UserStory 342*/
/* 
if(trigger.isAfter)
{   
 
    List<Id> caseIDList = new List<Id>();
     
    for (Case c : Trigger.New) {
        if(c.IsEscalated)
            caseIDList.add(c.Id);
        }
        
    System.debug('Trigger.oldMap.keyset()..'+Trigger.oldMap.keyset());
    List<Change_Request__c> crfetchList = [Select Originating_Case__c,Name,Is_Escalated__c from Change_Request__c WHERE  Originating_Case__c IN: caseIDList];
    for (Change_Request__c crList : crfetchList) {
        crList.Is_Escalated__c = true;
    //    boolean x = crList.Originating_Case__r.IsEscalated;
        }
        try
        {
            update crfetchList;
        }
         catch(Exception ex)
         {
            System.debug('Error on Updating Change request '+ex.getMessage());
         }
         
}
*/
    }


}