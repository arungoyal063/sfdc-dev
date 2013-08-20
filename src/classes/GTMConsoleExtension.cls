public with sharing class GTMConsoleExtension {

        public GTMConsoleExtension(Apexpages.StandardController controller) {
            showAlreadyExisting = false;
            GTMAccessToken__c workingToken;
            try {
                workingToken = [SELECT
                        GTMAccessToken__c.Id,
                        GTMAccessToken__c.User__c,                      
                        GTMAccessToken__c.Expiry_Date__c
                        FROM GTMAccessToken__c
                        WHERE GTMAccessToken__c.User__c =: System.Userinfo.getUserId() LIMIT 1];
               
                        //Indicate to the user that they already have valid information, but allow them to update
                        if (!(workingToken.Expiry_Date__c == null || workingToken.Expiry_Date__c < Datetime.now())) {
                                showAlreadyExisting = true;
                        }
        } catch(QueryException ex) {
            
                
        }
        }
        
        public Boolean showAlreadyExisting{get;set;}
}