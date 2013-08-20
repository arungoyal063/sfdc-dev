@isTest
public  class ManageGTMSession_UnitTest {
		
	static testMethod void PositiveManageGTMSession_Test(){
		User GTMUser= createUser();
		ApexPages.currentPage().getParameters().put('code','test');
		System.runas(GTMUser) {
			ManageGTMSession  Mst = new ManageGTMSession();
			Mst.showSuccess=false;
			Mst.ErrorMessage='this is just a test';
			Mst.createToken();
		
		   
		 }
	}
	static testMethod void NegativeManageGTMSession_Test(){
		User GTMUser= createUser();
		ApexPages.currentPage().getParameters().put('code','');
		System.runas(GTMUser) {
			ManageGTMSession  Mst1 = new ManageGTMSession();
			Mst1.showSuccess=true;
			Mst1.ErrorMessage='this is just a test';
			Mst1.createToken();
		   
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