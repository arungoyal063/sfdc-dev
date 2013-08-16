/*******************************************************************************************************************
** Module Name   : MockHttpResponseGenerator
** Description   : Test HTTP callouts.
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
*********************************************************************************************************************/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method 
    global HTTPResponse respond(HTTPRequest req) {
        // set up response for HTTPUtility_UnitTest
        if (req.getEndpoint().equals('http://www.yahoo.com')){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"foo":"bar"}');
            res.setStatusCode(200);
            System.assertEquals(res.getStatusCode(), 200);
            return res;
        }
        if (req.getEndpoint().contains('https://api.citrixonline.com/oauth/access_token')){
            String jsonResponse = '{"attributes":{"type":"GTMForce__GTMAccessToken__c"},"expires_in":"'+ Datetime.now() + '",'+
                                   '"access_token":"1235","account_key":"1234","account_type":"1234","email":"test@gmail.com",'+
                                   '"firstName":"test@gmail.com", "lastName":"test@gmail.com", "organizer_key":"test@gmail.com",'+
                                   '"refresh_token":"1234"}';
          
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(jsonResponse);
            res.setStatusCode(200);
            System.assertEquals(res.getStatusCode(), 200);
            return res;
        }
        List<GOTOMeetingConnect.GroupInfo> gInfoList = new List<GOTOMeetingConnect.GroupInfo>();
        GOTOMeetingConnect.GroupInfo gInfoObj = new GOTOMeetingConnect.GroupInfo();
        gInfoList.add(gInfoObj);
        String gInfoJSON = JSON.serialize(gInfoList);
        System.debug('JSON Response ::' + gInfoJSON);
        // Create a fake response    
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(gInfoJSON);
        res.setStatusCode(200);
        System.assertEquals(res.getStatusCode(), 200);
        return res;
    }
   
}