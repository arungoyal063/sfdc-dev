global without sharing class GTMAPICalloutBundle_PostInstall implements InstallHandler {
    global void onInstall(InstallContext context) {             
        RMA_C2M__GTM_Oauth_Detail1__c objGTMOauthDetail = new RMA_C2M__GTM_Oauth_Detail1__c(
                                            RMA_C2M__ORGANIZERS_URL__c='/organizers', 
                                            RMA_C2M__OAUTH_URL__c='https://api.citrixonline.com/oauth/access_token?grant_type=authorization_code&code=', 
                                            RMA_C2M__MEETINGS_URL__c = 'https://api.citrixonline.com/G2M/rest/meetings', 
                                            RMA_C2M__GROUP_URL__c='https://api.citrixonline.com/G2M/rest/groups', 
                                            RMA_C2M__CLIENT_ID__c='&client_id=470bff5235932d0f1922c2cf3e4575b7', 
                                            Name='GTMCalloutInfo' );
        insert objGTMOauthDetail;
    }
}