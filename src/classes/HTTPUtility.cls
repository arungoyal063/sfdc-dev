/**
*  This is a common HTTPUtility to process the message
*  @author:  klanka@rainmaker-llc.com
**/
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
        } else {
            return h.send(hreq);
        }
    }
}