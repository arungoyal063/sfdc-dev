trigger Ellu_SFDC_SAP_Int_Trigger_ContractLineSenttoSAPDoNotDelete on ContractLine__c (before delete) {

    Set<Id> SetConId = new  Set<Id>();
    for(ContractLine__c ObjCLine : [SELECT Id,ContractID__r.Send_to_SAP__c FROM ContractLine__c WHERE Id IN : trigger.Old]){
        
         if(ObjCLine.ContractID__r.Send_to_SAP__c==true){
             
             trigger.OldMap.get(ObjCLine.Id).adderror('Contract Line Item record cannot be deleted or created because the contract is already sent to SAP');
         }
    }
    
    

}