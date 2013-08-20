@istest(seeAlldata=true)
private class TestStopPartnerConnectionSharing {
    static testMethod void StopPartnerConnection_UnitTest() {
        try {
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
         username='standarduserTest@testorg.com');
         insert standard;
    
        // set up resource
        Appirio_PSAe__Resource__c newResourse = new  Appirio_PSAe__Resource__c();
        newResourse.Name = 'testResource';
        newResourse.Appirio_PSAe__Start_Date__c = System.Today();
        newResourse.Appirio_PSAe__Salesforce_User__c =  standard.Id;
        insert newResourse;
    
        // set up account
        Account a1 = new Account();
        a1.Client_Requires_a_Purchase_Order__c = 'No';
        a1.Industry = 'Education';
        a1.name = 'James Miller';
        insert(a1);
        
        // create Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.CloseDate = System.Today()+7;
        opp.StageName = 'Qualification';
        opp.ForecastCategoryName = 'Pipeline';
        opp.Deposit_Amount__c = 2;
        opp.Total_number_users__c = 2;
        insert opp;
    
        Appirio_PSAe__Proj__c projObj = [Select id from Appirio_PSAe__Proj__c where Appirio_PSAe__Project_Stage__c  = 'In Progress' limit 1];
        
       
        if(projObj == null) {
            // set up project
            projObj = new Appirio_PSAe__Proj__c();
            projObj.Name = 'testProject';
            projObj.Appirio_PSAe__Project_Stage__c = 'In Progress';
            projObj.Appirio_PSAe__Project_Mgr__c = newResourse.Id;
            projObj.Appirio_PSAe__Opportunity__c = opp.Id;
            projObj.Appirio_PSAe__Type__c = 'Internal Investment';
            projObj.Appirio_PSAe__Project_Mgr__c = newResourse.Id;
            projObj.Appirio_PSAe__Account__c = a1.Id;
            insert projObj;
        }
        
        List<RecordType> rtypeList = [Select Id from RecordType where Name='Customer Request' and SobjectType='Case'];
        //setup Case
        Case case1 = new Case();
        case1.Type = 'Problem';
        case1.Reason = 'Trigger';
        case1.Origin = 'Email'; 
        case1.status = 'In Progress';
        case1.RecordTypeId = rtypeList.get(0).Id; 
        case1.Project__c = projObj.Id;       
        insert case1; 
        
       case1.status = 'closed';
       update case1; 
       
        List<PartnerNetworkConnection> partnerConnection = new List<PartnerNetworkConnection>();
        partnerConnection = [select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection
                where ConnectionStatus = 'Accepted' Limit 1];
        
  
       //set up org sharing record
       PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
       newrecord.ConnectionId = partnerConnection.get(0).Id;
       newrecord.LocalRecordId = case1.Id;  
       newrecord.SendClosedTasks = true;
       newrecord.SendOpenTasks = true;
       newrecord.SendEmails = false;  
       insert newrecord; 
       
       case1.status = 'closed';
       update case1; 
         
       } catch(Exception e) {
           System.debug(e);
      }
    }
}