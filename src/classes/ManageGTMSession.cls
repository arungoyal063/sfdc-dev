/*******************************************************************************************************************
** Module Name   : ManageGTMSession
** Description   : This class manage GTM session by creating and updating token
** Throws        : Yes
** Calls         : Yes- Http callout,createToken,saveToken
** Test Class    : <ManageGTMSession_UnitTest>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/

public with sharing class ManageGTMSession{
    /*Create a Token*/     
    public PageReference createToken() {
        showSuccess = false;
        ErrorMessage = 'Error saving GTM Access Token! ';
        String code = ApexPages.currentPage().getParameters().get('code');
        System.debug(code);
        if (!(null == code || ''.equals(code))) {
            if(Test.IsRunningTest()) {  
                 String jsonResponse = '{"attributes":{"type":"GTMForce__GTMAccessToken__c"},"expires_in":"'+ Datetime.now() + '",'+
                                   '"access_token":"1235","account_key":"1234","account_type":"1234","email":"test@gmail.com",'+
                                   '"firstName":"test@gmail.com", "lastName":"test@gmail.com", "organizer_key":"test@gmail.com",'+
                                   '"refresh_token":"1234"}';
                 return saveToken(jsonResponse);                         
            }else{  
             	try{
             		if(GOTOMeetingConnect.objGTMOauthDetail != null){
		                HTTPResponse res = HTTPUtility.getMethod(GOTOMeetingConnect.objGTMOauthDetail.OAUTH_URL__c+code+GOTOMeetingConnect.objGTMOauthDetail.CLIENT_ID__c,'application/json');//'https://api.citrixonline.com/oauth/access_token?grant_type=authorization_code&code='+code+'&client_id=470bff5235932d0f1922c2cf3e4575b7','application/json');
		                return saveToken(res.getBody());
             		}else{
             			 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ConnectToMeeting authentication details do not exist, Please contact your Administrator!');
            			 ApexPages.addMessage(myMsg);
            			 return null;
             		}
             	}catch(CallOutException ce){
             		throw ce;
             	}
            }
        }
        return null;
    }
    /*
    	save Token in the GTMAccessToken__c object
    	@Argument: response 
    */
    public PageReference saveToken(string response){    
        try{
            //Expiration determines record saving
            Datetime expiration = datetime.now().addYears(1);
            //Split Response into a Map <String,String> of key and value pairs
            Map<String,String> responseArray = new Map<String,String>();
            if (response.length() > 0){
	            System.debug('Json Response ::'+ response);
	            string[] keysAndValues = response.split(',');
	            if (keysAndValues != null && !keysAndValues.isEmpty()){
                    //Now that each key and value pair are still together seperated by : Resplit and save
                    //key and value pairs to the map
                    for(String s:keysAndValues){
                            string[] rData = s.removeStart('{').removeEnd('}').split(':');
                            if (rData != null && rData.size() == 2)
                                    responseArray.put(rData[0].remove('"').trim(),rData[1].remove('"').trim());                                     
                    }
	            }
            }
            //Print responseArray values to the screen *Debug
            //Set up the expiration
            if (responseArray.get('expires_in') != null){
                    Integer seconds = Integer.valueOf(responseArray.get('expires_in'));
                    expiration = Datetime.now().addSeconds(seconds);
                    responseArray.remove('expires_in');
                    responseArray.put('expires_in',string.valueOf(expiration.format('M/d/y K:m a')));
            }
            else{
                    responseArray.put('expires_in',string.valueOf(expiration.format('M/d/y K:m a')));
            }
            //Get the Current User
            string currentUserId = System.Userinfo.getUserId();
            //Get the Current GTMAccess Token for logged in user if one exists, otherwise create a new one
            List<GTMAccessToken__c> existingToken = new List<GTMAccessToken__c>([
                    SELECT 
                    GTMAccessToken__c.Id,
                    GTMAccessToken__c.AccessToken__c,
                    GTMAccessToken__c.Account_Key__c,
                    GTMAccessToken__c.Account_Type__c,
                    GTMAccessToken__c.Email__c,
                    GTMAccessToken__c.Expiry_Date__c,
                    GTMAccessToken__c.First_Name__c,
                    GTMAccessToken__c.Last_Name__c,
                    GTMAccessToken__c.Organizer_Key__c,
                    GTMAccessToken__c.Refresh_Token__c,
                    GTMAccessToken__c.Status__c,
                    GTMAccessToken__c.User__c
                    FROM GTMAccessToken__c WHERE GTMAccessToken__c.User__c =: currentUserId
            ]);
            GTMAccessToken__c currentToken;
            if (existingToken != null && !existingToken.isEmpty()){
                    //Update Existing Values
                    currentToken = existingToken[0];                        
            }
            if (currentToken == null)
                    currentToken = new GTMAccessToken__c();
            //Save the Response to the GTMAccess Token
            if (responseArray.containsKey('access_token'))
                    currentToken.AccessToken__c = responseArray.get('access_token');
            if (responseArray.containsKey('account_key'))
                    currentToken.Account_Key__c = responseArray.get('account_key');
            if (responseArray.containsKey('account_type'))
                    currentToken.Account_Type__c = responseArray.get('account_type');
            if (responseArray.containsKey('email'))
                    currentToken.Email__c = responseArray.get('email');
            if (responseArray.containsKey('expires_in'))
                    currentToken.Expiry_Date__c = Datetime.parse(responseArray.get('expires_in'));
            if (responseArray.containsKey('firstName'))
                    currentToken.First_Name__c = responseArray.get('firstName');
            if (responseArray.containsKey('lastName'))
                    currentToken.Last_Name__c = responseArray.get('lastName');
            if (responseArray.containsKey('organizer_key'))
                    currentToken.Organizer_Key__c = responseArray.get('organizer_key');
            if (responseArray.containsKey('refresh_token'))
                    currentToken.Refresh_Token__c = responseArray.get('refresh_token');     
            if (currentToken.Status__c == null)
                    currentToken.Status__c = 'Active';
            if (currentToken.User__c == null)
                    currentToken.User__c = currentUserId;
            
            upsert(currentToken);
            showSuccess = true;
            //If success the redirect to the event page
            return new pageReference('/00U/e?retURL=%2Fhome%2Fhome.jsp');
        }
        catch (Exception ex){
                ErrorMessage += 'Exception: '+ex.getmessage();
        }               
        return null;
    }
    public Boolean showSuccess{get;set;}
    public string ErrorMessage{get;set;}
}