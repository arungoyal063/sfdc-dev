trigger Ellu_SFDC_SAP_Int_Trigger_ContractSentToSAPDoNotdelete on Contract (before delete) {

    For(Contract ObjCon : trigger.Old){
    
        If(ObjCon.Send_to_SAP__c==true){
            trigger.OldMap.get(ObjCon.Id).adderror('You cannot delete the Contract because it is already sent to SAP');
        }
    }
}