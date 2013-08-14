@isTest
private class Test_Contact_WebPortalActivation{
    static testMethod void Contact_WebPortalActivationUnitTest() {
    		User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
			System.runAs(thisUser) {
             User pu = MockTestData.getPortalUser();
         
             Test.startTest();             
             Set<ID> IdSet = new Set<ID>();
             IdSet.add(pu.Id);
             Contact_WebPortalActivation.Disable(IdSet);
             Contact_WebPortalActivation.Enable(IdSet);
             Contact_WebPortalActivation.DisableCommunityUser(IdSet);
             Contact_WebPortalActivation.EnableCommunityUser(IdSet);             
             Test.stopTest();
			}
    }
    
    static testMethod void contactUpdateUnitTest() {
        User pu = MockTestData.getPortalUser();
        User u = [Select Id, ContactId from User where Id = :pu.Id];
        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select u.Title, u.Street__c, u.State__c, u.ZipCode__c,
                                                                u.Phone, u.MobilePhone, u.LastName, u.Id,
                                                                u.FirstName, u.Fax, u.Email, 
                                                                u.Country__c, u.City__c FROM Contact u where Id= :u.ContactId]);
                                                                    
        Contact c = contactMap.get(u.ContactId);
        c.Email = 'Test@mail.com';
        User intu = [Select Id from User where Id =:UserInfo.getUserId()];
        System.runas(u) {
            Contact_WebPortalActivation.updateUserRecord(contactMap);
        }
    }
}