@isTest(SeeAllData = True)
public class updateLogins_Test
{
    Static TestMethod Void unittest()
    {
        Account Acc= new Account();
        Acc.name = 'Test';
        Acc.Industry_Sector__c = 'Association/NFP';
        Insert Acc;
        
        Login__c logObj = new Login__c();
        logObj.Name = 'TestLog';
        logObj.Account__c = Acc.id;
        logObj.Primary_Login__c = true;
        logObj.Sandbox_Login__c = true;
        try{insert logObj;}Catch(exception e){}
        
        Case cs= new Case();
        cs.AccountId = Acc.id;
        cs.Type = 'Problem' ;
        cs.Add_On__c = 'Basic Functionality';
        cs.Status = 'new';
        try{insert cs;}Catch(exception e){}            
    }        
    Static TestMethod Void unittest1()
    {
        Account Acc= new Account();
        Acc.name = 'Test';
        Acc.Industry_Sector__c = 'Association/NFP';
        Insert Acc;
        
        Login__c logObj = new Login__c();
        logObj.Name = 'TestLog';
        logObj.Account__c = Acc.id;
        logObj.Primary_Login__c = true;
        logObj.Sandbox_Login__c = False;
        try{insert logObj;}Catch(exception e){}
        
        Case cs= new Case();
        cs.AccountId = Acc.id;
        cs.Type = 'Problem' ;
        cs.Add_On__c = 'Basic Functionality';
        cs.Status = 'new';
        try{insert cs;}Catch(exception e){}            
    }      
    Static TestMethod Void unittest2()
    {
        Account Acc= new Account();
        Acc.name = 'Test';
        Acc.Industry_Sector__c = 'Association/NFP';
        Insert Acc;
        
        Login__c logObj = new Login__c();
        logObj.Name = 'TestLog';
        logObj.Account__c = Acc.id;
        logObj.Primary_Login__c = true;
        logObj.Sandbox_Login__c = False;
        try{insert logObj;}Catch(exception e){}
        
        Case cs= new Case();
        cs.AccountId = null;
        cs.Type = 'Problem' ;
        cs.Add_On__c = 'Basic Functionality';
        cs.Status = 'new';
        try{insert cs;}Catch(exception e){}            
    }        
}