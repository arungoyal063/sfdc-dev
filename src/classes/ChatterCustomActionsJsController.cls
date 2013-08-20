public with sharing class ChatterCustomActionsJsController {
  public String getActionsConfig() {
    String actions = '';
    for (ChatterCustomAction__c c : [SELECT ActionId__c, HandlerJs__c FROM ChatterCustomAction__c WHERE Active__c=true ORDER BY LastModifiedDate]) {
      if (actions != '') actions += ',';
      actions += '{actionId:"' + c.ActionId__c + '",handlerJs:"' + c.HandlerJs__c + '"}';
    }
    return actions;
  }
}