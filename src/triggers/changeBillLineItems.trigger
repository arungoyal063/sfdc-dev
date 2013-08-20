trigger changeBillLineItems on Opportunity (after update) {

if(Trigger.isUpdate){
 ID oppId = Trigger.new[0].Id;
 if(Trigger.oldMap.get(oppId).Deposit_Amount__c != Trigger.newMap.get(oppId).Deposit_Amount__c)
 {
     List<Appirio_PSAe__Proj__c> projectObj = new List<Appirio_PSAe__Proj__c>([select ID from Appirio_PSAe__Proj__c where Appirio_PSAe__Opportunity__c=:Trigger.newMap.keySet()]);
  List<Billing_Line_Item__c>  lineItemObj = new List<Billing_Line_Item__c>([select Id,Rate_per_Hour__c,Hours__c from Billing_Line_Item__c where Project__c IN :projectObj]);

  for(Billing_Line_Item__c bilingLineItems: lineItemObj)
    {
        bilingLineItems.Rate_per_Hour__c = - Trigger.newMap.get(oppId).Deposit_Amount__c;
    }
    update lineItemObj;
 }
}
}