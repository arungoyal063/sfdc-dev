trigger eventTrigger on Event (after insert,after update, after delete) {
        boolean IsAllDayEvent;
        String starttime;
        String endtime;
        String subject;
        String conferencecallinfo;
        String meetingtype;
        String assignTO;
        boolean isMeeting;
        String GTMId;
        String eventID;
        if (Trigger.isUpdate){
            Event oldEvent = Trigger.old[0];
            Event newEvent = Trigger.new[0];
            System.debug('oldEvent ---->' + oldEvent);
            System.debug('New Event --->' + newEvent);
        }
        //Set of User Id's to populate token Map
        Set<Id> userIds = new Set<Id>();
        if (!trigger.isDelete) {
            for (Event event:trigger.new) {
                if (!userIds.contains(event.OwnerId))
                    userIds.add(event.OwnerId);
            }
        }
        //Map of GTM Tokens keyed on User
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
	                //arun
	                //GTMId = event.GTM_Meeting_ID__c;
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
	            System.debug('----'+event.StartDateTime +'....jsonStr....'+jsonStr);
	            /*Insert senario*/
	            if(Trigger.isInsert && isMeeting){
	                //Check to ensure the User Indicated on the event has a GTM Token
	                GTMAccessToken__c workingToken = tokens.get(assignTO);
	                if (workingToken == null){
	            		//return pageReturn;
	            		if(!Test.isRunningTest()){
	              			throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User selected is not set up with a GTM Token!<br></br> The selected user must complete GTM registration by going to the GTM Console',true));
	            		}
	            	}
	                else if (workingToken.Expiry_Date__c < Datetime.now())
	                    throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User\'s GTM Token is expired <br></br> The selected user must complete GTM registration by going to the GTM Console',true));    
	                System.debug('on Insert');
	                //GTMHelper.createMeeting(jsonStr,eventID,assignTO);      
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
		                	}/*else{//(e.description.indexOf('||*') == -1){
			                	e.Create_Goto_Meeting_Invite__c = false;
			                }  */	
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
	           	
	            System.debug('..isMeeting....'+isMeeting);
	            //GTMHelper.updateMeeting(jsonStr,eventID,assignTO);
	            if(Trigger.oldMap.get(eventID).Create_Goto_Meeting_Invite__c == false && Trigger.newMap.get(eventID).Create_Goto_Meeting_Invite__c == true){
	                //Ensure that the selected user has a GTM Token and it's not expired
	                GTMAccessToken__c workingToken = tokens.get(assignTO);
	                if (workingToken == null){
	                	if(!Test.isRunningTest()){
	            		   throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User selected is not set up with a GTM Token!<br></br> The selected user must complete GTM registration by going to the GTM Console',true));
	                	}
	            	}
	                else if (workingToken.Expiry_Date__c < Datetime.now())
	                    throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User\'s GTM Token is expired <br></br> The selected user must complete GTM registration by going to the GTM Console',true));    
	                GTMHelper.updateMeeting(jsonStr, eventID, assignTO);
	                Event e = [SELECT Id, Description,Subject,StartDateTime,IsRecurrence,EndDateTime,OwnerId FROM Event where Id = :eventID LIMIT 1];
	                if(e.description == null){
	                	e.description = '';
	                }
	                /*To delete in case user removing description from the field*/
	                if(newDescription.indexOf('||*') == -1 && oldDescription.indexOf('||*') == -1){
	                	GTMHelper.createMeeting(jsonStr,eventID,assignTO);  	//String startDate, String endDate, String meetingType, String subject, String assignedTo
	                	/*system.debug('------------------'+GTMHelper.objCreateMeetingInfoReturn); 
	                	MeetingInfo mi = GOTOMeetingConnect.getMeetingById(eventID, assignTO);
			            if(mi != null){
				      		e.Description = e.Description+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\nGoto Meeting Details:\nJoin URL:' + 
				                       'https://www1.gotomeeting.com/join/'+mi.meetingid+ '\nMeeting id:' + mi.meetingid + '\nConference Call Info: ' + mi.conferenceCallInfo+'\n||~~~~~~~~~~~~~~~~~~~~~~*||\n';
				           	if(e != null) update e;
			            } */
	                }
	                /*To delete in case user removing description from the field*/
	                if(newDescription.indexOf('||*') == -1 && oldDescription.indexOf('||*') != -1){
	                	GTMHelper.EventDeleted_deleteMeeting(Trigger.oldMap.get(eventID).OwnerId,GTMHelper.getMeetingIdFromDescription(Trigger.oldMap.get(eventID).Description));
	                } 
	                /*if(e.description.indexOf('||*') == -1){
	                	e.Create_Goto_Meeting_Invite__c = false;
	                	if(e != null) update e;
	                }*/ 
	            }else if(Trigger.oldMap.get(eventID).Create_Goto_Meeting_Invite__c == true && Trigger.newMap.get(eventID).Create_Goto_Meeting_Invite__c == false) {
	               Event ev = [SELECT Id, Description,Subject FROM Event where Id IN :Trigger.newMap.keyset() LIMIT 1];
	               //To remove substring having GTM details
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
	                //Ensure that the selected user has a GTM Token and it's not expired
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
	                	Event e = [SELECT Id, Description,Subject FROM Event where Id = :eventID LIMIT 1];
		                if(e.description.indexOf('||*') == -1){
		                	e.Create_Goto_Meeting_Invite__c = false;
		                	if(e != null) update e;
		                }
	                }else{
	                	GTMHelper.updateMeeting(jsonStr,eventID,assignTO);
	                }
            }
       	}
    }
	/*Delete senario*/ 
	if(trigger.isDelete){
	    for (Event e:trigger.old){
			//system.debug(e.OwnerId+'))))))))'+ GTMHelper.getMeetingIdFromDescription(e.Description)); 
	        GTMHelper.EventDeleted_deleteMeeting(e.OwnerId, GTMHelper.getMeetingIdFromDescription(e.Description));
	    }
	}
}


