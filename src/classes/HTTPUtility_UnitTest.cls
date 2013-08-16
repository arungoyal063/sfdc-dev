/*******************************************************************************************************************
** Module Name   : HTTPUtility_UnitTest
** Description   : Test various methods used in HTTPUtility Apex Class by taking differnt input to test all possible condition
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
*********************************************************************************************************************/
@istest
private class HTTPUtility_UnitTest {
    Static TestMethod Void HTTPUtility_Test() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HTTPResponse response = HTTPUtility.getMethod('http://www.yahoo.com', 'application/json'); 
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                System.assertEquals(parser.getText(),'foo') ;
                break;
            }
        }
               
    }
}