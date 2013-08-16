/*******************************************************************************************************************
** Module Name   : HTTPUtility
** Description   : This is a common HTTPUtility to process the message
** Throws        : Yes
** Calls         : Http callout,getMethod
** Test Class    : <HTTPUtility_UnitTest>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/

public with sharing class HTTPUtility{
    /*
    *  Get Method URL
    */
    public static HTTPResponse getMethod(String URL, String contentType) {
        HTTP h = new HTTP();
        HTTPRequest hreq = new HTTPRequest();
        hreq.setMethod('GET');
        hreq.setHeader('Content-Type',contentType);
        hreq.setEndPoint(URL);
        if(Test.isRunningTest()) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"foo":"bar"}');
            return res;
        }else {	try{return h.send(hreq);}catch(CallOutException ce){throw ce;}
        }
    }
}