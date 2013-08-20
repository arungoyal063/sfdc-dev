@isTest
Public class checkDuplicatePrimaryLogin_Test
{
    Static TestMethod void TestMethod_One()
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
        try{
        insert logObj;
        }Catch(exception e){}
        
        Login__c logObj1 = new Login__c();
        logObj1.Name = 'TestLog1';
        logObj1.Account__c = Acc.id;
        logObj1.Primary_Login__c = true;
        logObj1.Sandbox_Login__c = true;
         try{
        insert logObj1;
        }Catch(exception e){}
        
        Login__c logObj2 = new Login__c();
        logObj2.Name = 'TestLog1';
        logObj2.Account__c = Acc.id;
        logObj2.Primary_Login__c = true;     
        logObj2.Sandbox_Login__c = false;    
        try{
        insert logObj2;
        }Catch(exception e){}
        
        Login__c logObj3 = new Login__c();
        logObj3.Name = 'TestLog1';
        logObj3.Account__c = Acc.id;
        logObj3.Primary_Login__c = true;     
        logObj3.Sandbox_Login__c = false;    
        try{
        insert logObj3;
        }Catch(exception e){}
        
        
        
    }
}