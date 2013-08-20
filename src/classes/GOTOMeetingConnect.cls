/**
*  author:  klanka@rainmaker-llc.com
*  Description:  Connect to GOTO Meeting in Salesforce and create a event
**/
public with sharing class GOTOMeetingConnect{
    

    Static String MEETINGS_URL = 'https://api.citrixonline.com/G2M/rest/meetings';
    Static String GROUP_URL = 'https://api.citrixonline.com/G2M/rest/groups';
    Static String ORGANIZERS_URL = '/organizers';
    Static String POST = 'POST';
    Static String GET = 'GET';
    Static String PUT = 'PUT';
    Static String DEL = 'DELETE';
    
    public static CreateMeetingInfoReturn createMeeting(String accessToken, CreateMeetingInfo cm) {
       
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','OAuth oauth_token=' + accessToken);
        req.setMethod(POST);
        req.setEndPoint(MEETINGS_URL);
        req.setBody(JSON.serialize(cm));
        HTTPResponse resp;
        if(Test.IsRunningTest()) {
            HttpResponse res = new HttpResponse();
            resp = res;  
        }
        else
        {
           resp = h.send(req);        
        }
        System.debug(resp.getBody());
        //TODO:  Exception, Error Handling
         CreateMeetingInfoReturn cmr;
	        if(!Test.isRunningTest()){
	        	List<Object>  ol = (List<Object>) JSON.deserializeUntyped(resp.getBody());
		        for (Object o : ol) {
		            cmr =  (CreateMeetingInfoReturn) JSON.deserialize(JSON.serialize(o),CreateMeetingInfoReturn.Class);
		            
		        }
	        }
        return cmr;
    }
    
    public static List<GTMOrganizerInfo> getOrganizers(String accessToken)
    {      
                           //Get all the groups 
                List<GTMOrganizerInfo> gList = new List<GTMOrganizerInfo>();
                HTTP h = new HTTP();
                HTTPRequest req = new HTTPRequest();
                req.setHeader('Content-Type','application/json');
                req.setHeader('Authorization','OAuth oauth_token=' + accessToken);
                req.setMethod(GET);
                req.setEndPoint(GROUP_URL);
                if(!Test.isRunningTest()){
	                HTTPResponse res = h.send(req);
	                String body = res.getBody();
	                List<Object> respList = (List <Object>) JSON.deserializeUntyped(body);
	                List <GroupInfo> giList = new List<GroupInfo>();
	                for (Object resp : respList) {
	                    GroupInfo gi =  (GroupInfo) JSON.deserialize(JSON.serialize(resp),GroupInfo.Class);
	                    System.debug(gi);
	                    giList.add(gi);
	                }
	                 //Get the organizers
	                for (GroupInfo g : giList) {
	                    req.setEndPoint(GROUP_URL + '/'+g.groupkey+ORGANIZERS_URL);
	                    HTTPResponse gres = h.send(req);
	                    String gbody = gres.getBody();
	                    List<Object> grespList = (List <Object>) JSON.deserializeUntyped(gbody);
	                    for (Object gresp : grespList) {
	                        GTMOrganizerInfo oi =  (GTMOrganizerInfo) JSON.deserialize(JSON.serialize(gresp),GTMOrganizerInfo.Class);
	                        System.debug(oi);
	                        gList.add(oi);
	                    }
	                }
                } 
       return gList;
        
    }
    
    public static void updateMeeting(String accessToken, CreateMeetingInfo cm,String meetingID) {
        System.debug(accessToken+'>>>>>>>>>>>>>>>>>>'+cm+'----------------'+meetingID);
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','OAuth oauth_token=' + accessToken);
        req.setMethod(PUT);
        req.setEndPoint(MEETINGS_URL + '/' + meetingID);
        req.setBody(JSON.serialize(cm));
        //TODO:  Exception, Error Handling
        if(!Test.IsRunningTest()) {
        	HTTPResponse resp = h.send(req);
        	System.debug('>>>>>>>>>>>>>>>>>>'+resp);
        }
    }
    
    public static void deleteMeeting(String accessToken, String meetingID) {
        
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','OAuth oauth_token=' + accessToken);
        req.setMethod(DEL);
        req.setEndPoint(MEETINGS_URL + '/' + meetingID);
      
        if(!Test.IsRunningTest()) {
            //TODO:  Exception, Error Handling
            HTTPResponse resp = h.send(req);
       }
    }
    
    /**
    *  Get the Meeting schedule
    *
    **/
    public static void getMyMeetings(String accessToken) {
        HTTPRequest req = new HTTPRequest();
        HTTP h = new HTTP();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','OAuth oauth_token=' + accessToken);
        req.setMethod(GET);
        Map<String,String> params = new Map<String,String>();
        params.put('scheduled','true');
        String url = buildURL(MEETINGS_URL,params);
        req.setEndpoint(url);
          if(!Test.IsRunningTest() == true) {
        HTTPResponse res = h.send(req);
        String body = res.getBody();
      
        List<Object> respList = (List <Object>) JSON.deserializeUntyped(body);
        for (Object resp : respList) {
            MeetingInfo mi =  (MeetingInfo) JSON.deserialize(JSON.serialize(resp),MeetingInfo.Class);
            System.debug(mi);
        }
        }
        
    }
    
	/**
    *  Get the Meeting schedule
    *
    **/
    public static MeetingInfo getMeetingById(String eventID,String assignedTo) {
        HTTPRequest req = new HTTPRequest();
        HTTP h = new HTTP();
        /*MeetingInfo mi1 = new MeetingInfo();
        GTMAccessToken__c gat = [SELECT id, AccessToken__c FROM GTMAccessToken__c 
                                    where User__c =: assignedTo LIMIT 1];
        Event e = [SELECT Id, Description,StartDateTime,EndDateTime FROM Event where Id = :eventID LIMIT 1];
        if(e.description == null){
        	e.description = '';
        }
        //String createdMeetingDetail = GTMHelper.createRemoteMeeting(null,null,null,null,null);
        //GTMHelper.MeetingDetails mdtl = (GTMHelper.MeetingDetails)JSON.deserialize(createdMeetingDetail,GTMHelper.MeetingDetails.class);
        if(e.Description.indexOf('||*') != -1 ){
	        req.setHeader('Content-Type','application/json');
	        req.setHeader('Authorization','OAuth oauth_token=' + gat.AccessToken__c);
	        req.setMethod(GET);
	        Map<String,String> params = new Map<String,String>();
	        params.put('scheduled','true');
	        String url = buildURL(MEETINGS_URL,params);
	        req.setEndpoint(url);
	      	if(!Test.IsRunningTest() == true) {
		        HTTPResponse res = h.send(req);
		        String body = res.getBody();	      
		        List<Object> respList = (List <Object>) JSON.deserializeUntyped(body);
		        system.debug('@@@@@@@@@@@@@@@@@@@'+respList);
		        for (Object resp : respList) {
		        	MeetingInfo mi =  (MeetingInfo) JSON.deserialize(JSON.serialize(resp),MeetingInfo.Class);
		        	//if(mi.meetingid == GTMHelper.getMeetingIdFromDescription(e.Description).trim()){ 
		        		mi1 = mi;
		        		break;
		        	//}
		        }
	        }
        }
        return mi1;*/
        return null;        
    }
    
    public static String buildURL(String url, Map<String,String> paramsMap) {
        String queryString = url;
        Set<String> paramKeys = paramsMap.keySet();
        Integer i = 0;
        for (String key:paramKeys) {
            if (i == 0) {
                queryString += '?';
                i++;
            } else {
                 queryString += '&';
            }
            queryString += key + '='+paramsMap.get(key);
        }
        return queryString;
        
    }
    
    public class GroupInfo
    {
        String groupkey;
        String parentKey;
        String groupName;
        String status;
        String numOrganizers;
        
    }
    

}