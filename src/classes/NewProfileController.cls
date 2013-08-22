/*
** Module Name   : 
** Description   : 
** Throws        : 
** Calls         : 
** Test Class    : 
** 
** Organization  : 
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
**                   Atulit Gupta          
**********************************************************************************************************************************************************/

public with sharing class NewProfileController {
        //Constructor
    public NewProfileController(ApexPages.StandardController controller) {
            showTemplate = false;
            profileobj = new Profile__c();
    }

        //Vaiable Declaration
        public Profile__c profileobj { get;set;}
        public boolean useTemplate {get;set;}
        public list<selectoption> templatelist {get;set;}
        public String selectedTemplate {get;set;}
        public boolean showTemplate {get;set;}
    
    //Constructor
        public NewProfileController(){
             
        }
    
    // Method triggered when the Selectlist is selected to create a list of Radio Buttons    
        public void selectTemplate(){
                if(useTemplate){
                        showTemplate = true;
                        templatelist = new list<selectoption>();
                        for(Profile__c p: DBUtility.getProfileHavingTypeTemplate()){
                                templatelist.add(new selectOption(p.id,p.Name));
                        }
                }
                else
                showTemplate = false;
        }
    //  To insert Profile and re-direct to the new Profile.
        public PageReference onSave(){
            try{
                insert profileobj;
                profileobj = new profile__c();
                if(null != selectedTemplate){
                    pageReference pr = new pageReference('/apex/PanelSelection?pId='+selectedTemplate);
                    pr.setRedirect(true);                    
                    return pr; 
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record Saved!'));               
                }
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Due to :'+ e.getMessage()));
            }
            return null;
        }
}