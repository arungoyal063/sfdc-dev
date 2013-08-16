/*******************************************************************************************************************
** Module Name   : GTMHelper_UnitTest
** Description   : Test various methods used in GTMHelper Apex Class by taking differnt input to test all possible condition
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
*********************************************************************************************************************/
@istest
private class GTMHelper_UnitTest {
    Static TestMethod Void GTMHelper_Test() {
        // set up Event
        User GTMUser = createUser();
        Event event = New Event();
        event.IsAllDayEvent = True ;
        event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        event.Subject = 'Call';
        event.Create_Goto_Meeting_Invite__c = True;
        event.OwnerId=GTMUser.id;
        //event.GTM_Meeting_ID__c = 'qwerw3r';
        try
        {
             Insert event;
             
             System.assert(event.Id != null);
             event = [SELECT Id, Subject FROM Event WHERE Id= :event.Id LIMIT 1];
             System.assertEquals(event.Subject, 'Call');
             update event;  
        }
        catch(Exception ex){
            System.debug('ex...'+ex.getMessage());
        } 
        
        Map<String, String> map1 = new Map<String, String> {};
        map1.put('token','This is a token');
        
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
                
        GTMHelper.ApplicationException Gap= new  GTMHelper.ApplicationException();  
        GTMHelper.MeetingDetails  GMeet = new   GTMHelper.MeetingDetails('test','1234','test12','yes','test');
        GTMHelper.MeetingDetails  GMeet1 = new  GTMHelper.MeetingDetails('yes','test');
            
        
        System.runas(GTMUser) {
            try{
              GTMHelper.createMeeting(cmString, event.Id, GTMUser.Id);
              GTMHelper.updateMeeting(cmString,event.Id, GTMUser.Id);
              GTMHelper.deleteMeeting(event.Id,GTMUser.Id);
              GTMHelper.EventDeleted_deleteMeeting(GTMUser.Id, '');
              GTMHelper.getMeetingIdFromDescription('this is a test');
              GTMHelper.errorReporting('testbody');
              GTMHelper.isUserHaveGTMAccount(GTMUser.id);
              GTMHelper.isUserHaveGTMAccount('');
              GTMHelper.deleteRemoteMeeting('1234',GTMUser.Id);
              GTMHelper.createRemoteMeeting('10/14/2011 11:46 AM','10/14/2011 12:46 PM','Recurring','Recurring',GTMUser.id);
              GTMHelper.getOrganizers();
              GTMHelper.CreateCustomTriggerMesssage('Hello World',true); 
              GTMHelper.EventDeleted_BulkdeleteMeeting(map1);
             
            }catch(Exception ex){}
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