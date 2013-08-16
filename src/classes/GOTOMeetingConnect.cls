/*******************************************************************************************************************
** Module Name   : GOTOMeetingConnect
** Description   : Having callout details from the trigger and the side bar Home component.
** Throws        : Yes
** Calls         : Yes - createMeeting,getMyMeetings,getOrganizers,updateMeeting,deleteMeeting,buildURL
** Test Class    : <GOTOMeetingConnect_unitTest>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/

public with sharing class GOTOMeetingConnect{
	/*Callout actions methods*/
	private Static final String POST = 'POST';
    private Static final String GET = 'GET';
    private Static final String PUT = 'PUT';
    private Static final String DEL = 'DELETE';
	/*Get callout info from custom settings*/
	public static GTM_Oauth_Detail1__c objGTMOauthDetail{
		get{
			if(!GTM_Oauth_Detail1__c.getAll().values().isEmpty()){
				objGTMOauthDetail = GTM_Oauth_Detail1__c.getAll().values()[0];//to get callout details record 
			}
			return objGTMOauthDetail;
		}public set;
	}
	/*MEETINGS URL default setted if custome setting doesnot have the value*/
    public Static String MEETINGS_URL{
    	get{
    		if(objGTMOauthDetail.MEETINGS_URL__c == null && objGTMOauthDetail.MEETINGS_URL__c.trim() == ''){
    			MEETINGS_URL = 'https://api.citrixonline.com/G2M/rest/meetings';
    		}else{
    			MEETINGS_URL = objGTMOauthDetail.MEETINGS_URL__c;
    		}
    		return MEETINGS_URL;
    	}public set;
    }
    /*GROUP URL default setted if setting doesnot have the value*/
    public Static String GROUP_URL{
    	get{
    		if(objGTMOauthDetail.GROUP_URL__c == null && objGTMOauthDetail.GROUP_URL__c.trim() == ''){
    			GROUP_URL = 'https://api.citrixonline.com/G2M/rest/groups';
    		}else{
    			GROUP_URL = objGTMOauthDetail.GROUP_URL__c;
    		}
    		return GROUP_URL;
    	}public set;
    } 
    /*ORGANIZERS URL default setted if setting doesnot have the value*/ 
    public Static String ORGANIZERS_URL{
    	get{
    		if(objGTMOauthDetail.ORGANIZERS_URL__c == null && objGTMOauthDetail.ORGANIZERS_URL__c.trim() == ''){
    			ORGANIZERS_URL = '/organizers';
    		}else{
    			ORGANIZERS_URL = objGTMOauthDetail.ORGANIZERS_URL__c;
    		}
    		return ORGANIZERS_URL;
    	}public set;
    } 
    /*
    	To Create meeting
    	@Argument1: AccessToken
    	@Argument2: CreateMeetingInfo 
    */
    public static CreateMeetingInfoReturn createMeeting(String accessToken, CreateMeetingInfo cm) {
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        CreateMeetingInfoReturn cmr;
        try{
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
	        if(!Test.isRunningTest())
	        {
	        	if(resp.getStatusCode() == 400)
	        	{try{
	        		map<String,Object>  mapReturn = new map<String,Object>();	
		        	  mapReturn = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
		 	       	for (String keys : mapReturn.keySet()){
            				cmr = new CreateMeetingInfoReturn();
            				cmr.meetingid =  String.valueOf(mapReturn.get('msg'));
            				cmr.joinURL = 'Error';
        			}}catch(Exception ex){throw ex;}
	        	}
	        	else if(resp.getStatusCode() == 201)
	        	{try{List<Object>  ol = (List<Object>) JSON.deserializeUntyped(resp.getBody());
			        for (Object o : ol) {
			            cmr =  (CreateMeetingInfoReturn) JSON.deserialize(JSON.serialize(o),CreateMeetingInfoReturn.Class);
			        }
	        		}catch(Exception ex){throw ex;}}
	        }
	    }catch(Exception ex){
    		throw ex;
    	}
        return cmr;
    }
    /*
    	Get Organizers
    	@Argument1: accessToken
	*/
    public static List<GTMOrganizerInfo> getOrganizers(String accessToken){      
        //Get all the groups 
        List<GTMOrganizerInfo> gList = new List<GTMOrganizerInfo>();
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        try{
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
	                try{
		                List<Object> grespList = (List <Object>) JSON.deserializeUntyped(gres.getBody());
		                for (Object gresp : grespList) {
		                    GTMOrganizerInfo oi =  (GTMOrganizerInfo) JSON.deserialize(JSON.serialize(gresp),GTMOrganizerInfo.Class);
		                    System.debug(oi);
		                    gList.add(oi);
		                }
	                }catch(Exception ex){
		        		throw ex;
		        	}
	            }
	        } 
        }catch(Exception ex){
    		throw ex;
    	}
       return gList;
        
    }
    /*
    	To Update meeting
    	@Argument1: AccessToken
    	@Argument2: CreateMeetingInfo
    	@Argument3: meeting Id
    */
    public static void updateMeeting(String accessToken, CreateMeetingInfo cm,String meetingID) {
        try{
	        HTTP h = new HTTP();
	        HTTPRequest req = new HTTPRequest();
	        req.setHeader('Content-Type','application/json');
	        req.setHeader('Authorization','OAuth oauth_token=' + accessToken);
	        req.setMethod(PUT);
	        req.setEndPoint(MEETINGS_URL + '/' + meetingID);
	        req.setBody(JSON.serialize(cm));
	        if(!Test.IsRunningTest()) {
	        	try{
	        		HTTPResponse resp = h.send(req);
	        	}catch(CallOutException ce){throw ce; }
	        }
        }catch(Exception ex){
        	throw ex; 
        }
    }
    /*
    	To delete Meeting  
    	@Argument1: AccessToken
    	@Argument2: meeting Id
    */
    public static void deleteMeeting(String accessToken, String meetingID) {
        try{
	        HTTP h = new HTTP();
	        HTTPRequest req = new HTTPRequest();
	        req.setHeader('Content-Type','application/json');
	        req.setHeader('Authorization','OAuth oauth_token=' + accessToken);
	        req.setMethod(DEL);
	        req.setEndPoint(MEETINGS_URL + '/' + meetingID);
	        if(!Test.IsRunningTest()) {
	            try{
	            	HTTPResponse resp = h.send(req);
	            }catch(CallOutException ce){
	        		throw ce; 
	        	}
	       }
       }catch(Exception ex){
        	throw ex; 
        }
    }
    
    /* 
       Get the Meeting schedule
       @Argument1: AccessToken
    */
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
    /*
    	Create Url to callout
    	@Argument1: String Map	
	*/
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
    /*GTM group Info Wrapper*/
    public class GroupInfo{
        String groupkey;
        String parentKey;
        String groupName;
        String status;
        String numOrganizers;
    }
}