@isTest
private class SoapUnzipperTest {

   /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
   **/
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof SoapUnzipper.unzipStaticResource_element) {
                SoapUnzipper.unzipStaticResourceResponse_element unzip = new SoapUnzipper.unzipStaticResourceResponse_element();
                unzip.result = 'test';
                response.put('response_x', unzip);
            }
           
        }
    }  
    
    
   static testmethod void SoapUnzipper_unitTest() {
       Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
       SoapUnzipper.Unzipper unzipObj = new SoapUnzipper.Unzipper();
       String unzipString =  unzipObj.unzipStaticResource('Case.Object'); 
       SoapUnzipper.LogInfo logInfo = new SoapUnzipper.LogInfo();
       SoapUnzipper.AllowFieldTruncationHeader_element fieldObj  = new SoapUnzipper.AllowFieldTruncationHeader_element();
       SoapUnzipper.DebuggingHeader_element debugObj = new SoapUnzipper.DebuggingHeader_element();
       SoapUnzipper.CallOptions_element callObj = new SoapUnzipper.CallOptions_element();
       SoapUnzipper.SessionHeader_element sessionObj = new SoapUnzipper.SessionHeader_element();
       SoapUnzipper.DebuggingInfo_element debugInfo =   new SoapUnzipper.DebuggingInfo_element();
       
       Unzipper.unzipStaticResource('Case.Object');
   }
}