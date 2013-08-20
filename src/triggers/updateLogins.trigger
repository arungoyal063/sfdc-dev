trigger updateLogins on Case (before insert, before update) {

Set<Id> accntIds = new Set<Id>();

for(Case ca : Trigger.new){
    accntIds.add(ca.AccountId); 
}

Map<Id,List<Login__c>> loginMap = new Map<Id,List<Login__c>>();
List<Login__c> loginList = [SELECT Id, Name, Account__c, Primary_Login__c, Sandbox_Login__c, Auto_Login_URL__c FROM Login__c WHERE Account__c IN: accntIds AND Primary_Login__c = true];  

for(Id accId :accntIds){
     List<Login__c> temp = new List<Login__c>();
     for(Login__c lList : loginList){
         if(lList.Account__c == accId)
            temp.add(lList);
     }
     loginMap.put(accId,temp);
}

for(Case ca : Trigger.new){
    List<Login__c> lList = loginMap.get(ca.AccountId);
    for(Login__c loList : lList){
        if(ca.AccountId == loList.Account__c && loList.Primary_Login__c == true && loList.Sandbox_Login__c == false)
           ca.Production_Login__c = loList.Auto_Login_URL__c;
        if(ca.AccountId == loList.Account__c && loList.Primary_Login__c == true && loList.Sandbox_Login__c == true)
           ca.Sandbox_Login__c = loList.Auto_Login_URL__c;           
    }
    if(ca.AccountId == null){
       ca.Production_Login__c = '';
       ca.Sandbox_Login__c = '';
    }
}

}