/*Opportunity op = [SELECT Deposit_Amount__c, name, id FROM Opportunity WHERE id =: proj.Appirio_PSAe__Opportunity__c];
        
        //proj.adderror('opportunity: ' + proj.Appirio_PSAe__Opportunity__c + ' op name: ' + op.Deposit_Amount__c);
        processController s123= new processController()
        if(op.Deposit_Amount__c > 0)
        {
            Billing_Line_Item__c bill = new Billing_Line_Item__c();
            bill.Project__c = proj.id;
            bill.Hours__c =1;
            bill.Rate_per_Hour__c = -1000;
            bill.Notes__c = 'Project Deposit';
            bill.Invoiced__c = 'Not Invoiced';
            List<Billing_Line_Item__c> blis = [SELECT id, Project__c, Notes__c 
                                                FROM Billing_Line_Item__c 
                                                WHERE Project__c =: proj.id];
            
            boolean projectDeposited = false;
            
            for(Billing_Line_Item__c oldBill : blis)
            {   
                if(oldBill.Notes__c == 'Project Deposit')
                {
                    projectDeposited = true;
                }                                
            }
            
            if(!projectDeposited)
            {
               insert(bill);
            }*/

@isTest

public class testCreateBillingOnDeposit{
    static testMethod void testCreateBilling(){
    
    // create user and profile 
   Map<String,ID> profiles = new Map<String,ID>();
         List<Profile> ps = [select id, name from Profile where name = 'System Administrator' or name = 'Standard User'];
      for(Profile p : ps){
         profiles.put(p.name, p.id);
      }

    User standard = new User(alias = 'standard',email='standarduser1@testorg.com',emailencodingkey='UTF-8',lastname='Testing', languagelocalekey='en_US',
      localesidkey='en_US',
      profileId = profiles.get('Standard User'),
      timezonesidkey='America/Los_Angeles',
      username='standarduserTest1@testorg.com');
      insert standard;
  
    System.debug('standard..........'+standard);
    
    // create resource
    Appirio_PSAe__Resource__c newResourse = new  Appirio_PSAe__Resource__c();
    newResourse.Name = 'testResource';
    newResourse.Appirio_PSAe__Start_Date__c = System.Today();
    newResourse.Appirio_PSAe__Salesforce_User__c =  standard.Id;
    insert newResourse;
    
    // create account
    Account a1 = new Account();
    a1.Client_Requires_a_Purchase_Order__c = 'No';
    a1.Industry = 'Education';
    a1.name = 'James Miller';
    insert(a1);
    
    // create oOpportunity
    Opportunity opp = new Opportunity();
    opp.Name = 'testOpp';
    opp.CloseDate = System.Today()+7;
    opp.StageName = 'Qualification';
    opp.ForecastCategoryName = 'Pipeline';
    opp.Deposit_Amount__c = 2;
    opp.Total_number_users__c = 2;
    insert opp;
    
    // create project
    
    Appirio_PSAe__Proj__c projObj = new Appirio_PSAe__Proj__c();
    projObj.Name = 'testProject';
    projObj.Appirio_PSAe__Project_Stage__c = 'Completed';
    projObj.Appirio_PSAe__Project_Mgr__c = newResourse.Id;
    projObj.Appirio_PSAe__Opportunity__c = opp.Id;
    projObj.Appirio_PSAe__Type__c = 'Internal Investment';
    projObj.Appirio_PSAe__Project_Mgr__c = newResourse.Id;
    projObj.Appirio_PSAe__Account__c = a1.Id;
    insert projObj;
    
    // for update opp trigger
    opp.Deposit_Amount__c = 3;
    update opp;
        
    }
}