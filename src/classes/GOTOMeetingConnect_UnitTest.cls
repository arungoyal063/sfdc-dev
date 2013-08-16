/*******************************************************************************************************************
** Module Name   : GOTOMeetingConnect_UnitTest
** Description   : Test various method used in GOTOMeetingConnect by taking differnt input to test all possible condition
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
*********************************************************************************************************************/
@isTest
public  class GOTOMeetingConnect_UnitTest {
    static testMethod void GOTOMeetingConnect_Test(){
            User GTMUser = createUser();
            Event event = New Event();
            event.IsAllDayEvent = True ;
            event.StartDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
            event.EndDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
            event.Subject = 'Call';
            event.description='test description||*';
            event.Create_Goto_Meeting_Invite__c = True;
            try{            
                Insert event;
                
                System.assert(event.Id != null);
                event = [SELECT Id, Create_Goto_Meeting_Invite__c FROM Event WHERE Id= :event.Id LIMIT 1];
                System.assertEquals(event.Create_Goto_Meeting_Invite__c, true);
            }
            catch(Exception ex){
                System.debug('ex...'+ex.getMessage());
            }    
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
            
            
            /*System.assert(accObj.Id != null);
            accObj = [SELECT Id, User__c FROM GTMAccessToken__c WHERE Id= :accObj.Id LIMIT 1];
            System.assertEquals(accObj.User__c, GTMUser.Id);*/
            System.runas(GTMUser) {
            System.debug('GOTOMeetingConnect.............');
            GTM_Oauth_Detail1__c mycs = new GTM_Oauth_Detail1__c();
            mycs.Name= 'CustomValues';
            mycs.CLIENT_ID__c = '&client_id=470bff5235932d0f1922c2cf3e4575b7';
            mycs.GROUP_URL__c = 'https://api.citrixonline.com/G2M/rest/groups';
            mycs.MEETINGS_URL__c= 'https://api.citrixonline.com/G2M/rest/meetings';
            mycs.OAUTH_URL__c = 'https://api.citrixonline.com/oauth/access_token?grant_type=authorization_code&code=';
            mycs.ORGANIZERS_URL__c= '/organizers';  
            insert mycs;
            
            GOTOMeetingConnect.GROUP_URL = 'https://api.citrixonline.com/G2M/rest/groups';
            GOTOMeetingConnect.MEETINGS_URL= 'https://api.citrixonline.com/G2M/rest/meetings';
            GOTOMeetingConnect.ORGANIZERS_URL= '/organizers'; 
            GOTOMeetingConnect.deleteMeeting('1234','1234');
            GOTOMeetingConnect.getMyMeetings('1234');
            GOTOMeetingConnect.updateMeeting('1234',cm,'1234');
            Map<String, String> map123 =  new Map<String, String>();
            map123.put('1234', '1234');
            GOTOMeetingConnect.buildURL('1234',map123);
            GOTOMeetingConnect.createMeeting('1234',cm);
            GOTOMeetingConnect.GroupInfo GTg= new GOTOMeetingConnect.GroupInfo();
            //GOTOMeetingConnect.getMeetingById(event.id,GTMUser.id);
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