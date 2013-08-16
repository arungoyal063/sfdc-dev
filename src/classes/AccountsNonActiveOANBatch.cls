/**
*********************************************************************************************************************
* Module Name   :  AccountsNonActiveOANBatch
* Description   :  Emails    
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      07/23/2013     Milligan         1443             Initial Version
*     
*  
*  
*******************************************************************************************************************
**/
global class AccountsNonActiveOANBatch  implements Database.Batchable<sObject>, Database.Stateful{
    global String query = '';  
    
    global  Database.Querylocator start(Database.BatchableContext bc) {
    	
    query= 'SELECT id, name, (Select Product__c, Agreement_Status__c From Agreements__r where agreement_status__c <>'  + '\'' + 'Active' + '\'' + ' AND product__c <> ' + '\'' + 'OAN' + '\'' + ') , (SELECT UserId, TeamMemberRole, CreatedDate, AccountId, User.Email, User.id, Account.Name FROM AccountTeamMembers WHERE TeamMemberRole = '   + '\'' + 'Client Account Manager' + '\'' + ') FROM Account';

        
        System.debug('AccountsNonActiveOANBatch Query --->' + query);
        
        return Database.getQueryLocator(query);    	
    }    
    
    global void execute(Database.BatchableContext BC, List<Account> acctList){
    	
    	System.debug('Account List Size --> ' + acctList.Size());
    	
    	for(Account a: acctList){
    		
    		List<Agreements__c> arList = new List<Agreements__c>();
    		arList = a.Agreements__r;
    		
    		List<AccountTeamMember> atm = new List<AccountTeamMember>();
    		atm = a.AccountTeamMembers;
    		
    		System.debug('Account -->' + a.name + ' Num of Agreements -- ' + arList.size() + ' Account Team Members -->' + atm.size());
    		
    		if(!atm.IsEmpty()){
    			
    			// Get email address
    			AccountTeamMember am = atm.get(0);
    			System.debug('Account Email address --> ' + am.User.Email);
    			
    		}
    		
    	}
    }

    
   global void finish(Database.BatchableContext BC){
   	
   }
    
    

}