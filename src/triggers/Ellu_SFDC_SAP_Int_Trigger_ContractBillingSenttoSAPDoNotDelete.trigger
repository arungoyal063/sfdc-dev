trigger  Ellu_SFDC_SAP_Int_Trigger_ContractBillingSenttoSAPDoNotDelete on Contract_Billing__c (before delete) {

    for(Contract_Billing__c ObjCBill : [SELECT Id,  ContractId__r.Send_to_SAP__c FROM Contract_Billing__c WHERE Id IN : trigger.Old]){
    
        if(ObjCBill.ContractId__r.Send_to_SAP__c==true){
        
            trigger.OldMap.get(ObjCBill.Id).adderror('Contract Billing record cannot be deleted or created because the contract is already sent to SAP');
        }
    }

}