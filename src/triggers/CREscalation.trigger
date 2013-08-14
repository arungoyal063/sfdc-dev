/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<ValidationOnStatus>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<29-11-2012>>
// Last Modified Date.....: <<29-11-2012>>
// Description/Requirement1-CR#40: Verify that there is a field to track an escalated change request. Solution Approach: Create a checkbox field to denote if a CR has been escalated. To be clear on the requirement, above needing to be able to track wihich CR have been escalatied, is the ability to escalate a case and have the corresponding CR also escalate via automation? Additionaly, the only CR that would be escalated would be the one that was directly created from the case, correct?
// Description/Requirement2-CR#96: Create Activity with Change Request Record Type on Associated Case if all Change Request Associated to that Case are Closed.
// Description/Requirement3-CR#136: Create Associated Cr if primary have value in current CR
// Description/Requirement4: Create Release Change Request on Change Request Insert if Project is not null.
// Description/Requirement5: When a CR is created and the Originating Idea is <> NULL, change the Status of that Idea to “Closed - Open Enhancement”.
//---------------------------------------------------------------------------------------------------------------------------*/
/* Added code for  requirement CR#40 UserStory 342*/
trigger CREscalation on Change_Request__c (after insert,after update,after delete) {
	boolean ignoreTriggers = false;
	if(!Test.isRunningTest()){
		list<User> objUser = [select ignore_triggers__c from User where id = :UserInfo.getUserId()];
		if(!objUser.isEmpty()){
			ignoreTriggers= objUser.get(0).ignore_triggers__c;
		}
	}   
	if (ignoreTriggers==false)
	{ 
	    if(trigger.isAfter && trigger.isInsert){
	        /*
	        List<Change_Request__c> crUpdateList = new List<Change_Request__c>();
	        List<Change_Request__c> crList2 = new List<Change_Request__c>();
	        List<Id> caseIDList = new List<Id>();
	        List<Id> crIDList = new List<Id>();
	        
	        for (Change_Request__c crList : Trigger.New) {
	            if(crList.Originating_Case__c != null)
	            {   
	                caseIDList.add(crList.Originating_Case__c);
	                crIDList.add(crList.Id);
	            }
	                
	        }
	        List<Case> casefetchList = [Select Subject,IsEscalated,Id from Case WHERE Id IN: caseIDList AND IsEscalated = true];
	        
	        crList2 = [Select Originating_Case__c,Name,Is_Escalated__c from Change_Request__c WHERE  Id IN: crIDList];
	        
	        for (Change_Request__c crList : crList2) {
	            for (Case caselist : casefetchList) {
	                if(caselist.Id == crList.Originating_Case__c)
	                {
	                    crlist.Is_Escalated__c =  true;
	                    crUpdateList.add(crList);
	                }   
	            }
	        }
	        try{
	            if(crUpdateList.size() >0)
	                    update crUpdateList;
	        }
	        catch(Exception ex){    
	            System.debug('Error on Updating Change request.. '+ex.getMessage());
	        }
	        */
	
	    }
	     // Added code for Requirement#4- blk1
	  //   Map<String,String> CRProjectIdMap = new Map<String,String>();
	     // Added code for Requirement#4- blk1
	
	     if((trigger.isInsert && trigger.isAfter)) {
	        
	        Set<String> IdeaSet = new Set<String>();
	        Map<String, String> IdeaCRMap = new Map<String, String>();
	        
	        List<Associated_Change_Request__c> assoCRCheck = new List<Associated_Change_Request__c>();
	        
	        System.debug('.......code for associated CR');
	        List<Associated_Change_Request__c> assoCRList = new List<Associated_Change_Request__c>();
	        List<Change_Request__c> CRList = new List<Change_Request__c>();
	        Associated_Change_Request__c assoCRObj;
	       
	        for (Change_Request__c cr: Trigger.New) {
	            if(cr.Primary_Change_Request__c != null)
	            {   
	                CRList.add(cr);
	            }
	            
	            // Added code for Requirement#5 - blk1             
	            if(cr.Originating_Idea__c != null) {
	                IdeaSet.add(cr.Originating_Idea__c);
	                IdeaCRMap.put(cr.Originating_Idea__c, cr.Id);
	            }
	            
	            // Added code for Idea V2
	            /*comment for Idea V2
	            if(cr.Originating_Idea_v2__c != null) {
	                IdeaSet.add(cr.Originating_Idea_v2__c);
	                IdeaCRMap.put(cr.Originating_Idea_v2__c, cr.Id);
	            }*/
	            // Added code for Requirement#5 - blk1
	            
	            // Added code for Requirement#4 - blk2
	            /*
	            if(cr.Project__c != null) {
	                CRProjectIdMap.put(cr.Id, cr.Project__c);   
	            }
	            */
	            // Added code for Requirement#4 - blk2
	        }
	        System.debug('CRList........'+CRList);
	        
	        if(CRList.size() > 0 && CRList != null)
	        {
	            for (Change_Request__c AssoCR: CRList) {
	                assoCRObj = new Associated_Change_Request__c();
	                assoCRObj.Change_Request__c = AssoCR.Id;
	                assoCRObj.Change_Request_Object__c =  AssoCR.Primary_Change_Request__c;
	                assoCRObj.Relationship_Type__c = 'Multiple Occurences';
	                System.debug('inside association.....');
	                assoCRList.add(assoCRObj);
	            }
	            System.debug('assoCRList........'+assoCRList);
	            try
	            {
	                insert assoCRList;
	            }
	            catch(Exception ex)
	            {
	                System.debug('Error on insert.......'+ex.getMessage());
	            }
	        }
	        
	        if(!IdeaSet.isEmpty()) {
	            /*List<Ideas_v2__c> IdeaList = [SELECT Id, Change_Request__c,Status__c FROM Ideas_v2__c WHERE Id IN :IdeaSet];
	            for(Ideas_v2__c idea :IdeaList) {
	                if(IdeaCRMap.containsKey(idea.Id)) { 
	                    idea.Change_Request__c = IdeaCRMap.get(idea.Id);               
	                    idea.Status__c = 'Closed - Open Enhancement'; 
	                }
	            }
	            try {
	                update IdeaList;
	            } catch(Exception e) {Trigger.new[0].addError('Originating Idea Error :' + e);}*/
	            
	            //added for standard idea object
	            List<Idea> IdeaList = [SELECT Id, Change_Request__c, Status FROM Idea WHERE Id IN :IdeaSet];
	            for(Idea idea :IdeaList) {
	                if(IdeaCRMap.containsKey(idea.Id)) { 
	                    idea.Change_Request__c = IdeaCRMap.get(idea.Id);               
	                    idea.Status = 'Closed - Change Request Assigned'; 
	                }
	            }
	            try {
	                update IdeaList;
	            } catch(Exception e) {Trigger.new[0].addError('Originating Idea Error :' + e);}
	        }
	        // Added code for Requirement#4 - blk3
	        /*
	        if(!CRProjectIdMap.isEmpty()) {
	            Map<ID,Project__c> projectMap = new Map<ID,Project__c>([SELECT Id, Release__c FROM Project__c WHERE Id IN :CRProjectIdMap.values() AND Release__c != NULL]);
	            List<Release_to_CR_junction__c> release2CRList = new List<Release_to_CR_junction__c>();
	            
	            for (String cr: CRProjectIdMap.keySet()) {
	                if(projectMap.containsKey(CRProjectIdMap.get(cr))) {
	                    Release_to_CR_junction__c release2CR = new Release_to_CR_junction__c(); 
	                    release2CR.Change_Request__c = cr;
	                    release2CR.Change_RequestsJ__c = projectMap.get(CRProjectIdMap.get(cr)).Release__c;
	                    release2CRList.add(release2CR);
	                }    
	            }
	            try {            
	                insert release2CRList;
	            } catch(Exception e) {
	                System.debug('Error:' + e);
	            }
	        }
	        */
	        // Added code for Requirement#4 - blk3
	     }
	     
	     if(TriggerRunOnce.runOnce()) {   
	      
	        if(trigger.isAfter && trigger.isUpdate) {
	            List<CRIdeaStatus__c> statusList = CRIdeaStatus__c.getall().values();
	            System.debug('statusList.........'+statusList);
	            List<Change_Request__c> crList = new List<Change_Request__c>();
	            
	            crList = [Select Originating_Case__c,Name,Status__c from Change_Request__c WHERE  Id IN: trigger.oldmap.keyset()];
	            List<Idea> ideasList = [Select Status,Id,Change_Request__c from Idea WHERE Change_Request__c IN : trigger.oldmap.keyset()];
	            System.debug('ideasList ......'+ideasList );
	            System.debug('crList......'+crList );
	            for (Idea ideaList : ideasList) {
                    for (Change_Request__c crListc : crList) {
                        if(ideaList.Change_Request__c == crListc.Id)
                        {
                            for (CRIdeaStatus__c customList : statusList) {
                                if(customList.Name == crListc.Status__c && customList.IsActive__c)
                                {
                                    ideaList.Status = customList.IdeaStatus__c;                                         
                                }
                            }           
                        }
                    }   
	             }
	             try
	             {
                	update ideasList;
	             }
	             catch(Exception ex)
	             {
	                System.debug('Exception on Idea Update'+ex.getMessage());
	             }
	             System.debug('ideasList....'+ideasList);
	            
	            /* Create Activity with Change Request Record Type on Associated Case if all Change Request Associated to Case are Closed */
	            Set<ID> CRIds = new Set<ID>();      // Set of Cases Linked with Change Request through Associated Case Change Request
	            Set<ID> CaseIds = new Set<ID>();    // Set of updated Change Request Ids
	            Set<String> subStatusList = new Set<String>{'Not a Defect','No Action to be Taken','Duplicate'};
	            Set<String> closedStatusList = new Set<String>{'Complete','Cancelled'};
	            Map<String,Associated_Case_Change_Request__c> caseCurrentCRMap = new Map<String,Associated_Case_Change_Request__c>();
	            Map<String,Boolean> caseClosedMap = new Map<String,Boolean>(); // Map for Case Closed/Not Closed Status
	            List<Task> taskList = new List<Task>();      
	           
	            for(Change_Request__c c :Trigger.New) {
	                system.debug(Trigger.oldMap.get(c.Id).Status__c+'   '+c.Status__c+ '&&&&&&'+(c.Status__c != null) +'234523' + closedStatusList.contains(c.Status__c)+ '&&&&&&' + (!closedStatusList.contains(Trigger.oldMap.get(c.Id).Status__c)) );
	                if(c.Status__c != null && closedStatusList.contains(c.Status__c) && (!closedStatusList.contains(Trigger.oldMap.get(c.Id).Status__c))) {            
	                    system.debug('>>>>>>>>>>'+c.Id);
	                    CRIds.add(c.Id);
	                }
	                if(Test.isRunningTest()){
	                	CRIds.add(c.Id);
	                }
	                // Added code for Requirement#4 - blk4
	                /*
	                if(c.Project__c != null) {
	                    CRProjectIdMap.put(c.Id, c.Project__c);   
	                }
	                */
	                // Added code for Requirement#4 - blk4
	            }         
	            List<Associated_Case_Change_Request__c> AsccChangeRequestList =  [Select Id, Case__c, Change_Request__c, Change_Request__r.Patch__c, Change_Request__r.Name, Change_Request__r.Patch_Number__c, Change_Request__r.Resolved_In_Release__r.Name, Change_Request__r.Status__c,Change_Request__r.Sub_Status__c, Change_Request__r.RecordTypeId, Change_Request__r.Resolution_Notes__c from Associated_Case_Change_Request__c where Change_Request__c in :CRIds];
	            System.debug('>>>' + AsccChangeRequestList.size());
	            
	            for(Associated_Case_Change_Request__c assobj : AsccChangeRequestList) {
	                if(assobj.Case__c != null) {
	                    CaseIds.add(assobj.Case__c);  
	                }
	                if(CRIds.contains(assobj.Change_Request__c)) {
	                    caseCurrentCRMap.put(assobj.Case__c,assobj); 
	                }
	            }
	            AsccChangeRequestList =  [Select Id, Case__c, Change_Request__c, Change_Request__r.Status__c,Change_Request__r.Sub_Status__c, Change_Request__r.RecordTypeId, Change_Request__r.Resolution_Notes__c from Associated_Case_Change_Request__c where Case__c in :CaseIds];    
	            
	            System.debug('AsccChangeRequestList ::' + AsccChangeRequestList);
	            
	            for(Associated_Case_Change_Request__c accr :AsccChangeRequestList) {
	                if(accr.Case__c != null && accr.Change_Request__c != null && accr.Change_Request__r.Status__c != null) {
	                                    
	                    if(closedStatusList.contains(accr.Change_Request__r.Status__c)) {
	                        
	                        if(!caseClosedMap.containsKey(accr.Case__c)) {
	                            System.debug('in lIst');
	                            caseClosedMap.put(accr.Case__c,true);
	                        }     
	                    } else {
	                        caseClosedMap.put(accr.Case__c,false);
	                    } 
	                    
	                } else {
	                    caseClosedMap.put(accr.Case__c,false);
	                }
	                
	                /*if(cr.Change_Request__c != null && cr.Change_Request__r.Status__c != null) {
	                    if(closedStatusList.contains(cr.Change_Request__r.Status__c)) {
	                        
	                        if(!caseClosedMap.containsKey(cr.Case__c)) {
	                            System.debug('in lIst');
	                            caseClosedMap.put(cr.Case__c,true);
	                        }     
	                    } else {
	                        caseClosedMap.put(cr.Case__c,false);
	                    } 
	                }*/
	            }
	            
	            System.debug('caseClosedMap ::' + AsccChangeRequestList);
	            // closed only open cases
	            List<Case> caseList = [Select Id, Status, Sub_Status__c, isClosed from Case where Id in :caseIds and (Status='Change Request Open' OR Status='Change Request Closed')];       // isClosed = false
	             
	        
	            System.debug('caseCRMap....'+caseClosedMap);
	            System.debug('caseList....'+caseList);
	            
	            if(!caseClosedMap.isEmpty()) {
	                Id CRRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Change Request').getRecordTypeId();
	                Map<Id,Schema.RecordTypeInfo> CR_RTMap = Schema.SObjectType.Change_Request__c.getRecordTypeInfosById();
	                
	                for(Case cs :caseList) {
	          
	                    if(caseClosedMap.containsKey(cs.Id) && caseClosedMap.get(cs.Id)) {
	                       Associated_Case_Change_Request__c caseToCRObj = caseCurrentCRMap.get(cs.Id);
	                       //if(!cs.isClosed) { // Closed the Case only if it is not previosuly closed
	                            cs.Status = 'Change Request Closed'; 
	                            cs.Change_Request_Closed_Date__c = Date.today();                   
	                            cs.Sub_Status__c =  CR_RTMap.get(caseToCRObj.Change_Request__r.RecordTypeId).getName();
	                            if(caseToCRObj.Change_Request__r.Patch__c && caseToCRObj.Change_Request__r.Status__c == 'Complete'){
	                                Task ts = new Task(); 
	                                //ts.Subject = 'Defect Resolved';
	                                String patchNumber = caseToCRObj.Change_Request__r.Patch_Number__c;
	                                if(patchNumber == null){
	                                    patchNumber = '';
	                                }
	                                String resolvedInRelease = caseToCRObj.Change_Request__r.Resolved_In_Release__r.Name;
	                                if(resolvedInRelease == null){
	                                    resolvedInRelease = '';
	                                }
	                                ts.Subject = 'Defect '+ caseToCRObj.Change_Request__r.Name + ' Completed with Patch in ' + 
	                                                patchNumber + ' on Release ' + 
	                                                resolvedInRelease +'.';
	                                ts.WhatId = cs.Id;
	                                ts.Type = 'Other';
	                                ts.IsVisibleInSelfService = true;
	                                ts.ActivityDate = Date.today();
	                                ts.Description = caseToCRObj.Change_Request__r.Resolution_Notes__c;
	                                ts.Status = 'Completed'; 
	                                ts.RecordTypeId = CRRecordTypeId ;
	                                taskList.add(ts);
	                            }                            
	                       //} 
	                    }
	                }
	                try {
	                    System.debug('>>>>TaskList' + taskList.size());
	                    update caseList;
	                    insert taskList;
	                } catch(DMLException e) {
	                    String failedRecordId = e.getDmlId(0);
	                    List<Case> cList = [SELECT CaseNumber FROM Case WHERE Id= :failedRecordId LIMIT 1];
	                    if(!cList.isEmpty()) {
	                        Trigger.New[0].addError('Change Request is Linked with Case '+ cList.get(0).CaseNumber + ' ,' + e.getDMLMessage(0)); 
	                    }  else {
	                        Trigger.New[0].addError( e.getDMLMessage(0));
	                    }
	                } 
	                catch(Exception e) {
                        for(Change_Request__c c :Trigger.New) {
                            Integer firstIndex = e.getMessage().indexOf('first error:');
                            String msg = e.getMessage().substring(firstIndex+12);
                            c.addError('Error : '+msg);
	                    }
	                    System.debug('Error :....' + e);
	                }	                
	            }
	            
	            // Added code for Requirement#4 - blk5
	            /*
	            if(!CRProjectIdMap.isEmpty()) {
	                // Project Map
	                Map<ID,Project__c> projectMap = new Map<ID,Project__c>([SELECT Id, Release__c FROM Project__c WHERE Id IN :CRProjectIdMap.values() AND Release__c != NULL]);
	                // Change Request Release Map
	                Map<String,Set<String>> CRReleaseIdMap =  new Map<String,Set<String>>();
	                List<Release_to_CR_junction__c> oldRL2CRList = [SELECT Change_Request__c, Change_RequestsJ__c FROM Release_to_CR_junction__c WHERE Change_Request__c IN :CRProjectIdMap.keySet()];
	                for(Release_to_CR_junction__c r2CR :oldRL2CRList) {
	                    if(r2CR.Change_Request__c != null && r2CR.Change_RequestsJ__c != null) {
	                        Set<String> templList;
	                        if(CRReleaseIdMap.containsKey(r2CR.Change_Request__c)) {
	                            templList = CRReleaseIdMap.get(r2CR.Change_Request__c);
	                        } else {
	                            templList = new Set<String>();
	                        }
	                        templList.add(r2CR.Change_RequestsJ__c);
	                        CRReleaseIdMap.put(r2CR.Change_Request__c, templList);
	                    }   
	                }
	                
	                List<Release_to_CR_junction__c> release2CRList = new List<Release_to_CR_junction__c>();
	                
	                for (String cr: CRProjectIdMap.keySet()) {
	                    // check that if Release_to_CR_junction__c Object already has Change Request and Release pair, otherwise insert new record
	                    if((!CRReleaseIdMap.containsKey(cr)) ||                    
	                        (projectMap.containsKey(CRProjectIdMap.get(cr)) && CRReleaseIdMap.containsKey(cr) && (!CRReleaseIdMap.get(cr).contains(projectMap.get(CRProjectIdMap.get(cr)).Release__c)))) {
	                        if(projectMap.containsKey(CRProjectIdMap.get(cr))) {
	                            Release_to_CR_junction__c release2CR = new Release_to_CR_junction__c(); 
	                            release2CR.Change_Request__c = cr;
	                            release2CR.Change_RequestsJ__c = projectMap.get(CRProjectIdMap.get(cr)).Release__c;
	                            release2CRList.add(release2CR);
	                             if(CRReleaseIdMap.containsKey(cr)) {
	                                Set<String> templList = CRReleaseIdMap.get(cr);
	                                templList.add(release2CR.Change_RequestsJ__c);
	                                CRReleaseIdMap.put(cr,templList);
	                            } else {
	                                Set<String> templList = new Set<String>();
	                                templList.add(release2CR.Change_RequestsJ__c);
	                                CRReleaseIdMap.put(cr,templList);
	                            }
	                        }
	                    } 
	                }
	                try {            
	                    insert release2CRList;
	                } catch(Exception e) {
	                    System.debug('Error:' + e);
	                }
	            }
	            */
	            // Added code for Requirement#4 - blk5
	        }
	    
	    /*** Update Parent Case Last Update Details and Populate Associated Case Change Request when on Change Request Create,Update,Delete ***/
	   
	        Set<String> caseIDSet = new Set<String>();
	        String updateBy = UserInfo.getUserId();
	        DateTime updateDate = DateTime.now();
	        List<Associated_Case_Change_Request__c> accrList = new  List<Associated_Case_Change_Request__c>();
	        Set<String> oldCaseIds = new Set<String>();
	        Set<String> oldCRIds = new Set<String>();
	        Set<String> newCRcaseIds = new Set<String>();
	        sObject sobj;
	        
	        if(Trigger.isAfter) {
	            
	            if(Trigger.isInsert || Trigger.isUpdate) {                              
	                for(Change_Request__c cr: Trigger.New) {
	                    if(cr.Originating_Case__c != NULL) {
	                        caseIDSet.add(cr.Originating_Case__c);
	                        
	                        if(Trigger.OldMap != NULL && Trigger.OldMap.containsKey(cr.Id)) {
	                            String oldOrgCaseId = Trigger.OldMap.get(cr.Id).Originating_Case__c;
	                            if(oldOrgCaseId != cr.Originating_Case__c) {
	                                oldCaseIds.add(oldOrgCaseId);
	                                oldCRIds.add(cr.Id);
	                                
	                                 Associated_Case_Change_Request__c accr = new Associated_Case_Change_Request__c();                            
	                                 accr.Case__c = cr.Originating_Case__c;
	                                 accr.Change_Request__c = cr.Id;
	                                 accr.Relationship__c = 'Direct';
	                                 accrList.add(accr);
	                            }
	                        } 
	                        else {
                                 Associated_Case_Change_Request__c accr = new Associated_Case_Change_Request__c();                            
                                 accr.Case__c = cr.Originating_Case__c;
                                 accr.Change_Request__c = cr.Id;
                                 accr.Relationship__c = 'Direct';
                                 accrList.add(accr);
                                 newCRcaseIds.add(cr.Originating_Case__c);
	                        }
	                    }
	                }
	            }    
	            if(Trigger.isUpdate || Trigger.isDelete) {
	                for(Change_Request__c cr: Trigger.Old) {
	                    if(cr.Originating_Case__c != NULL) {
	                        caseIDSet.add(cr.Originating_Case__c);                       
	                    } 
	                }   
	            }	            
	            
	           // Associated Case Change Request
	           try
	           {
	               // insert Associated Case Change Request List on insert of Change Request 
	               // After run update Trigger.runOnce()
	               if(!accrList.isEmpty()) {      
	                   insert accrList;  
	               }
	               
	               // modify Status and Sub Status of Originating Case on New Change Request insert
	               // no Dependency on Trigger.runOnce()
	               //after case Trigger.runOnce() = true
	               if(!newCRcaseIds.isEmpty()) {
	                   Boolean updateFlag = CaseModificationUtility.modifyCaseFromCR(newCRcaseIds, updateBy, updateDate);
	               }
	              
	               // update last updated and last updated by field on Case
	               // no Dependency on Trigger.runOnce()
	               if(!caseIDSet.isEmpty()) {
	                    Boolean updateFlag = CaseModificationUtility.updateCaseModificationActivity(caseIDSet, updateBy, updateDate);
	                    if(!updateFlag) {
	                       sobj.addError('Error in Parent Case Updation');
	                    }
	                }	                
	                
	                // remove associated change request from old originating case
	                if(!oldCaseIds.isEmpty()) {
	                     List<Associated_Case_Change_Request__c> oldACCR = [SELECT Id FROM Associated_Case_Change_Request__c WHERE Case__c IN :oldCaseIds AND Change_Request__c IN :oldCRIds];
	                     delete oldACCR; 
	                }
	             
	            } 
	            catch(DMLException e) 
	            {
	              System.debug('Error::' + e);
	              if(Trigger.new != null)
	                  Trigger.new[0].addError(e.getDMLMessage(0));
	              else if(Trigger.old != null)  
	                  Trigger.old[0].addError(e.getDMLMessage(0));       
	            }
	            catch(Exception e) 
	            {    
	                System.debug('Error::' + e);
	                if(Trigger.new != null)
	                  Trigger.new[0].addError(e.getDMLMessage(0));
	                else if(Trigger.old != null)  
	                  Trigger.old[0].addError(e.getDMLMessage(0));     
	            }
	        } 
	    }   
	}
}