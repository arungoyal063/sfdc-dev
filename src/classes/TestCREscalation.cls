/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<TestCREscalation>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<22-11-2012>>
// Last Modified Date.....: <<11-12-2012>>
// Description/Requirement: <<Test Class for CREscalation Trigger>>
//---------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class TestCREscalation{
	
	 static testMethod void CRTriggerUnitTest() {        
       Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');  // Case Created 
       Change_Request__c cr2 = MockTestData.createCRRecordByPrimaryCR('Test2',NULL, c.Id);   // Change Request Created 
       Change_Request__c cr = MockTestData.createCRRecordByPrimaryCR('Test', cr2.Id, c.Id);  // Change Request Created       
       Idea idea = MockTestData.createIdeaRecord('Test', 'Test', cr.Id);                     // Idea Created
       //Releases__c rl = MockTestData.createReleaseRecord('Test');                            // Release Created
       //Project__c pr =  MockTestData.createProjectRecord('Test',rl.Id);                      // Project Created
       Change_Request__c crIdeaobj = MockTestData.createCRRecordByIdea('Test', idea.Id);     // Change Request with Idea Created 
       
       c.Status = 'Change Request Open';
       c.Sub_Status__c = 'Defect';
       c.Reason = 'Client Solved';
       update c;
       
       Associated_Case_Change_Request__c accr = MockTestData.createAssociatedCaseCRRecord(c.id, cr.Id); // Associated Case Change Request Created
              
       TriggerRunOnce.run = true;
       cr.Status__c = 'Cancelled';
       update cr;
       
       //cr.status__C='Complete';
       //cr.patch__c=true;
       
       //cr.Status__c = 'Cancelled';    
       //update cr;
       
       //cr2.Originating_Case__c = c.Id;
       //cr2.Status__c = 'Cancelled';
       //cr2.Sub_Status__c = 'Not a Defect';        
       //update cr2;  
       
       //Change_Request__c cre = MockTestData.createCRRecord('Test');   
       //cre.Originating_Case__c = c.Id;
       //cre.Status__c = 'Cancelled';
       //cre.Sub_Status__c = 'Not a Defect';     
       //update cre;       
       
       //Change_Request__c crProject = MockTestData.createCRRecordByProject('Test',pr.Id);
    }  
	
    /*static testMethod void CRTriggerUnitTest() {        
       Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');  // Case Created
       c.status='Change Request Open';
       c.sub_status__c='Working with team';
       c.reason='Client Solved';
       update c; 
       Change_Request__c cr2 = MockTestData.createCRRecordByPrimaryCR('Test2',NULL, c.Id);   // Change Request Created 
       Change_Request__c cr = MockTestData.createCRRecordByPrimaryCR('Test', cr2.Id, c.Id);  // Change Request Created       
       Idea idea = MockTestData.createIdeaRecord('Test', 'Test', cr.Id);                     // Idea Created
       //Releases__c rl = MockTestData.createReleaseRecord('Test');                            // Release Created
       //Project__c pr =  MockTestData.createProjectRecord('Test',rl.Id);                      // Project Created
       
       Change_Request__c crIdeaobj = MockTestData.createCRRecordByIdea('Test', idea.Id);    // Change Request with Idea Created 
       
       
       Change_Request__c crobj = MockTestData.createCRRecord('Test');    // Change Request with Idea Created 
       crobj.status__C='Complete';
       crobj.patch__c=true;
       update crobj;
              
       Associated_Case_Change_Request__c accr = MockTestData.createAssociatedCaseCRRecord(c.id, crobj.Id); // Associated Case Change Request Created
       update accr;
       
       Change_Request__c cr1 = MockTestData.createCRRecordByPrimaryCR('Test', cr2.Id, c.Id);
       cr1.status__C='Complete';
       cr1.patch__c=true;
       update cr1; 
               
       Associated_Case_Change_Request__c accr = MockTestData.createAssociatedCaseCRRecord(c.id, cr1.Id); // Associated Case Change Request Created
       update accr;      
       
       //TriggerRunOnce.run = true;
       //cr.Originating_Case__c = c.Id;
      // cr.Status__c = 'Cancelled';
       //update cr;
       
       //cr.Status__c = 'Cancelled';    
       //update cr;
       
       //cr2.Originating_Case__c = c.Id;
       //cr2.Status__c = 'Cancelled';
       //cr2.Sub_Status__c = 'Not a Defect';        
       //update cr2;  
       
       //Change_Request__c cre = MockTestData.createCRRecord('Test');   
       //cre.Originating_Case__c = c.Id;
       //cre.Status__c = 'Cancelled';
       //cre.Sub_Status__c = 'Not a Defect';     
       //update cre;       
       
       //Change_Request__c crProject = MockTestData.createCRRecordByProject('Test',pr.Id);
    }*/   
    /*static testMethod void CREscalationUnitTest() { 
        Change_Request__c cr = [SELECT Id FROM Change_Request__c WHERE Originating_Case__c != NULL LIMIT 1];
        Case c = [SELECT Id FROM Case LIMIT 1];
        cr.Originating_Case__c = c.Id;
        update cr;
    }*/
}