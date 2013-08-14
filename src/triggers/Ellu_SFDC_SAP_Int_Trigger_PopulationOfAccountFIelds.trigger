trigger Ellu_SFDC_SAP_Int_Trigger_PopulationOfAccountFIelds on Account (before insert,before update) {

    Set<Id> SetOwnerId = new Set<Id>();
    List<RenewalDateAugustClients__c> ObjRenDaAugClients = new List<RenewalDateAugustClients__c>();
    CustSettingJuneRenewalDate__c ObjJuneRenDate = new CustSettingJuneRenewalDate__c ();
    
    Map<Id,User> MapIdToEmpNumber = new Map<Id,User>();
    Map<String,RenewalDateAugustClients__c> MapStrRenDateAugClient= new Map<String,RenewalDateAugustClients__c>();
    //Map<String,CustSettingRenewalDate__c> MapStrRenDate= new Map<String,CustSettingRenewalDate__c>();
    try{
        ObjJuneRenDate = [SELECT Renewal_Date__c FROM CustSettingJuneRenewalDate__c LIMIT 1];

        //system.debug('RENEWAL DATE'+ObjRenDate.Renewal_Date__c);
        for(RenewalDateAugustClients__c TempObjRenDate : [SELECT ID ,Client_Number__c,Renewal_Date__c FROM RenewalDateAugustClients__c]){
    
            MapStrRenDateAugClient.put(TempObjRenDate.Client_Number__c ,TempObjRenDate );    
        }
    
    
    
        for(Account obj : trigger.new){
        
            SetOwnerId.add(obj.OwnerId);
        
        }
        
        //List<User> LstObjUser = new List<User>();
        for(User ObjUser : [SELECT Id,EmployeeNumber FROM User WHERE Id IN:SetOwnerId ]){
        
            MapIdToEmpNumber.put(ObjUser.Id,ObjUser);
        }
    
        for(Account objAcc : trigger.new){
            try{
            //objAcc.Owner_EmployeeNumber__c= MapIdToEmpNumber.get(objAcc.OwnerId).EmployeeNumber;
            }
            catch(exception e){
                //Bypassing the field updation when there is no employee id corresponding to the Owner
            }
            if(MapStrRenDateAugClient.get(objAcc.AccountNumber)<>null){
            //system.debug('Renewal Date 2'+objAcc.RenewalDate__c);
            objAcc.RenewalDate__c= MapStrRenDateAugClient.get(objAcc.AccountNumber).Renewal_Date__c;
        }
        else{
        
                objAcc.RenewalDate__c=ObjJuneRenDate.Renewal_Date__c;
        }      
    }
    
    }

    catch(exception e){
    }
        
}