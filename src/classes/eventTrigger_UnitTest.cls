@istest
public class eventTrigger_UnitTest
{
    Static TestMethod Void eventTrigger_Test()
    {
        Event event = New Event();
        event.IsAllDayEvent = True ;
        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.Subject = 'Call';
        event.Create_Goto_Meeting_Invite__c = True;
        event.Description = 'abcd';
   
        //event.GTM_Meeting_ID__c = 'qwerw3r';
       Try{
            insert event;
       		event.Description = null;
       		event.Create_Goto_Meeting_Invite__c = false;
            update event;
            delete event;
        } catch(Exception ex){
            System.debug('ex...'+ex.getMessage());
        }
       
    }
    Static TestMethod Void eventTrigger_Test1()
    {
        Event event = New Event();
        event.IsAllDayEvent = True ;
        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.Subject = 'Call';
        event.Create_Goto_Meeting_Invite__c = true;
        event.Description = 'abcd';
   
        //event.GTM_Meeting_ID__c = 'qwerw3r';
       Try{
            insert event;
       		event.Description = null;
       		event.Create_Goto_Meeting_Invite__c = True;
            update event;
            delete event;
        } catch(Exception ex){
            System.debug('ex...'+ex.getMessage());
        }
       
    }
    Static TestMethod Void eventTrigger_Test2()
    {
        Event event = New Event();
        event.IsAllDayEvent = True ;
        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.Subject = 'Call';
        event.Create_Goto_Meeting_Invite__c = false;
        event.Description = 'abcd';
   
        //event.GTM_Meeting_ID__c = 'qwerw3r';
       Try{
            insert event;
       		event.Description = null;
       		event.Create_Goto_Meeting_Invite__c = true;
            update event;
            delete event;
        } catch(Exception ex){
            System.debug('ex...'+ex.getMessage());
        }
       
    }
    
  Static TestMethod Void callOut_Test()
    {
        Event event = New Event();
        event.IsAllDayEvent = True ;
        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.Subject = 'Call';
        event.Create_Goto_Meeting_Invite__c = True;
        //event.GTM_Meeting_ID__c = 'qwerw3r';
        
        try
        {
            Insert event;
        }
        catch(Exception ex){
            System.debug('ex...'+ex.getMessage());
        }
        
        
        // Create GTMAccessToken Record
        
        GTMAccessToken__c accObj = new GTMAccessToken__c();
        user user = createUser();
        accObj.Expiry_Date__c = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        accObj.User__c = user.Id;
        accObj.Email__c = 'klanka@rainmaker-llc.com';
        accObj.AccessToken__c = '1234';
        insert accObj;
        
                
       CreateMeetingInfo cm = new CreateMeetingInfo();
        cm.subject = 'This is test meeting - Update';
        cm.starttime = Datetime.valueOf('2013-02-16 07:00:0000');
        cm.endtime = Datetime.valueOf('2013-02-16 08:00:0000');
        cm.passwordrequired = 'false';
        cm.conferencecallinfo = 'Free';
        cm.meetingtype = 'Scheduled';
        cm.timezonekey = '';
        String cmString = JSON.serialize(cm);
        try
        {
            GTMHelper.createMeeting(cmString,event.Id,'');
            GTMHelper.updateMeeting(cmString,event.Id,'');
            GTMHelper.deleteMeeting(event.Id,'');
           
        }
        catch(Exception ex)
        {
            System.debug('Exception in call...'+ex);
        }
        
    }
    
