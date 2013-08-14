/*******************************************************************************************************************
** Module Name   : ESCUserControllerExt
** Description   : Controller Extension for ESC User Standard Controller
** Throws        : NA
** Calls         : NA
** Test Class    : <Test_ESCUserControllerExt>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-03-11  AW                    Initial Version
******************************************************************************************************************/
public class ESCUserControllerExt {
    
    /* List of Assigned Permission Set */
    public List<PermissionSetAssignment> psAssigned{get; set;}
    public String listURL{get;set;}
    public String printURL{get;set;}
    
    private String ESCuserId;
    private final Set<String> portalUser = new Set<String>{'PowerCustomerSuccess',
                                                           'CustomerSuccess','CspLitePortal'};
    
    /* ESC User Standard Controller */
    public ESCUserControllerExt(ApexPages.StandardController controller) {
         psAssigned = new List<PermissionSetAssignment>();
         ESCuserId = ApexPages.currentPage().getParameters().get('Id');
         listURL = '/clients/' + Community_User__c.SObjectType.getDescribe().getKeyPrefix() + '/o';
         printURL = controller.View().getURL() + '/p?retURL' + controller.View().getURL() ;
         try {
             if (ESCuserId != null && (!ESCuserId.trim().equals(''))){
                 List<Community_User__c> ESCUserList = [SELECT Id, RelatedUserId__c FROM Community_User__c 
                                                        WHERE Id =:ESCuserId LIMIT 1];
                 
                 if ((!ESCuserList.isEmpty()) && (ESCuserList.get(0).RelatedUserId__c != null)){
                     psAssigned = [SELECT PermissionSetId,PermissionSet.Name, 
                                          Id, AssigneeId, SystemModstamp
                                          FROM PermissionSetAssignment
                                          WHERE AssigneeId = :ESCUserList.get(0).RelatedUserId__c
                                          AND PermissionSet.IsOwnedByProfile = false];    
                 }
             } 
         } catch(Exception e) {
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));    
         }     
    }
    
    public PageReference redirectOnload() {
        
        /*if user is standard salesforce user, redirect him to standard ESC user View page */
        if((!portalUser.contains(UserInfo.getUserType())) && ESCuserId != null && (!ESCuserId.trim().equals(''))) {
            PageReference page = new PageReference('/' + ESCuserId + '?nooverride=1');
            page.setRedirect(true);
            return page;    
        }    
        return null;   
    }  
}