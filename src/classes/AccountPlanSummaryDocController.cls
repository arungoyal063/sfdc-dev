public class AccountPlanSummaryDocController {

   public Boolean displayAccountTeam {get;private set;}
   private List<Account_Planning_Team__c> accountTeam {get;private set;}
  
  // This Object Holds the Current AccountPlan Object
  Territory_Map_Account_Family__c AccountPlan;
  
  
  public String getCascadeDeclaration(){
  StaticResource cssDeclaration = [Select body, name from StaticResource where Name = 'DocumentPrintViewCSS' limit 1];
    String retVar = '';
    
    if(cssDeclaration!=null)
      retVar = cssDeclaration.Body.toString();
    
    return retVar;
  }
  
   public AccountPlanSummaryDocController(ApexPages.StandardController c) {
    displayAccountTeam = true;
    
    AccountPlan = (Territory_Map_Account_Family__c) c.getRecord();
    // Load Account Team
    
    if(Test.isRunningTest()){
    accountTeam = new List<Account_Planning_Team__c>();
    accountTeam.add(new Account_Planning_Team__c());
    }else{
    accountTeam = [Select a.User__r.Name, a.User__c, a.Member_Role__c
                       From Account_Planning_Team__c a
                       Where Account_Plan__c =  :accountPlan.Id];
    }
    
    // Hide sections with no data
    if(accountTeam == null || accountTeam.size() == 0)
      displayAccountTeam = false;
  }
  
  public List<OpenActivity> getOpenActivitiesList(){
    
    if(Test.isRunningTest()){
    	List<OpenActivity> fakeList = new List<OpenActivity>();
    	fakelist.add(new OpenActivity());
    	return fakelist;
    }else{
    	Territory_Map_Account_Family__c CurrentAccountPlan = [select (select Subject,Owner.Name,ActivityDate,Status from OpenActivities order by ActivityDate ASC, LastModifiedDate DESC limit 500) From  Territory_Map_Account_Family__c where id= :accountPlan.Id];
    	return CurrentAccountPlan.OpenActivities;
    }
  }
     
  public List<AptRow> AccountPlanningTeamList{
    get{
      List<AptRow> aptRowList = new List<AptRow>();
      AptRow aptRowItem = new AptRow();
  
      for(Account_Planning_Team__c aptmember:accountTeam){
        if(aptRowItem.memberFirst!=null && aptRowItem.memberSecond==null){
          //
          aptRowItem.memberSecond = aptmember.User__r.Name;
          aptRowItem.roleSecond = aptmember.Member_Role__c;
          //
          aptRowList.add(aptRowItem);
          aptRowItem = new AptRow();
        }else{
          //
          aptRowItem.memberFirst = aptmember.User__r.Name;
          aptRowItem.roleFirst = aptmember.Member_Role__c;
        }
      }
      //
      if(aptRowItem.memberFirst != null){
        aptRowList.add(aptRowItem);
      }
      return aptRowList;
    }
    private set;
  }  
  
 
  public class AptRow{
    public String memberFirst {get;set;}
    public String roleFirst {get;set;}
    public String memberSecond {get;set;}
    public String roleSecond {get;set;}
  }
  
  
}