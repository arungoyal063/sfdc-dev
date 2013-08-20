public with sharing class Util {
    
    
public static User createUser() {
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
      return standard;
    }
    

public static Appirio_PSAe__Resource__c createResource(String UserID) {
    Appirio_PSAe__Resource__c newResourse = new  Appirio_PSAe__Resource__c();
    newResourse.Name = 'testResource';
    newResourse.Appirio_PSAe__Start_Date__c = System.Today();
    newResourse.Appirio_PSAe__Salesforce_User__c =  UserID;
    insert newResourse;
    return newResourse;
    }

public static Account createAccount() {
    // create account
    Account a1 = new Account();
    a1.Client_Requires_a_Purchase_Order__c = 'No';
    a1.Industry = 'Education';
    a1.name = 'James Miller';
    insert(a1);
    return a1;
    }   

public static Opportunity createOpportunity(String AcocuntID) {
     // create oOpportunity
    Opportunity opp = new Opportunity();
    
    opp.AccountId = AcocuntID;  
    opp.Name = 'testOpp';
    opp.CloseDate = System.Today()+7;
    opp.StageName = 'Qualification';
    opp.ForecastCategoryName = 'Pipeline';
    opp.Deposit_Amount__c = 20000;
    opp.Total_number_users__c = 2;
    insert opp;
    return opp;
    
    }
    
    public static Appirio_PSAe__Proj__c createProject(string resourceID,String OppID,String AccountID) {
     
    Appirio_PSAe__Proj__c projObj = new Appirio_PSAe__Proj__c();
    projObj.Name = 'testProject';
    projObj.Appirio_PSAe__Project_Stage__c = 'Completed';
    projObj.Appirio_PSAe__Project_Mgr__c = resourceID;
    projObj.Appirio_PSAe__Opportunity__c = OppID;
    projObj.Appirio_PSAe__Project_Stage__c = 'In Progress';
    projObj.Appirio_PSAe__Type__c = 'Internal Investment';
    projObj.Appirio_PSAe__Project_Mgr__c = resourceID;
    projObj.Rate__c = 12.2;
    projObj.Appirio_PSAe__Account__c = AccountID;
    projObj.Appirio_PSAe__Hours_Allocated__c = 200;
    insert projObj;
    return projObj;
    
    }
    public static Appirio_PSAe__Proj__c createProjectChild(string resourceID,String OppID,String AccountID,String ParentID) {
     
    Appirio_PSAe__Proj__c projObj = new Appirio_PSAe__Proj__c();
    projObj.Parent_Project__c = ParentID;
    projObj.Name = 'testProject';
    projObj.Appirio_PSAe__Project_Stage__c = 'Completed';
    projObj.Appirio_PSAe__Project_Mgr__c = resourceID;
    projObj.Appirio_PSAe__Opportunity__c = OppID;
    projObj.Appirio_PSAe__Project_Stage__c = 'In Progress';
    projObj.Appirio_PSAe__Type__c = 'Internal Investment';
    projObj.Appirio_PSAe__Project_Mgr__c = resourceID;
    projObj.Appirio_PSAe__Account__c = AccountID;
    projObj.Appirio_PSAe__Hours_Allocated__c = 200;
    insert projObj;
    return projObj;
    
    }

public static Appirio_PSAe__Assignment__c createAssignment(string resourceID,String ProjectID) {
     
    Appirio_PSAe__Assignment__c assignObj = new Appirio_PSAe__Assignment__c();
     assignObj.Appirio_PSAe__Projects__c  = ProjectID;
    assignObj.Appirio_PSAe__Resource__c  = resourceID;
    assignObj.Appirio_PSAe__Description__c = 'test porj';
    assignObj.Appirio_PSAe__Status__c = 'Tentative';
    assignObj.Appirio_PSAe__Start_Date__c = System.today();
    assignObj.Appirio_PSAe__End_Date__c  = System.today().addDays(30);
    assignObj.Appirio_PSAe__Total_Assignment_Hours__c = 50; 
    
    insert assignObj;
    return assignObj;
    
    }
    
        
public static Appirio_PSAe__Timecard__c createTimeCard(string resourceID,String ProjectID,string AssignID) {
     
    Appirio_PSAe__Timecard__c timeObj = new Appirio_PSAe__Timecard__c();
    timeObj.Appirio_PSAe__SFDC_Projects__c  = ProjectID;
    timeObj.Appirio_PSAe__SFDC_Resource__c =  resourceID;
    timeObj.Appirio_PSAe__Assignment__c =  AssignID;
    timeObj.Appirio_PSAe__Sun__c = 12;
    timeObj.Appirio_PSAe__Notes_Sun__c = 'test';
    Date myDate =  date.newinstance(2013, 02, 23);
    timeObj.Appirio_PSAe__Week_Ending__c = myDate;
    insert timeObj;
    return timeObj;
    
    
    
    }
    
    public static Billing_Line_Item__c createBillLineItem(String ProjectID) {
     
    Billing_Line_Item__c billObj = new Billing_Line_Item__c();
    billObj.Project__c =  ProjectID;
    billObj.Invoiced__c =  'Invoiced';
    billObj.Rate_per_Hour__c = 1;
    billObj.Notes__c =  'Test Notes';
    insert billObj;
    return billObj;
    
    }
    
    //This method will be used by the Milestone1TaskTrigger to send the email
    public static void sendEmail(String emailSubject, String emailBody, String[] toaddress){
    	try{
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(toaddress);
			mail.setsubject(emailSubject);
			mail.setPlainTextBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}
		catch(Exception e){			
			System.debug('Error in sending email'+e.getMessage());
		}
		    
    }
}