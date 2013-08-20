@istest
 
private class HTTPUtility_UnitTest {
    Static TestMethod Void HTTPUtility_Test() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HTTPUtility.getMethod('http://www.yahoo.com', 'application/json'); 
    }
}