    Static TestMethod Void callOut1_Test()
    {
        Event event = New Event();
        event.IsAllDayEvent = True ;
        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.Subject = 'Call';
        event.Create_Goto_Meeting_Invite__c = True;
        //event.GTM_Meeting_ID__c = 'qwerw3r';
        try
        {
           Insert event;
            update event;
        }
        catch(Exception ex){
            System.debug('ex...'+ex.getMessage());
        }
        // Create GTMAccessToken Record
        
        GTMAccessToken__c accObj = new GTMAccessToken__c();
        user user = createUser();
        accObj.User__c = user.Id;
        accObj.Email__c = 'klanka@rainmaker-llc.com';
        accObj.Expiry_Date__c = Null;
        accObj.AccessToken__c = '1234';
        insert accObj;
               
       CreateMeetingInfo cm = new CreateMeetingInfo();
        cm.subject = 'This is test meeting - Update';
        cm.starttime = Datetime.valueOf('2013-02-16 07:00:0000');
        cm.endtime = Datetime.valueOf('2013-02-16 08:00:0000');
        cm.passwordrequired = 'false';
        cm.conferencecallinfo = 'Free';
        cm.meetingtype = 'Recurring';
        cm.timezonekey = '';
        String cmString = JSON.serialize(cm);
        try
        {
            GTMHelper.createMeeting(cmString,event.Id,'');
            GTMHelper.updateMeeting(cmString,event.Id,'');
            GTMHelper.deleteMeeting(event.Id,'');
            GTMHelper.getOrganizers();
        }
        catch(Exception ex)
        {
            System.debug('Exception in call...'+ex);
        }
    }
   /* Static TestMethod Void GOTOMeetingConnect_Test()
    {     
       CreateMeetingInfo cm = new CreateMeetingInfo();
        cm.subject = 'This is test meeting - Update';
        cm.starttime = Datetime.valueOf('2013-02-16 07:00:0000');
        cm.endtime = Datetime.valueOf('2013-02-16 08:00:0000');
        cm.passwordrequired = 'false';
        cm.conferencecallinfo = 'Free';
        cm.meetingtype = 'Scheduled';
        cm.timezonekey = '';
        String cmString = JSON.serialize(cm);
        //mine--
        user user = createUser();
        
        try{   
            System.debug('GOTOMeetingConnect.............');
            GOTOMeetingConnect.deleteMeeting('1234','1234');
            GOTOMeetingConnect.getMyMeetings('1234');
            GOTOMeetingConnect.updateMeeting('1234',cm,'1234');
            Map<String, String> map123 =  new Map<String, String>();
            map123.put('1234', '1234');
            GOTOMeetingConnect.buildURL('1234',map123);
            GOTOMeetingConnect.createMeeting('1234',cm);
            GOTOMeetingConnect.GroupInfo GTg= new GOTOMeetingConnect.GroupInfo();
            GOTOMeetingConnect.getMeetingById(String.Valueof(Event.id),String.Valueof(user.id));
        }
        catch(Exception ex)
        {
            System.debug('Exception in call'+ex.getMessage());
        }
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       */
    
         Static TestMethod Void eventTrigger_Test3(){
         	User User1= createUser();
     	    Event event = New Event();
	        event.IsAllDayEvent = True ;
	        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.Subject = 'Call';
	        event.Create_Goto_Meeting_Invite__c = false;
	        event.Description = 'abcd';
	        event.OwnerId=User1.id;
	        
	        GTMAccessToken__c accObj = new GTMAccessToken__c();
	        accObj.Expiry_Date__c = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        accObj.User__c = user1.Id;
	        accObj.Email__c = 'klanka@rainmaker-llc.com';
	        accObj.AccessToken__c = '1234';
	        insert accObj;
	   
	        //event.GTM_Meeting_ID__c = 'qwerw3r';
	       Try{
	            insert event;
	            event.Description='';
	       		update event;
	       		delete event;
	        } catch(Exception ex){
	            System.debug('ex...'+ex.getMessage());
	        }	
        }
    	
    	 Static TestMethod Void eventTrigger_Test4(){
     		user user = createUser();
     	    Event event = New Event();
	        event.IsAllDayEvent = True ;
	        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.Subject = 'Call';
	        event.Create_Goto_Meeting_Invite__c = true;
	        event.Description = '';
	        event.ownerid=user.id;
	        
	        GTMAccessToken__c accObj = new GTMAccessToken__c();
	        accObj.Expiry_Date__c = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        accObj.User__c = user.Id;
	        accObj.Email__c = 'klanka@rainmaker-llc.com';
	        accObj.AccessToken__c = '1234';
	        insert accObj;
	   
	        //event.GTM_Meeting_ID__c = 'qwerw3r';
	       Try{
	            insert event;
	            event.Description='this is a test||*';
	       		update event;
	       		event.Description='this is a test|';
	       		update event;
	       		event.Description='||*';
	       		update event;
	       		delete event;
	        } catch(Exception ex){
	            System.debug('ex...'+ex.getMessage());
	        }	
         }
          Static TestMethod Void eventTrigger_Test5(){
     		user user = createUser();
     	    Event event = New Event();
	        event.IsAllDayEvent = True ;
	        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        event.Subject = 'Call';
	        event.Create_Goto_Meeting_Invite__c = false;
	        event.Description = '';
	        event.ownerid=user.id;
	        
	        GTMAccessToken__c accObj = new GTMAccessToken__c();
	        accObj.Expiry_Date__c = datetime.newInstance(2008, 12, 1, 12, 30, 2);
	        accObj.User__c = user.Id;
	        accObj.Email__c = 'klanka@rainmaker-llc.com';
	        accObj.AccessToken__c = '1234';
	        insert accObj;
	   
	        //event.GTM_Meeting_ID__c = 'qwerw3r';
	       Try{
	            insert event;
	            event.Description='';
	       		update event;
	       		
	       		delete event;
	        } catch(Exception ex){
	            System.debug('ex...'+ex.getMessage());
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