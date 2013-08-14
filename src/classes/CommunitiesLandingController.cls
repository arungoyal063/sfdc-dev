/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
    if(UserInfo.getUserType() == 'Guest')
       return goToEllucian();
       else
       return Network.communitiesLanding();
    }
    
    public PageReference goToEllucian() {
        return new PageReference('http://ellucian.okta.com');
    }
    
    public CommunitiesLandingController() {}
    
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
      }    
}