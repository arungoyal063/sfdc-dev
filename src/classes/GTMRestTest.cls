@RestResource(urlMapping='/rest/CreateGTM/*')
global with sharing class GTMRestTest {

	@HttpGet
    global static String CreateGTM() {
    	System.debug('restJson....11');
    	String restJson =  RestContext.request.params.get('json');    		
    		System.debug('restJson....'+restJson);
    		
    		return 'success';
    }
}