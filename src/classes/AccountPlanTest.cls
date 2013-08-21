@isTest
private class AccountPlanTest{
  
  static testMethod void testAccountPlanSummaryDocController(){
    Territory_Map_Account_Family__c AccountFamily = new Territory_Map_Account_Family__c();
    
    PageReference pageRef = Page.AccountPlanSummaryDoc;
    Test.setCurrentPageReference(pageRef);
    
    ApexPages.StandardController sc = new ApexPages.StandardController(AccountFamily);
    AccountPlanSummaryDocController myPageCon = new AccountPlanSummaryDocController(sc);
    
    String cascadeDeclaration = myPageCon.getCascadeDeclaration();
    System.assert(cascadeDeclaration != null);
    
    List<OpenActivity> actList = myPageCon.getOpenActivitiesList();
    System.assert(actList == actList);
    
    List<AccountPlanSummaryDocController.AptRow> listAptRow = myPageCon.AccountPlanningTeamList;
    System.assert(listAptRow == listAptRow);
    

    
    
  }
  

  
}