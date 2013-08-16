trigger eventTrigger on Event (after insert,after update, after delete) {
        /*Variable Decliaration*/
        boolean IsAllDayEvent,isMeeting;
        String starttime,endtime,subject,conferencecallinfo,meetingtype,assignTO,GTMId,eventID;
        //Set of User Id's to populate token Map
        try{
            Set<Id> userIds = new Set<Id>();
            if (!trigger.isDelete) {
                for (Event event:trigger.new) {
                    if (!userIds.contains(event.OwnerId))
                        userIds.add(event.OwnerId);
                }
            }
            /*Map of GTM Tokens keyed on User*/
            Map<Id,GTMAccessToken__c> tokens = new Map<Id,GTMAccessToken__c>();
            List<GTMAccessToken__c> tokenTemp = new List<GTMAccessToken__c>();
            tokenTemp = [SELECT GTMAccessToken__c.Id,GTMAccessToken__c.User__c,GTMAccessToken__c.Expiry_Date__c
                         FROM GTMAccessToken__c
                         WHERE GTMAccessToken__c.User__c in: userIds];
            if (tokenTemp != null && !tokenTemp.isEmpty()) {
                for (GTMAccessToken__c gtmAT:tokenTemp) {
                    if (!tokens.containsKey(gtmAT.User__c)) {
                        tokens.put(gtmAT.User__c,gtmAT);
                    }
                }
            }
            if (!trigger.isDelete){ 
                for(Event event : trigger.new){
                    IsAllDayEvent = event.IsAllDayEvent;
                    starttime = String.valueOF(event.StartDateTime);
                    endtime = String.valueOF(event.EndDateTime);
                    subject = event.Subject;
                    conferencecallinfo = 'Free';
                    assignTO = event.Ownerid; 
                    isMeeting = event.Create_Goto_Meeting_Invite__c;
                    eventID = event.Id;
                    if(event.IsRecurrence)
                        meetingtype = 'Recurring';
                    else
                        meetingtype = 'Scheduled';
                }
                CreateMeetingInfo obj = new CreateMeetingInfo();
                obj.subject = subject + ' ConnectToMeeting';
                obj.starttime = Datetime.valueOf(starttime);
                obj.endtime = Datetime.valueOf(endtime);
                obj.conferencecallinfo = conferencecallinfo;
                obj.meetingtype = meetingtype;
                obj.passwordrequired = 'false';
                obj.timezonekey = '';
                String jsonStr = JSON.serialize(obj);
                /*Insert senario*/
                if(Trigger.isInsert && isMeeting){
                    /*Check to ensure the User Indicated on the event has a GTM Token*/
                    GTMAccessToken__c workingToken = tokens.get(assignTO);
                    if (workingToken == null){
                        if(!Test.isRunningTest()){
                            throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User selected is not set up with a GTM Token!<br></br> The selected user must complete GTM registration by going to the GTM Console',true));
                        }
                    }
                    else if (workingToken.Expiry_Date__c < Datetime.now())
                        throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User\'s GTM Token is expired <br></br> The selected user must complete GTM registration by going to the GTM Console',true));    
                    Event e = [SELECT Id, Description,Subject FROM Event where Id = :eventID LIMIT 1];          
                    GTMHelper.updateMeeting(jsonStr, eventID, assignTO);
                    try{
                        if(e != null){
                            if(e.description == null){
                                e.description = '';
                            }
                            if(e.Description.indexOf('||*') != -1 && e.Subject.indexOf('ConnectToMeeting') == -1){
                                String newSubject = e.Subject + ' ConnectToMeeting';
                                e.Subject = newSubject;
                                if(e != null) update e;
                            }   
                        } 
                    }catch(Exception ex){
                        throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('Unable to update Subject!'+ex,true));
                    }
               }
               /*Update senario*/ 
               if(Trigger.isUpdate){
                String oldDescription = Trigger.oldMap.get(eventID).description;
                String newDescription = Trigger.newMap.get(eventID).description;
                if(Trigger.newMap.get(eventID).description == null){
                    newDescription = '';
                }
                if(Trigger.oldMap.get(eventID).description == null){
                    oldDescription = '';
                }
                //GTMHelper.updateMeeting(jsonStr,eventID,assignTO);
                if(Trigger.oldMap.get(eventID).Create_Goto_Meeting_Invite__c == false && Trigger.newMap.get(eventID).Create_Goto_Meeting_Invite__c == true){
                    //Ensure that the selected user has a GTM Token and it's not expired
                    if(Trigger.newMap.get(eventID).EndDateTime <= datetime.now()){
                       trigger.new[0].addError('Meeting can not be created for the past, Please make sure meeting EndDate should be greater then today DateTime!');
                    }
                    // Updated on 23 may in order to ensure that start date and enddate should not be less than today's date prev check is only for enddate  
                     /*if(Trigger.newMap.get(eventID).StartDateTime < datetime.now() && Trigger.newMap.get(eventID).EndDateTime < datetime.now()){
                        trigger.new[0].addError('Meeting can not be created for the past, Please make sure meeting StartDate and  EndDate should be equal to today DateTime or future time!');
                     }*/
                    GTMAccessToken__c workingToken = tokens.get(assignTO);
                    if (workingToken == null){
                        if(!Test.isRunningTest()){
                           throw new GTMHelper.ApplicationException('The User selected is not set up with a GTM Token!The selected user must complete GTM registration by going to the GTM Console');
                        }
                    }
                    else if (workingToken.Expiry_Date__c < Datetime.now())
                        throw new GTMHelper.ApplicationException('The User\'s GTM Token is expired The selected user must complete GTM registration by going to the GTM Console');  //GTMHelper.CreateCustomTriggerMesssage('',true)'  
                    //GTMHelper.updateMeeting(jsonStr, eventID, assignTO);                  
                    Event e = [SELECT Id, Description,Subject,StartDateTime,IsRecurrence,EndDateTime,OwnerId FROM Event where Id = :eventID LIMIT 1];
                    if(e.description == null){
                        e.description = '';
                    }
                    /*To delete in case user removing description from the field*/
                    if(newDescription.indexOf('||*') == -1 && oldDescription.indexOf('||*') == -1){
                        GTMHelper.createMeeting(jsonStr,eventID,assignTO);      //String startDate, String endDate, String meetingType, String subject, String assignedTo
                    }
                    /*To delete in case user removing description from the field*/
                    if(newDescription.indexOf('||*') == -1 && oldDescription.indexOf('||*') != -1){
                        GTMHelper.EventDeleted_deleteMeeting(Trigger.oldMap.get(eventID).OwnerId,GTMHelper.getMeetingIdFromDescription(Trigger.oldMap.get(eventID).Description));
                    } 
                    }else if(Trigger.oldMap.get(eventID).Create_Goto_Meeting_Invite__c == true && Trigger.newMap.get(eventID).Create_Goto_Meeting_Invite__c == false) {
                   Event ev = [SELECT Id, Description,Subject FROM Event where Id IN :Trigger.newMap.keyset() LIMIT 1];
                   /*To remove substring having GTM details*/
                   if(ev.description == null){
                        ev.description = '';
                   }
                   if(ev.description.indexOf('||*') != -1 ){
                        ev.description = ev.description.replace(ev.description.substringBetween('||*','*||'),'').replace('||*','').replace('*||','');
                   }
                    GTMHelper.EventDeleted_deleteMeeting(Trigger.oldMap.get(eventID).OwnerId,GTMHelper.getMeetingIdFromDescription(Trigger.oldMap.get(eventID).Description));
                   try{
                        update ev;  
                   }catch(Exception ex){
                        throw ex; 
                   }
                }
                else if(Trigger.oldMap.get(eventID).Create_Goto_Meeting_Invite__c == true && Trigger.newMap.get(eventID).Create_Goto_Meeting_Invite__c == true && newDescription == oldDescription){
                    /*Ensure that the selected user has a GTM Token and it's not expired*/
                    GTMAccessToken__c workingToken = tokens.get(assignTO);
                    if (workingToken == null){
                        if(!test.isRunningTest()){
                            throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User selected is not set up with a GTM Token!<br></br> The selected user must complete GTM registration by going to the GTM Console',true));
                        }
                    }
                    else if (workingToken.Expiry_Date__c < Datetime.now())
                        throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User\'s GTM Token is expired <br></br> The selected user must complete GTM registration by going to the GTM Console',true));
                    GTMHelper.updateMeeting(jsonStr,eventID,assignTO);
                    if(newDescription.indexOf('||*') == -1 && oldDescription.indexOf('||*') == -1){
                        GTMHelper.createMeeting(jsonStr,eventID,assignTO);
                        Event e = [SELECT Id, Description,Create_Goto_Meeting_Invite__c,Subject  FROM Event where Id = :eventID LIMIT 1];                        
                        if((null != e.description)) {
                            if(e.description.indexOf('||*') == -1)
                            {
                                e.Create_Goto_Meeting_Invite__c = false;
                                if(e != null) update e;
                            }                           
                        }
                    }else{
                        GTMHelper.updateMeeting(jsonStr,eventID,assignTO);
                    }
                                    
                }
            }
        } 
        /*Delete senario*/
        if(trigger.isDelete) {
            
            Set<ID> ownerIds = new Set<ID>();
            Map<String, String> tokenDescMap = new Map<String, String>();
            
            for (Event e :trigger.old){
                ownerIds.add(e.OwnerId);    
            }
            
            if(!ownerIds.isEmpty()){
                Map<ID,GTMAccessToken__c> userIdAccessTokenMap = GTMHelper.getGTMAccessTokenMapById(ownerIds);
                for (Event e :trigger.old) {
                    if(userIdAccessTokenMap.containsKey(e.OwnerId)){
                        GTMAccessToken__c gat = userIdAccessTokenMap.get(e.OwnerId);
                        tokenDescMap.put(gat.AccessToken__c, GTMHelper.getMeetingIdFromDescription(e.Description));
                    }
                 } 
                 
                 GTMHelper.EventDeleted_BulkdeleteMeeting(tokenDescMap); 
            }
            
            /*for (Event e :trigger.old){
                GTMAccessToken__c gat = getGTMAccessTokenById(e.OwnerId);
                tokenDescMap.put(gat.AccessToken__c, GTMHelper.getMeetingIdFromDescription(e.Description));
               //GTMHelper.EventDeleted_deleteMeeting(e.OwnerId, GTMHelper.getMeetingIdFromDescription(e.Description));
               //eventIds.add(e.Id);  
            } 
            System.debug('eventIds....'+eventIds);
            
            */
        }
    }catch(Exception ex){
        /*To show thw message on the Standard page for delete*/
        if(trigger.isDelete){
            trigger.old[0].addError(ex.getMessage());
        }else{
            /*To show thw message on the Standard page for update/New*/
            trigger.new[0].addError(ex.getMessage());
        } 
    }
}