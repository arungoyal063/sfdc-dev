/*********************************************************************************************************************
* Module Name   :  RedirectToCase Apex Controller 
* Description   :  This Class is used to Redirect User to Different Case Layout according to user profile
* Throws        :  <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  Test_RedirectToCase
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/01/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
public with sharing class RedirectToCase {
    
    private final list<String> communityprofiles = new list<String>{'Ellucian Support Center','Support','Commmunities','Communities','Community','Ellucian Communities Profile'}; 
    private String RecordTypeId;
    private Map<String, String> paramMap;
    
    public RedirectToCase(ApexPages.StandardController controller) {
        Case caseRecord = (Case)controller.getRecord();   
        
        if(caseRecord != null && caseRecord.RecordTypeId != null) {
            RecordTypeId = caseRecord.RecordTypeId;  
        }  
        	paramMap = ApexPages.currentPage().getParameters();
        if(ApexPages.currentPage().getParameters().size() > 0) {
            if(paramMap.containsKey('sfdc.override')) {
                paramMap.remove('sfdc.override');
            } 
            if(paramMap.containsKey('save_new')) {
                paramMap.remove('save_new');
            }  
        }
    }
    
    //To redirect
    public pageReference pageRedirect() {
        pageReference pr;// = new pageReference('/' + Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?retURL='+Change_Request__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
        
        if(getProfile()){
            pr = new pageReference('/clients/caseproductselection?retURL=/500/o');
            return pr;  
        }
         
        String stdReirect =  '/500/e?nooverride=1';
        //  stdReirect += '&retURL=/500/o';
        pr = new pageReference(stdReirect);
        
        if(!paramMap.isEmpty()) {
            pr.getParameters().putAll(paramMap);
        } else {        
            if(RecordTypeId != null && RecordTypeId != '') {
                stdReirect +=  '&RecordType=' + RecordTypeId;
            }
            stdReirect += '&retURL=/500/o';
            pr = new pageReference(stdReirect);
        }      
        return pr;//new pageReference('/home/home.jsp');
    }
    
    //Get profile
    private boolean getProfile(){
        boolean isCommunityUser = false;
        list<Profile> objProfile = new list<Profile>{[Select Name, Id From Profile where id =:Userinfo.getProfileId() limit 1]};
        if(!objProfile.isEmpty()){
            system.debug(communityprofiles+'============'+objProfile);
            for(String comProf:communityprofiles){
                if((objProfile.get(0).Name).contains(comProf) && (''+ URL.getCurrentRequestUrl()).contains('clients')){
                    isCommunityUser = true;
                }
            }
        }
        return isCommunityUser;
    }
}