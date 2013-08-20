@isTest
public  class GOTOMeetingConnect_UnitTest {
	static testMethod void GOTOMeetingConnect_Test(){
		 User GTMUser = createUser();
		 System.runas(GTMUser) {
	        Event event = New Event();
	        event.IsAllDayEvent = True ;
	        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.Subject = 'Call';
	        event.description='test description||*';
	        event.Create_Goto_Meeting_Invite__c = True;
	        //event.GTM_Meeting_ID__c = 'qwerw3r';
	        
	        Insert event;
	               
	        // set up CreateMeetingInfo
	        CreateMeetingInfo cm = new CreateMeetingInfo();
	        cm.subject = 'This is test meeting - Update';
	        cm.starttime = Datetime.valueOf('2013-02-16 07:00:0000');
	        cm.endtime = Datetime.valueOf('2013-02-16 08:00:0000');
	        cm.passwordrequired = 'false';
	        cm.conferencecallinfo = 'Free';
	        cm.meetingtype = 'Recurring';
	        cm.timezonekey = '';
	        String cmString = JSON.serialize(cm);
	        
	        GTMAccessToken__c accObj = new GTMAccessToken__c();
	       
	        accObj.User__c = GTMUser.Id;
	        accObj.Email__c = 'klanka@rainmaker-llc.com';
	        accObj.Expiry_Date__c = Null;
	        accObj.AccessToken__c = '1234';
	        insert accObj;
        	
            System.debug('GOTOMeetingConnect.............');
            GOTOMeetingConnect.deleteMeeting('1234','1234');
            GOTOMeetingConnect.getMyMeetings('1234');
            GOTOMeetingConnect.updateMeeting('1234',cm,'1234');
            Map<String, String> map123 =  new Map<String, String>();
            map123.put('1234', '1234');
            GOTOMeetingConnect.buildURL('1234',map123);
            GOTOMeetingConnect.createMeeting('1234',cm);
            GOTOMeetingConnect.GroupInfo GTg= new GOTOMeetingConnect.GroupInfo();
            GOTOMeetingConnect.getMeetingById(event.id,GTMUser.id);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
	        GOTOMeetingConnect.getOrganizers('1234');            
            map123.put('123411', '123412');
      		GOTOMeetingConnect.buildURL('1234',map123);
        }
    }
    
     public TestMethod static User createUser()
    {
      Map<String,ID> profiles = new Map<String,ID>();
      List<Profile> ps = [select id, name from Profile where name = 'System Administrator' or name = 'Standard User'];
      for(Profile p : ps)
      {
         profiles.put(p.name, p.id);
      }
      User standard = new User(alias = 'standard',email='klanka@rainmaker-llc.com',emailencodingkey='UTF-8',lastname='Testing', languagelocalekey='en_US',
      localesidkey='en_US',
      profileId = profiles.get('Standard User'),
      timezonesidkey='America/Los_Angeles',
      username='standarduserTest@testorg.com');
      insert standard;     
      return standard;
    }

}