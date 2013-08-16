/**
*********************************************************************************************************************
* Module Name   : Agreement_Trigger 
* Description   : This trigger is used for WorkOrder#1446 
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :    
* Test Class    : Test_Agreement_Trigger
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      07/30/2013      Algo         1446             Initial Version
*   
*******************************************************************************************************************
**/
trigger Agreement_Trigger on Agreements__c (after insert, after update) {
	system.debug('<<<<<<<<<<<<<<in trigger');
	List<Id> accIdList = new List<Id>();
	List<Account> accObjList = new List<Account>();
	List<Task> taskInsertList = new List<Task>();
	for(agreements__c agreementObj: trigger.new)
	{
		system.debug('<<<<<<<<<<<<<<Trigger.isInsert' + Trigger.isInsert +   '###############agreementObj.agreement_status__c' + agreementObj.agreement_status__c);
		if(Trigger.isInsert && agreementObj.agreement_status__c == 'Active'){
			system.debug('<<<<<<<<<<<<<<in insert');
			accIdList.add(agreementObj.Account_Name__c);
		}
		
		if(Trigger.isUpdate){
			agreements__c oldAgreementObj = trigger.oldMap.get(agreementObj.Id);
			if(oldAgreementObj != null && oldAgreementObj.agreement_status__c != agreementObj.agreement_status__c && agreementObj.agreement_status__c == 'Active'){
				accIdList.add(agreementObj.Account_Name__c);
			}
		}
	}
	system.debug('<<<<<<<<<<<<<<accIdList' + accIdList);
	/*List<User> userList = [SELECT Id, UserRole.Name FROM User WHERE UserRole.Name = 'Client Account Manager'];
	Map<Id, String> userIdVsUserRoleMap = new Map<Id, String>();
	for(User userObj: userList){
		userIdVsUserRoleMap.put(userObj.Id, userObj.UserRole.Name);
	}*/
	
	accObjList = [SELECT Id, Name, (SELECT Id FROM agreements__r WHERE agreement_status__C = 'Active'), (SELECT Id, UserId, TeamMemberRole FROM AccountTeamMembers) FROM account WHERE id In :accIdList];
	system.debug('<<<<<<<<<<<<<<accObjList' + accObjList);
	for(Account accObj: accObjList)
	{	
		system.debug('<<<<<<<<<<<<<<accObj.agreements__r.size()' + accObj.agreements__r.size());	
		if(accObj.agreements__r.size() == 1)
		{
			task t = new task();
			t.subject = 'Initial Outreach and Setup';
			t.activitydate = date.today();
			t.priority = '**HOT**';
			t.WhatId = accObj.Id;
			for(AccountTeamMember accountTeamMembersObj: accObj.AccountTeamMembers){
				if(accountTeamMembersObj.TeamMemberRole != null && accountTeamMembersObj.TeamMemberRole == 'Client Account Manager'){
					t.OwnerId = accountTeamMembersObj.UserId;	
					break;
				}				
				/*if(userIdVsUserRoleMap.get(accountTeamMembersObj.UserId) != null){
					t.OwnerId = accountTeamMembersObj.UserId;	
					break;
				}*/
			}			
			taskInsertList.add(t);
		}			 
	}
	
	system.debug('<<<<<<<<<<<<<<taskInsertList' + taskInsertList);
	if(!taskInsertList.isEmpty()){
		try{
			insert taskInsertList;
			system.debug('<<<<<'+ taskInsertList);
		}catch(DMLException e) {
		    Trigger.new[0].addError(e.getDMLMessage(0));    
		} catch(Exception e) {
		    Trigger.new[0].addError(e.getMessage());
		}
	}
}