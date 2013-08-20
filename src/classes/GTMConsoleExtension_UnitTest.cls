@isTest
public  class GTMConsoleExtension_UnitTest {
	static testMethod void  GTMConsoleExtension_Test(){
		
		
		Account ac= new account();
		ac.name='test';
		insert ac;
		User GTMUser = createUser();
		 System.runas(GTMUser) {
		ApexPages.StandardController controller = new ApexPages.StandardController(ac); 
		GTMConsoleExtension gtExt = new GTMConsoleExtension(controller);
		gtExt.showAlreadyExisting=false;
		
		 }	
	}
	static TestMethod User createUser() {
          Map<String,ID> profiles = new Map<String,ID>();
          List<Profile> ps = [select id, name from Profile where name = 'System Administrator' or name = 'Standard User'];
          for(Profile p : ps)
          {
             profiles.put(p.name, p.id);
          }
          User standard = new User(alias = 'standard',email='test@gmail.com',emailencodingkey='UTF-8',lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US',
          profileId = profiles.get('Standard User'),
          timezonesidkey='America/Los_Angeles',
          username='standarduserTest@testorg.com');
          insert standard;     
          return standard;
     }

}