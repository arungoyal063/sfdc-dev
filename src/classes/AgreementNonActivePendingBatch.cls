/**
*********************************************************************************************************************
* Module Name   :  AgreementNonActivePendingBatch
* Description   :       
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    
* Test Class    :  
* Fields        : Opportunity.Name, Account ID, Opportunity ID
* Logic         : Agreement Status = 'Pending Approval', Agreement.Opportunity.Stage = "CLOSED - WON"
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      07/24/2013     Milligan         1443             Initial Version
*   this email will be sent out to contracts@4centurion.com when Agreement.Status = "Pending Approval", 
* Agreement.Opportunity.Stage = "CLOSED - WON", and the Account associated with that 
* Agreement does not currently have any other associated Agreements where Status = "Active"
*******************************************************************************************************************
**/
global class AgreementNonActivePendingBatch  implements Database.Batchable<sObject>, Database.Stateful{
    global String query = '';  
    
    global  Database.Querylocator start(Database.BatchableContext bc) {
    	
    	query= '';
    	
        System.debug('AgreementNonActivePendingBatch Query --->' + query);
        
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