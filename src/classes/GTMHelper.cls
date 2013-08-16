/*******************************************************************************************************************
** Module Name   : GTMHelper
** Description   : Having callout details from the trigger and the side bar Home component.
** Throws        : Yes
** Calls         : Yes - createMeeting,updateMeeting,deleteMeeting,EventDeleted_deleteMeeting
** Test Class    : <GTMHelper_unitTest>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/

global class GTMHelper{
	/*To create Meeting On GTM server*/
    @future(callout=true)
    public static void createMeeting(String cmJSON, String eventID, String assignedTo) {
       CreateMeetingInfo cm = (CreateMeetingInfo) JSON.deserialize(cmJSON, CreateMeetingInfo.class);
       try { 
           GTMAccessToken__c gat = getGTMAccessTokenById(assignedTo);
           If(null != gat && cmJSON != null && eventID != null && assignedTo != null){                         
	            CreateMeetingInfoReturn cmr;
	            if(Test.IsRunningTest()) {                                    
	               cmr = new CreateMeetingInfoReturn();    
	               cmr.joinURL ='abcd';
	           }else{
	                cmr = GOTOMeetingConnect.createMeeting(gat.AccessToken__c,cm);       
	           }
	           Event e = [SELECT Id,description FROM Event where Id = :eventID LIMIT 1];
	           if(e != null){
		           if(e.description == null){
		           		e.description = '';	
		           }
		           if(e.description.indexOf('||*') == -1){
		               e.Description = e.Description+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\nGoto Meeting Details:\nJoin URL:' + 
		                               cmr.joinURL+ '\nMeeting id:' + cmr.meetingid + '\nConference Call Info: ' + cmr.conferenceCallInfo+
		                               '\n||~~~~~~~~~~~~~~~~~~~~~~*||\n';
		               update e;
		           }
	           }
           }                    
        } catch (QueryException ex) { throw ex; }
    }
    /*To update Meeting On GTM server*/
    @future(callout=true)
    public static void updateMeeting(String cmJSON, String eventID, String assignedTo) {
        CreateMeetingInfo cm = (CreateMeetingInfo) JSON.deserialize(cmJSON, CreateMeetingInfo.class);
        try {
           GTMAccessToken__c gat = getGTMAccessTokenById(assignedTo);
           If(gat != null && cmJSON != null && eventID != null && assignedTo != null){
	           Event e = [SELECT Id, Description FROM Event where Id = :eventID LIMIT 1];
	           if(!Test.IsRunningTest()) {      
	                GOTOMeetingConnect.updateMeeting(gat.AccessToken__c,cm, getMeetingIdFromDescription(e.Description));
	           }
	        }
        } catch (QueryException ex) { throw ex; }
    }
    /*To delete by event and assigned user Meeting On GTM server*/
    @future(callout=true)
    public static void deleteMeeting(String eventID, String assignedTo) {
        try {
           GTMAccessToken__c gat = getGTMAccessTokenById(assignedTo); 
           if(gat != null && eventID != null && assignedTo != null){
	           Event e = [SELECT Id, description FROM Event where Id = :eventID LIMIT 1];
	           if(!Test.IsRunningTest()) {      
	           		GOTOMeetingConnect.deleteMeeting(gat.AccessToken__c, getMeetingIdFromDescription(e.Description));
	            	upsert e;
	           }  
           }         
        } catch (QueryException ex) { throw ex; } 
    }
    /*To delete Meeting by meeting Id and UsrId On GTM server*/
    @future(callout=true)
    public static void EventDeleted_deleteMeeting(Id UserId, String GTMid) {
        try {
           GTMAccessToken__c gat = getGTMAccessTokenById(UserId);
           if(UserId != null && GTMid != null){
	           if(!Test.IsRunningTest()) {                                    
	                GOTOMeetingConnect.deleteMeeting(gat.AccessToken__c,GTMid);
	           }
           }
        } catch (QueryException ex) { throw ex; }
    }
    
     /*Bulk Delete Go to meeting events*/
    @future(callout=true) 
    public static void EventDeleted_BulkdeleteMeeting(Map<String, String> tokenDescMap) {  
        if(!tokenDescMap.isEmpty()) {
            try {
            	for(String token : tokenDescMap.keySet()) 
                	{
        	           if(!Test.IsRunningTest()) 
            	       {  
                    	    GOTOMeetingConnect.deleteMeeting(token, tokenDescMap.get(token));
	                   }
    	           }     
            } 
            catch (Exception ex) { //throw ex;
            		System.debug('Exception...'+ex.getMessage());
            	 }   
        }
    }
    
    /*Get Access token by userId*/ 
    private static GTMAccessToken__c  getGTMAccessTokenById(String userId){
    	list<GTMAccessToken__c> objGTMAccessToken = [SELECT id, AccessToken__c,User__c FROM GTMAccessToken__c WHERE User__c =:userId]; 
        If(!objGTMAccessToken.isEmpty()){
        	return objGTMAccessToken.get(0);
        }
        return new GTMAccessToken__c();
    }
    
    /*Get Access token by userId*/ 
    public static Map<ID,GTMAccessToken__c>  getGTMAccessTokenMapById(Set<ID> userIdList){
        Map<ID,GTMAccessToken__c> userIdAccessTokenMap = new Map<ID,GTMAccessToken__c>();
    	list<GTMAccessToken__c> objGTMAccessToken = [SELECT id, AccessToken__c,User__c FROM GTMAccessToken__c WHERE User__c IN :userIdList]; 
        If(!objGTMAccessToken.isEmpty()){
        	for(GTMAccessToken__c gtm :objGTMAccessToken){
        		userIdAccessTokenMap.put(gtm.User__c, gtm);	
        	}
        }
        return userIdAccessTokenMap;
    }
    /*Get the List of all the organizers and save to the custom table*/
    public static void getOrganizers() {
        try {
			GTMAccessToken__c gat = getGTMAccessTokenById(System.Userinfo.getUserId());
			if(gat!= null){
				List<GTMOrganizerInfo> gList;			
	            if(Test.isRunningTest()){
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
	            }else{
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
			}
        } catch (QueryException ex) { throw ex; }
    }
    /*Create Alert to callout from Trigger*/
    public static string CreateCustomTriggerMesssage(string s, Boolean alert){
        string retval = '';
        retval += '<script>window.onload = function(){document.getElementById("errorDiv_ep").innerHTML = "</br></br>'+s+'</br></br>";};';
        if (alert){
            string replacedBR = s.replace('<br>','');
            replacedBR = replacedBR.replace('</br>', '.');
            replacedBR = replacedBR.replace('\'', '\\\'');
            retval += 'alert(\''+replacedBR+'\');';
        }
        retval += '</script>';
        return retval;
    }
    /*To Delete meetong from GTM Server/Account*/
    webService static void deleteRemoteMeeting(String meetingId, String assignedTo){
    	try{
           GTMAccessToken__c gat = getGTMAccessTokenById(assignedTo);
           if(!Test.IsRunningTest() && gat != null && meetingId != null) {                                    
                GOTOMeetingConnect.deleteMeeting(gat.AccessToken__c,meetingId);
           }
    	}catch(CallOutException ce){
    		throw ce;
    	}catch(Exception ex){
    		throw ex;
    	}
    }
    
    /*Create Meeting by SOAP callout*/
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
           GTMAccessToken__c gat = getGTMAccessTokenById(assignedTo);
           if(null == gat && cm != null){
				return JSON.serialize(new MeetingDetails('false','User does not have a GTM Account,Please create new Account first.'));           	
           }
           CreateMeetingInfoReturn cmr;
           if(Test.IsRunningTest()) {                                    
               cmr = new CreateMeetingInfoReturn();    
               cmr.joinURL ='abcd';
           }
           else{
               cmr = GOTOMeetingConnect.createMeeting(gat.AccessToken__c,cm);       
             //  System.debug('cmr.....'+cmr);
           }
           return JSON.serialize(new MeetingDetails(cmr.joinURL,cmr.meetingid,cmr.conferenceCallInfo,'true','Success'));
           
        } catch (QueryException ex) { result = ex.getMessage(); }       
        return JSON.serialize(new MeetingDetails('false',result));
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
    /*To check wether user have GTM Account Or not*/
    webService static String isUserHaveGTMAccount(String userId){
         list<GTMAccessToken__c> tokenTemp = [SELECT GTMAccessToken__c.Id,GTMAccessToken__c.User__c,GTMAccessToken__c.Expiry_Date__c 
         									  FROM GTMAccessToken__c 
         									  WHERE GTMAccessToken__c.User__c =: userId];
         if(!tokenTemp.isEmpty()){
            return 'true';
         }
         return 'false';
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
    
    /*Extended Exception Handle*/
    public class ApplicationException extends Exception{}
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
        /*In case Error*/
        global MeetingDetails(String isSuccess,String message){     
            this.isSuccess = isSuccess;
            this.message = message;
        }       
    }
}