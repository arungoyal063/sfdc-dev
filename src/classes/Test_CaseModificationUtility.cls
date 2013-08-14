/*********************************************************************************************************************
* Module Name   :  Test_CaseModificationUtility Test Class
* Description   :  This Controller is used to update Last Updated By and Last Updated fields on Case object
* Throws        :  <Any Exceptions/messages thrown by this class/triggers>
* Calls         :  <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  <Included in the Class>
* 
* Organization  :  Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      08/12/2013      Algo          Ellucian    Initial Version
*******************************************************************************************************************/
@isTest(seeAllData=True)
private class Test_CaseModificationUtility {

    static testMethod void caseMdoifyUnitTest() {
        try {
            Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');       
            Set<String> idSet = new Set<String>();
            idSet.add(c.Id);
            CaseModificationUtility.updateCaseModificationActivity(idSet,UserInfo.getUserId(),DateTime.now());
            CaseModificationUtility.updateCaseModificationActivity(idSet,'Test',DateTime.now());
            CaseModificationUtility.updateCaseModificationActivity(new Set<String>{'Test'},'Test',DateTime.now());            
        } catch(Exception e) {
            System.debug('Error >>' + e);
        }
    }
    
    static testMethod void caseMdoifyUnitTest1() {
        try {            
            CaseModificationUtility.updateCaseModificationActivity(null,UserInfo.getUserId(),DateTime.now());
        } catch(Exception e) {
            System.debug('Error >>' + e);
        }
    }
    
     static testMethod void caseMdoifyCRUnitTest() {
        try {
            Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');       
            Set<String> idSet = new Set<String>();
            idSet.add(c.Id);
            CaseModificationUtility.modifyCaseFromCR(idSet, UserInfo.getUserId(), DateTime.now());
            CaseModificationUtility.modifyCaseFromCR(idSet, 'Test', DateTime.now());
            CaseModificationUtility.modifyCaseFromCR(new Set<String>{'Test'},'Test', DateTime.now());            
        } catch(Exception e) {
            System.debug('Error >>' + e);
        }
    }
    
    static testMethod void caseMdoifyCRUnitTest1() {
        try {
            CaseModificationUtility.modifyCaseFromCR(null, UserInfo.getUserId(), DateTime.now());
                       
        } catch(Exception e) {
            System.debug('Error >>' + e);
        }
    }
    
    static testMethod void unittestMethod1() {
    		//CaseMilestone cm = new CaseMilestone(CaseId = );
        	Case c1 = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');
        	Case c2 = MockTestData.createCaseRecord('New', 'Web', 'Level 3', 'Test','Test');
        	//cm.CaseId = c1;
        	Account a1 = MockTestData.createAccountRecord('Acc1', 100);
        	Account a2 = MockTestData.createAccountRecord('Acc2', 100);
            Set<ID> idSet = new Set<ID>();
            Set<String> idSet1 = new Set<String>();
            idSet.add(a1.Id);
            idSet.add(a2.Id);
            idSet1.add(a1.Id);
            idSet1.add(a2.Id);
            CaseModificationUtility.modifyCaseFromCR(idSet1, 'Test', DateTime.now());
            CaseModificationUtility.completeCaseMilestones(idSet);
            CaseModificationUtility.retPriorityComment(c1.ID);
    }
    
    
    static testmethod void testmethod1(){
    	Case c1 = MockTestData.createCaseRecord('New', 'Phone', 'Level 1', 'Test1', 'Test12');
    	Set<ID> idset = new Set<ID>();
    	idset.add(c1.id);
    	CaseComment cc = MockTestData.createCaseCommentRecord(c1.id, 'hello abc');
		  Boolean b =  CaseModificationUtility.updateCaseModificationActivity(new Set<String>{''+c1.id},UserInfo.getUserId(),DateTime.now());
		  Boolean ba =  CaseModificationUtility.modifyCaseFromCR(new Set<String>{c1.id},UserInfo.getUserId(),DateTime.now());
		  CaseModificationUtility.completeCaseMilestones(idset);
		  CaseModificationUtility.retPriorityComment(c1.id);
    }
    
    static testmethod void testmethod2(){
    	Set<ID> idset = new Set<ID>();
    	list<CaseMilestone> cmList = [SELECT CaseMilestone.Id,  CaseMilestone.CaseId,  CaseMilestone.CompletionDate  FROM CaseMilestone WHERE CaseMilestone.CaseId != null AND CompletionDate != null AND Case.Completion_Date__c = null Limit 5];
    	for(CaseMilestone cmObj: cmList){
    		idset.add(cmObj.CaseId);
    	}		
		CaseModificationUtility.completeCaseMilestones(idset);
    }
}