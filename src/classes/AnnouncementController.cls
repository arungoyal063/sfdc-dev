/* Controller for Displaying Annoucments on Communities Home Page */

public class AnnouncementController {
    public List<Announcement__c> annList{get; set;}
    
    
    
    public AnnouncementController() {
        annList = [SELECT Id, Title__c,Description__c FROM Announcement__c WHERE IsActive__c = true LIMIT 10];
    }
    
    static testMethod void announcementUnitTest(){
        Announcement__c ann = new Announcement__c(Title__c = 'Test', Description__c = 'Test',IsActive__c = true);
        insert ann;
        AnnouncementController acr = new AnnouncementController();
        System.assert(acr.annList.size() > 0);

    }

}