/*if(Trigger.newMap.get(eventID).description.indexOf('||*') == -1){
		                MeetingInfo mi = GOTOMeetingConnect.getMeetingById(eventID, assignTO);
		                if(mi != null){
			        		e.Description = e.Description+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\nGoto Meeting Details:\nJoin URL:' + 
			                        'https://www1.gotomeeting.com/join/'+mi.meetingid+ '\nMeeting id:' + mi.meetingid + '\nConference Call Info: ' + mi.conferenceCallInfo+'||~~~~~~~~~~~~~~~~~~~~~~*||\n';
			            	if(e != null) update e;
		                }
	                }*/



/*if(e.description.indexOf('||*') == -1){ 
	            			MeetingInfo mi = GOTOMeetingConnect.getMeetingById(eventID, assignTO);
	            			e.Description = e.Description+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\nGoto Meeting Details:\nJoin URL:' + 
	                            'https://www1.gotomeeting.com/join/'+mi.meetingid+ '\nMeeting id:' + mi.meetingid + '\nConference Call Info: ' + mi.conferenceCallInfo+'||~~~~~~~~~~~~~~~~~~~~~~*||\n';
	                		if(e != null) update e;
	            		}
	            		//else{//(e.description.indexOf('||*') == -1){
		                	e.Create_Goto_Meeting_Invite__c = false;
		                //}*/
 /*else if(Trigger.oldMap.get(eventID).Create_Goto_Meeting_Invite__c == true && isMeeting == false)
            {
               Event ev = [SELECT Id, Description,Subject FROM Event where Id IN :Trigger.newMap.keyset() LIMIT 1];
               //To remove substring having GTM details
               if(ev.description.indexOf('||*') !=-1 ){
               		ev.description = ev.description.replace(ev.description.substringBetween('||*','*||'),'').replace('||*','').replace('*||','');
               }else{
               	    ev.Create_Goto_Meeting_Invite__c = false;
               }
               GTMHelper.deleteMeeting(eventID,Trigger.oldMap.get(eventID).OwnerId);
               try{
               		update ev;	
               }catch(Exception ex){
               		throw ex; 
               }
            }
            else if(Trigger.oldMap.get(eventID).Create_Goto_Meeting_Invite__c == true && isMeeting == true)
            {
                //Ensure that the selected user has a GTM Token and it's not expired
                GTMAccessToken__c workingToken = tokens.get(assignTO);
                if (workingToken == null)
                {
                	//return pageReturn;
                    throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User selected is not set up with a GTM Token!<br></br> The selected user must complete GTM registration by going to the GTM Console',true));
                }
                else if (workingToken.Expiry_Date__c < Datetime.now())
                    throw new GTMHelper.ApplicationException(GTMHelper.CreateCustomTriggerMesssage('The User\'s GTM Token is expired <br></br> The selected user must complete GTM registration by going to the GTM Console',true));
                if(Trigger.newMap.get(eventID).description.indexOf('||*') == -1){
                	GTMHelper.createMeeting(jsonStr,eventID,assignTO);
                	Event e = [SELECT Id, Description,Subject FROM Event where Id = :eventID LIMIT 1];
                	if(Trigger.newMap.get(eventID).description.indexOf('||*') == -1){
		                MeetingInfo mi = GOTOMeetingConnect.getMeetingById(eventID, assignTO);
		        		Trigger.newMap.get(eventID).Description = Trigger.newMap.get(eventID).Description+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\nGoto Meeting Details:\nJoin URL:' + 
		                        'https://www1.gotomeeting.com/join/'+mi.meetingid+ '\nMeeting id:' + mi.meetingid + '\nConference Call Info: ' + mi.conferenceCallInfo+'||~~~~~~~~~~~~~~~~~~~~~~*||\n';
		            	if(e != null) update e;
	                }
	                if(e.description.indexOf('||*') == -1){
	                	e.Create_Goto_Meeting_Invite__c = false;
	                	if(e != null) update e;
	                }
                }else{
                	GTMHelper.updateMeeting(jsonStr,eventID,assignTO);
                }
            }
           }*/