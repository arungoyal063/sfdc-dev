/*******************************************************************************************************************
** Module Name   : Test_CommunityUserController
** Description   : Test Class for Community User Controller
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-02-05  AC                    Initial Version
******************************************************************************************************************/
@isTest
private class Test_CommunityUserController{
     static testMethod void CommunityUserController_UnitTest() {
         User u = MockTestData.getPortalUser();     
         User pu = updatePortaluser(u);
         System.runAs(pu) {   
            
             update pu;
             Set<ID> IdSet = new Set<ID>();
             IdSet.add(pu.Id);
             CommunityUserController.createCommunityUser(IdSet);
             CommunityUserController.updateCommunityUser(IdSet);
              
         }
     }  
     
     public static User updatePortaluser(User pu) {
         if(pu != null && pu.Email != null) {
             pu.Email = pu.Email + 'test';    
         }
         return pu;      
     }
     
     /*public static User getPortalUser() {
          Account a;
          Contact c;
          a = new Account(name = 'TEST ACCOUNT');
          Database.insert(a);
            
          c = new Contact(AccountId = a.id, lastname = 'lastname');
          Database.insert(c);
     
           Profile p = [SELECT Id FROM profile WHERE name='Ellucian Communities Profile'];        
           // mock test user
           User pu = new User(alias = 'newUser', email='newuser@tgerm.com',
                 emailencodingkey='UTF-8', lastname='Testing', 
                 languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id,contactId = c.id,
                 timezonesidkey='America/Los_Angeles', username='newuser@tgerm.com' + System.now().getTime());
           Database.insert(pu);
           
           
           return pu;
     } */
}