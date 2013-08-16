/*******************************************************************************************************************
** Module Name   : ManageGTMSession_UnitTest
** Description   : Test various methods used in ManageGTMSession Apex Class by taking differnt input to test all possible condition
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
*********************************************************************************************************************/
@isTest
public  class ManageGTMSession_UnitTest {
        
    static testMethod void PositiveManageGTMSession_Test(){
        User GTMUser= createUser();
        ApexPages.currentPage().getParameters().put('code','test');
        System.runas(GTMUser) {
            ManageGTMSession  Mst = new ManageGTMSession();
            Mst.showSuccess=false;
            Mst.ErrorMessage='test';
            Mst.createToken();
            System.assertEquals(Mst.showSuccess, true);
           
         }
    }
    static testMethod void NegativeManageGTMSession_Test(){
        User GTMUser= createUser();
        ApexPages.currentPage().getParameters().put('code','');
        System.runas(GTMUser) {
            ManageGTMSession  Mst1 = new ManageGTMSession();
            Mst1.showSuccess=true;
            Mst1.ErrorMessage='test';
            Mst1.createToken();
            System.assertEquals(Mst1.showSuccess, false);
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
          System.assertEquals(standard.username, 'standarduserTest@testorg.com');   
          return standard;
     }

}