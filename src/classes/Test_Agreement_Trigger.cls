/**
*********************************************************************************************************************
* Module Name   :  Test_Agreement_Trigger
* Description   :  
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date        	  Author      	   WO#         Description of Action
* 1.0      30/07/2013     Algo         	  1446      		Initial Version
*   
*******************************************************************************************************************
**/
@isTest
private class Test_Agreement_Trigger {

    static testMethod void myUnitTest() {
        Account acct = new Account();
		acct.Name = 'Acme';		
		insert acct;
		
		User temp = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
                
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acct.Id;
        atm.UserId = temp.id;
        atm.TeamMemberRole = 'Client Account Manager';
        insert atm;
		
		Agreements__c ag1 = new Agreements__c();
		ag1.Account_Name__c = acct.Id;
		ag1.Subscription_Start_Date__c = System.today() - 30;
		ag1.closed_on__c = System.today() - 30;		
		ag1.Subscription_Type__c = '1 Year';
		ag1.Annual_Value__c = 2000;
		ag1.Final_Subscription_Value__c = 2000;
		ag1.Price_List_Item__c	= '5000';
		ag1.Agreement_Status__c = 'Pending Renewal';		
		ag1.Subscription_End_Date__c =  System.today();
		insert ag1;
		
		ag1.Agreement_Status__c = 'Active';		
		ag1.Renewal__c = 'No';
		update ag1;
    }
    
    static testMethod void myUnitTest1() {
        Account acct = new Account();
		acct.Name = 'Acme';		
		insert acct;
		
		User temp = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];		
                
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acct.Id;
        atm.UserId = temp.id;
        atm.TeamMemberRole = 'Client Account Manager';
        insert atm;
		
		Agreements__c ag1 = new Agreements__c();
		ag1.Account_Name__c = acct.Id;
		ag1.Subscription_Start_Date__c = System.today() - 30;
		ag1.closed_on__c = System.today() - 30;		
		ag1.Subscription_Type__c = '1 Year';
		ag1.Annual_Value__c = 2000;
		ag1.Final_Subscription_Value__c = 2000;
		ag1.Price_List_Item__c	= '5000';
		ag1.Renewal__c = 'No';	
		ag1.Agreement_Status__c = 'Active';		
		ag1.Subscription_End_Date__c =  System.today();
		insert ag1;		
    }
}