global class GTMHelper{
    global static CreateMeetingInfoReturn objCreateMeetingInfoReturn {get;set;}
    @future(callout=true)
    public static void createMeeting(String cmJSON, String eventID, String assignedTo) {
        CreateMeetingInfo cm = (CreateMeetingInfo) JSON.deserialize(cmJSON, CreateMeetingInfo.class);
           try {
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: assignedTo LIMIT 1];
           //ToDo : GTM Access Token not found                         
               CreateMeetingInfoReturn cmr;
            if(Test.IsRunningTest()) {                                    
               cmr = new CreateMeetingInfoReturn();    
                   cmr.joinURL ='abcd';
           }
           else
           {
                cmr = GOTOMeetingConnect.createMeeting(gat.AccessToken__c,cm);       
           }
           objCreateMeetingInfoReturn = cmr;
                       
           Event e = [SELECT Id,description FROM Event where Id = :eventID LIMIT 1];
           if(e.description.indexOf('||*') == -1){
               e.Description = e.Description+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\nGoto Meeting Details:\nJoin URL:' + 
                               cmr.joinURL+ '\nMeeting id:' + cmr.meetingid + '\nConference Call Info: ' + cmr.conferenceCallInfo+'\n||~~~~~~~~~~~~~~~~~~~~~~*||\n';
               update e;
           }
                               
        } catch (QueryException ex) { }
    }
    
    
    @future(callout=true)
    public static void updateMeeting(String cmJSON, String eventID, String assignedTo) {
        CreateMeetingInfo cm = (CreateMeetingInfo) JSON.deserialize(cmJSON, CreateMeetingInfo.class);
        try {
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: assignedTo LIMIT 1];
           //ToDo : GTM Access Token not found
           Event e = [SELECT Id, Description FROM Event where Id = :eventID LIMIT 1];
            //Read the GTM details from the description //Update the GTM with the date time and subject //If the meeting is a recurring meeting, make it a Recurrent Event, 
            //If it is not a recurring meeting, update with the date time
           if(!Test.IsRunningTest()) {      
                GOTOMeetingConnect.updateMeeting(gat.AccessToken__c,cm, getMeetingIdFromDescription(e.Description) /*e.GTM_Meeting_ID__c*/);
           }
           
        } catch (QueryException ex) {  }
    }
    
    @future(callout=true)
    public static void deleteMeeting(String eventID, String assignedTo) {
        
        try {
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: assignedTo LIMIT 1];
           //ToDo : GTM Access Token not found
           Event e = [SELECT Id, description /*Go_To_Meeting_Info__c ,GTM_Meeting_ID__c*/ FROM Event where Id = :eventID LIMIT 1];
           if(!Test.IsRunningTest()) {      
            GOTOMeetingConnect.deleteMeeting(gat.AccessToken__c, getMeetingIdFromDescription(e.Description) /*e.GTM_Meeting_ID__c*/);
            upsert e;
           }           
        } catch (QueryException ex) { }
    }
    
    @future(callout=true)
    public static void EventDeleted_deleteMeeting(Id UserId, String GTMid) {
        try {
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: UserId LIMIT 1];
           if(!Test.IsRunningTest()) {                                    
                GOTOMeetingConnect.deleteMeeting(gat.AccessToken__c,GTMid);
           }
        } catch (QueryException ex) { }
    }
    
    /**
    *  Get the List of all the organizers and save to the custom table
    **/
    public static void getOrganizers() {
        try {
              GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: System.Userinfo.getUserId() LIMIT 1];
              //ToDo : GTM Access Token not found
              System.debug('gat.....' +gat);
              List<GTMOrganizerInfo> gList;
            if(Test.isRunningTest())
            {
                gList = new List<GTMOrganizerInfo>();
                GTMOrganizerInfo t1 = new GTMOrganizerInfo();
                t1.email='test@gmail.com';
                t1.firstName = 'sdfg';
                t1.groupId = 'sdgsdg';
                t1.groupName = 'dfh'; 
                t1.lastName ='dsgfsd';
                t1.organizerKey = 'sdgfsd';
                t1.status = 'asfas';
                gList.add(t1);
            }
            else
            {
               gList = GOTOMeetingConnect.getOrganizers(gat.AccessToken__c);
            }
            System.debug('gList.....' +gList);
            Map<String,GTMAccessToken__c> gatMap = new Map<String,GTMAccessToken__c>();
            List<String> emailList = new List<String>();
            for (GTMOrganizerInfo g:gList) {
                emailList.add(g.email);
                GTMAccessToken__c gat2 = new GTMAccessToken__c();
                gat2.Email__c = g.email;
                gat2.First_Name__c = g.firstName;
                gat2.Group_ID__c = g.groupId;
                gat2.Group_Name__c = g.groupName;
                gat2.Last_Name__c = g.lastName;
                gat2.Organizer_Key__c = g.organizerKey;
                gat2.Status__c = g.status;
                gatMap.put(g.email,gat2);
            }
            List<USER> uList = [SELECT id, email FROM USER where email in :emailList];
            List<GTMAccessToken__c> gatuList = [SELECT id, Email__c FROM GTMAccessToken__c where Email__c in :emailList];
            Map<String,String> emailMap = new Map<String,String>();
            for (USER u:uList) {
                GTMAccessToken__c gat1 = gatMap.get(u.email);
                gat1.User__c = u.id;
                gatMap.put(u.email,gat1);
            }
            for (GTMAccessToken__c g4:gatuList) {
                GTMAccessToken__c gat3 = gatMap.get(g4.email__c);
                gat3.id = g4.id;
                gatMap.put(g4.email__c,gat3);
            }
            upsert gatMap.values();
        } catch (QueryException ex) {  }
    }
    
    public static string CreateCustomTriggerMesssage(string s, Boolean alert)
    {
        string retval = '';
        retval += '<script>window.onload = function(){document.getElementById("errorDiv_ep").innerHTML = "</br></br>'+s+'</br></br>";};';
        if (alert)
        {
            string replacedBR = s.replace('<br>','');
            replacedBR = replacedBR.replace('</br>', '.');
            replacedBR = replacedBR.replace('\'', '\\\'');
            retval += 'alert(\''+replacedBR+'\');';
        }
        retval += '</script>';
        return retval;
    }
    
    webService static void deleteRemoteMeeting(String meetingId, String assignedTo){
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: assignedTo LIMIT 1];
           //ToDo : GTM Access Token not found //Event e = [SELECT Id, Go_To_Meeting_Info__c /*,GTM_Meeting_ID__c*/ FROM Event where Id = :eventID LIMIT 1];
           if(!Test.IsRunningTest()) {                                    
                GOTOMeetingConnect.deleteMeeting(gat.AccessToken__c,meetingId);
           }
    }
    
    webService static String createRemoteMeeting(String startDate, String endDate, String meetingType, String subject, String assignedTo) {
        
        string result = 'false';
        
        CreateMeetingInfo cm = new CreateMeetingInfo();
        cm.subject = subject;
        cm.meetingtype = meetingType;
        cm.passwordrequired = 'false';
        cm.starttime = DateTime.parse(startDate);
        cm.endtime = DateTime.parse(endDate);
        cm.conferencecallinfo = 'Free';
        cm.timezonekey = '';
                  
           try {
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: assignedTo LIMIT 1];
           //ToDo : GTM Access Token not found                         
               CreateMeetingInfoReturn cmr;
            if(Test.IsRunningTest()) {                                    
               cmr = new CreateMeetingInfoReturn();    
                   cmr.joinURL ='abcd';
           }
           else
           {
                cmr = GOTOMeetingConnect.createMeeting(gat.AccessToken__c,cm);       
           }
           return JSON.serialize(new MeetingDetails(cmr.joinURL,cmr.meetingid,cmr.conferenceCallInfo,'true','Success'));
           
        } catch (QueryException ex) { result = ex.getMessage(); }       
        return JSON.serialize(new MeetingDetails('false',result));
    }
    
    /*Meeting detail wrapper*/
    global class MeetingDetails{
        public String joinURL{get;set;}
        public String meetingId{get;set;}
        public String conferenceCallInfo{get;set;}
        public String isSuccess{get;set;}
        public String message{get;set;}
        
        global MeetingDetails(String joinURL,String meetingId,String conferenceCallInfo,String isSuccess,String message){
            this.joinURL = joinURL;
            this.meetingId = meetingId;
            this.conferenceCallInfo = conferenceCallInfo;
            this.isSuccess = isSuccess;
            this.message = message;
        }
        //In case Error
        global MeetingDetails(String isSuccess,String message){     
            this.isSuccess = isSuccess;
            this.message = message;
        }       
    }
    /*To get meeting id from the description*/
    public static String getMeetingIdFromDescription(String description){
        if(null != description && description.trim() != ''){
            String meetingId = description.substringBetween('Meeting id:','Conference');
            if(meetingId == null){
                meetingId = '';
            }
            return meetingId.trim();
        }
        return Null;
    }
    
    /* error reporting via mail */  
    webService static void errorReporting(String Body){
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String EmailAddresses = Label.Error_Reporting_Email_Address_Details;
            if(Label.Error_Reporting_Email_Address_Details != null && Label.Error_Reporting_Email_Address_Details.trim() != ''){                
                String[] toEmails = EmailAddresses.Split(',');
                mail.setToAddresses(toEmails);
                mail.setSubject('Error occure in the Org '+Userinfo.getOrganizationName());
                String orgDetail = 'Org Name/Org Id: '+Userinfo.getOrganizationName()+'/'+Userinfo.getOrganizationId()+'\n';
                mail.setPlainTextBody(orgDetail+Body);
                if(toEmails != null) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }catch(Exception ex){ throw ex; }
    }
    
    webService static String isUserHaveGTMAccount(String userId){
         list<GTMAccessToken__c> tokenTemp = [SELECT GTMAccessToken__c.Id,GTMAccessToken__c.User__c,GTMAccessToken__c.Expiry_Date__c FROM GTMAccessToken__c WHERE GTMAccessToken__c.User__c =: userId];
         if(!tokenTemp.isEmpty()){
            return 'true';
         }
         return 'false';
    }
    
    public class ApplicationException extends Exception{}
}

