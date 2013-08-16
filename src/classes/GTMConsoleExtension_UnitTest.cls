/*******************************************************************************************************************
** Module Name   : GTMConsoleExtension_UnitTest
** Description   : Test various method used in GTMConsoleExtension Apex Class by taking differnt input to test all possible condition
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
*********************************************************************************************************************/
@isTest
public  class GTMConsoleExtension_UnitTest {
    static testMethod void  GTMConsoleExtension_Test(){
       
        Account ac= new account();
        ac.name='test';
        insert ac;
        
        System.assert(ac.Id != null);
        ac = [SELECT Id, Name FROM Account WHERE Id= :ac.Id LIMIT 1];
        System.assertEquals(ac.Name, 'test');
            
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