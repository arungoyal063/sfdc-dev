/*******************************************************************************************************************
** Module Name   : Test_FeedByCommunityUser
** Description   : Test Class for FeedByCommunityUser Trigger
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

@istest
public class Test_FeedByCommunityUser {
    static testMethod void FeedByCommunityUserUnitTest() {  
        
        User pu = MockTestData.getPortalUser();     
        System.runAs(pu) {  
            // Adding a Case Record
            Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');  
            
            //Adding a Text post
            FeedItem textpost = new FeedItem();
            textpost.ParentId = c.Id; 
            textpost.Body = 'Enter post text here';
            insert textpost;
        }
    }
    
    static testMethod void FeedByCommunityUserUnitTest1() {  
        
        User pu = MockTestData.getPortalUser();     
        System.runAs(pu) {  
            // Adding a Case Record
            Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');            
            
            //Adding a Link post
            FeedItem linkpost = new FeedItem();
            linkpost.ParentId = c.Id; 
            linkpost.Body = 'Enter post text here';
            linkpost.LinkUrl = 'http://www.someurl.com';
            insert linkpost;
        }
    }
   
}