/*
           Event e = [SELECT Id, Go_To_Meeting_Info__c,GTM_Meeting_ID__c FROM Event where Id = :eventID LIMIT 1];
           e.Go_To_Meeting_Info__c = 'Goto Meeting Details:\nJoin URL:' + 
                            cmr.joinURL+ '\nMeeting id:' + cmr.meetingid + '\nConference Call Info: ' + cmr.conferenceCallInfo;
           e.GTM_Meeting_ID__c = cmr.meetingid;
           upsert e;         
           */
           
           //result = 'Goto Meeting Details:\nJoin URL:' + 
           //                 cmr.joinURL+ '\nMeeting id:' + cmr.meetingid + '\nConference Call Info: ' + cmr.conferenceCallInfo;
           
           
            //e.Go_To_Meeting_Info__c = '';
           //e.GTM_Meeting_ID__c = '';
           //upsert e;
        //} catch (QueryException ex) {
        
        //}
        
         /*
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__r.email='klanka@rainmaker-llc.com' and Expiry_Date__c = null LIMIT 1];
            */
            /*
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__r.email='klanka@rainmaker-llc.com' and Expiry_Date__c = null LIMIT 1];
        */
        //try {
           /*
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__r.email='klanka@rainmaker-llc.com' and Expiry_Date__c = null LIMIT 1];
           */
            /*
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__r.email='klanka@rainmaker-llc.com' and Expiry_Date__c = null LIMIT 1];
           */
           /*
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__r.email='klanka@rainmaker-llc.com' and Expiry_Date__c = null LIMIT 1];
           */
            /*Event e = [SELECT Id, Description FROM Event where Id = :eventID LIMIT 1];
           system.debug('--------------');
           if(e.Description.indexOf('||*') == -1){
                system.debug('<<<<<<<<'+e);
               e.Description = e.Description+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\nGoto Meeting Details:\nJoin URL:' + 
                               cmr.joinURL+ '\nMeeting id:' + cmr.meetingid + '\nConference Call Info: ' + 
                               cmr.conferenceCallInfo+'||~~~~~~~~~~~~~~~~~~~~~~*||\n';
               update e;           
           }*/
               /*
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__r.email='klanka@rainmaker-llc.com' and Expiry_Date__c = null LIMIT 1];
               */
                /*
           GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__r.email='klanka@rainmaker-llc.com' and Expiry_Date__c = null LIMIT 1];
               */