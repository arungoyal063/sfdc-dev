trigger Ellu_SFDC_SAP_Int_Trigger_ContractRevSenttoSAPDoNotDelete on Contract_Revenue__c (before delete) {

    for(Contract_Revenue__c ObjCRevenue : [SELECT Id,ContractId__r.Send_to_SAP__c,ContractLine__r.CountOfContractRev__c FROM Contract_Revenue__c WHERE Id IN : trigger.Old]){
        
         if(ObjCRevenue.ContractId__r.Send_to_SAP__c==true){
             
             trigger.OldMap.get(ObjCRevenue.Id).adderror('Contract Revenue record cannot be deleted or created because the contract is already sent to SAP');
         }
         if(ObjCRevenue.ContractLine__r.CountOfContractRev__c > 0){
         
             trigger.OldMap.get(ObjCRevenue.Id).adderror('Contract Revenue record cannot be deleted because there should be atleast one revenue record for Maintenance or Annual License ');        
         }
    }

}