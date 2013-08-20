trigger checkDuplicatePrimaryLogin on Login__c (before insert, before update) {

  Set<Id> accntId = new Set<Id>();
  
  for(Login__c lo : Trigger.New){
  
      if(lo.Primary_Login__c == true)
         accntId.add(lo.Account__c);
  }
  
  Map<Id,List<Login__c>> loMap = new Map<Id,List<Login__c>>();
  
  List<Login__c> lolist = [SELECT Account__c,Primary_Login__c,Sandbox_Login__c FROM Login__c WHERE Account__c IN: AccntId AND Primary_Login__c =: true]; 
  
  for(Id accId :accntId){
     List<Login__c> temp = new List<Login__c>();
     for(Login__c lList : loList){
         if(lList.Account__c == accId)
            temp.add(lList);
     }
     loMap.put(accId,temp);
  }

  for(Login__c lo : Trigger.New){
      if(lo.Primary_Login__c == true && lo.Sandbox_Login__c == false){
          List<Login__c> tempList = loMap.get(lo.Account__c);
          system.debug('templist..'+templist);
          for(Login__c login : tempList){
              if(login.Primary_Login__c == true && login.Sandbox_Login__c == false && lo.Id != login.Id)
                 lo.adderror('Duplicate Primary Login for Production already exist.');
          }
      }
      if(lo.Primary_Login__c == true && lo.Sandbox_Login__c == true){
          List<Login__c> tempList = loMap.get(lo.Account__c);
          for(Login__c login : tempList){
              if(login.Primary_Login__c == true && login.Sandbox_Login__c == true  && lo.Id != login.Id)
                 lo.adderror('Duplicate Primary Login for Sandbox already exist.');
          }
      }
  }        
}