/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<MockTestData>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<22-11-2012>>
// Last Modified Date.....: <<22-11-2012>>
// Description/Requirement: <<TestData Class for Test Classes>>
//---------------------------------------------------------------------------------------------------------------------------*/
public class MockTestData {
    
    
    /* Create New Product Record */
    public static Product2 createProductRecord(String nameProduct) {        
        Product2 pro = new Product2(Name = nameProduct, Family='Software');
        try {
            pro.Is_Case_Supported__c = true;
            pro.Is_Change_Request_Supported__c = true;
            insert pro;
        } catch(Exception e) { System.debug('Error :' + e);}
        return pro;
    }
    
    /* Create New Case Record */
    public static Case createCaseRecord(String caseStatus, String caseOrigin, String casePriority, String pr_stmnt, String summary) {  
        Case c = new Case(Status = caseStatus, Origin = caseOrigin, Priority = casePriority, Problem_Statement__c = pr_stmnt, Resolution_Summary__c = summary);
        try {
        	c.Subject = 'Test';        	
            insert c;
        } catch(Exception e) { System.debug('Error :' + e);}
        return c;
    }
        
    /* Create New Change Request Record */
    public static Change_Request__c createCRRecord(String description) {
        Change_Request__c cr = new Change_Request__c(Description__c = description);
        try {        	
            insert cr;
        } catch(Exception e) {
            System.debug('Error :' + e);
        }       
        return cr;   
    }
    
      /* Create New Change Request Record with Originating Idea*/
    public static Change_Request__c createCRRecordByIdea(String description, String ideaId) {
        Change_Request__c cr = new Change_Request__c(Description__c = description);
        try {
            if(ideaId != null) {
                cr.Originating_Idea__c = ideaId;
            }
            insert cr;
        } catch(Exception e) {
            System.debug('Error :' + e);
        }       
        return cr;   
    }
    
    /* Create New Change Request Record with Primary Change Request */
    public static Change_Request__c createCRRecordByPrimaryCR(String description, String primaryCRId, String caseId) {
        Change_Request__c cr;
        try {
            cr = new Change_Request__c(Description__c = description); 
            cr.Summary__c = 'Test Summary';  
            if(caseId != NULL) {
                cr.Originating_Case__c = caseId;
            } 
            if(primaryCRId != NULL) {
                cr.Primary_Change_Request__c = primaryCRId;
            }    
            insert cr;
        } catch(Exception e) {
            System.debug('Error :' + e);
        }       
        return cr;   
    }
    
    /* Create New Change Request Record with Primary Change Request */
    public static Change_Request__c createCRRecordByPrimaryCRWithStatus(String description, String primaryCRId, String caseId, String Status) {
        Change_Request__c cr;
        try {
            cr = new Change_Request__c(Description__c = description, Status__c = Status); 
            cr.Summary__c = 'Test Summary';  
            if(caseId != NULL) {
                cr.Originating_Case__c = caseId;
            } 
            if(primaryCRId != NULL) {
                cr.Primary_Change_Request__c = primaryCRId;
            }    
            insert cr;
        } catch(Exception e) {
            System.debug('Error :' + e);
        }       
        return cr;   
    }
    
    /* Create New Change Request Record with Project Lookup */
    public static Change_Request__c createCRRecordByProject(String description, String projectId) {
        Change_Request__c cr = new Change_Request__c(Description__c = description);
        try {
            cr.Project__c = projectId;
            insert cr;
        } catch(Exception e) {
            System.debug('Error :' + e);
        }       
        return cr;   
    }
    
    /* Create New Account Record */
    public static Account createAccountRecord(String accName, Integer billMinutes) {
        Account a = new Account(Name = accName,Billable_Minutes__c = billMinutes);
        try {
            insert a;
        } catch(Exception e) {System.debug('Error :' + e);} 
        return a;
    }  
    
    /* Create New Contact Record */
    public static Contact createContactRecord(String contactName, String accId) {
        Contact con = new Contact(LastName = contactName);
        try {
            con.AccountId = accId;
            con.Inactive__c = false;
            insert con;
        } catch(Exception e) {System.debug('Error :' + e);} 
        return con;
    }    
    
    /* Create New Task Record */
    public static Task createTaskRecord(String parentId) {
         Task newTask = new Task(Subject = 'Email:',
                                 Status = 'In Progress',
                                 Priority = 'Normal',
                                 WhatId = parentId,
                                 ActivityDate = Date.today(),
                                 Billable_Minutes__c = 100,
                                 Description = 'Test' 
                                 );
         try {                        
             insert newTask;
         } catch(Exception e) {
             System.debug('Error :' + e);
         }                          
         return newTask;
    }
    
    /* Create New Non Billable Task Record */
    public static Task createNonBillTaskRecord(String parentId) {
         Task newTask = new Task(Subject = 'Email:',
                                 Status = 'In Progress',
                                 Priority = 'Normal',
                                 WhatId = parentId,
                                 ActivityDate = Date.today(),                                
                                 Description = 'Test' 
                                 );
         try {                        
             insert newTask;
         } catch(Exception e) {
             System.debug('Error :' + e);
         }                          
         return newTask;
    }
    
    /* Create New Event Record */
    public static Event createEventRecord(String parentId) {
         Event et = new Event(Subject = 'Call',                            
                             StartDateTime = Date.today(),
                             EndDateTime = Date.today(),
                             WhatId = parentId,
                             ActivityDate = Date.today(),
                             Billable_Minutes__c = 100,
                             Description = 'Test' 
                             );
        try {                        
             insert et;
             } catch(Exception e) {
             System.debug('Error :' + e);
         }                          
         return et;
    }
    
    /* Create New Licensed Product Record */
    public static Licensed_Product__c createLPRecord(String lpName, Account a){
        //insert a;
        Licensed_Product__c lp = new Licensed_Product__c(Name = lpName, Account__c = a.Id);
        //try {
            insert lp;
            return lp;
       // } catch(Exception e) {
            //System.debug('Error :' + e);
       // }
       // return lp;
    }
    
    /* Create New Entitlement Record */
    public static Entitlement createEntlmntRecord(String enName, Account a) {       
        Entitlement  en = new Entitlement(Name = enName, AccountId = a.Id); 
        try {
            insert en;
        } catch(Exception e) { System.debug('Error :' + e); }
        return en;
    }
    
    /* Create New Idea Record with Change Request lookup */
    public static Idea  createIdeaRecord(String title, String bussPrps, String crId) {
       Idea idea;
       try {
           Community community = [ SELECT Id FROM Community limit 1];     
           idea = new Idea(Title = title, Change_Request__c = crId, Business_Purpose__c = bussPrps, CommunityId = community.Id);
           insert idea;           
        } catch(Exception e) { System.debug('Error :' + e); }
           return idea;
    }
    
    /* Create New Idea Record with Case lookup */
    public static Idea createIdeaRecordByCase(String title, String bussPrps, String caseId) {
         Idea idea;
         try {
           Community community = [ SELECT Id FROM Community limit 1];     
           idea = new Idea(Title = title, Case__c = caseId, Business_Purpose__c = bussPrps, CommunityId = community.Id);
           insert idea;           
         } catch(Exception e) { System.debug('Error :' + e); }
           return idea;
    }
    
    /* Create New Related Case Record */
    public static Case_to_case_junction_object__c createRelatedCaseRecord(String orgCaseId, String relCaseId) {
        Case_to_case_junction_object__c ccObj = new Case_to_case_junction_object__c();
        try {
            ccObj.OriginatingCase__c = orgCaseId;
            ccObj.Related_Case__c = relCaseId;        
            insert ccObj;
        }catch(Exception e) { System.debug('Error :' + e); }
        return ccObj;
    }
    
    /* Create New Associated Case Change Request Record */
    public static Associated_Case_Change_Request__c createAssociatedCaseCRRecord(String caseId, String CRId) {
        Associated_Case_Change_Request__c accr = new Associated_Case_Change_Request__c();
        try {
            accr.Case__c = caseId;
            accr.Change_Request__c = CRId;        
            insert accr;
        }catch(Exception e) { System.debug('Error :' + e); }
        return accr;
    }
    
    /* Create New CaseComment Record */
    public static CaseComment createCaseCommentRecord(String caseId, String dsecText) {
        CaseComment cc = new CaseComment(IsPublished = true);
        try {
            cc.ParentId = caseId;
            cc.CommentBody = dsecText;        
            insert cc;
        }catch(Exception e) { System.debug('Error :' + e); }
        return cc;
    }
    
    /* Create New CaseComment Record */
    public static Billable_Time__c createBillableTimeRecord(String caseId) {
        Billable_Time__c bt = new Billable_Time__c();
        try {
            bt.Case__c = caseId;           
            insert bt;
        }catch(Exception e) { System.debug('Error :' + e); }
        return bt;
    }
    
 
    /* Create New Project Record */
    public static Project__c createProjectRecord(String projectName, String releaseId) {
        Project__c pr = new Project__c();
        try {
         //   pr.Release__c = releaseId;         
            insert pr;
        }catch(Exception e) { System.debug('Error :' + e); }
        return pr;
    }
    
    /* Create New Releases Record */
    public static Releases__c createReleaseRecord(String releaseName) {
        Releases__c rl = new Releases__c(name = releaseName);
        try {           
            insert rl;
        }catch(Exception e) { System.debug('Error :' + e); }
        return rl;
    }
    
    /* Create EmailMessage Record */
    public static EmailMessage createEmailMessageRecord(String caseId) {
        EmailMessage newEmail;
        Task t = createTaskRecord(caseId);
        newEmail = new EmailMessage(FromAddress = 'test@abc.org', Incoming = false, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = caseId, ActivityId = t.Id); 
        
        insert newEmail;
        return newEmail;
    }
    
    /* Create EmailMessage Record */
    public static Confidential_Attachment_and_Note__c createConfidentialAttachNoteRecord(String caseId, String siebelID) {
        Confidential_Attachment_and_Note__c con = new Confidential_Attachment_and_Note__c();
        try {
            con.Case__c = caseId;
            con.Siebel_ID__c = siebelID;
            insert con;
        }catch(Exception e) { System.debug('Error :' + e); }
        return con;
    }
    
    /* Create Product Version Record */
    public static Version__c createVersionRecord(String productId) {
        Version__c v;
        try {
            v = new Version__c(Name='Test', Product__c = productId);
            insert v;
        }catch(Exception e) { System.debug('Error :' + e); }
        return v;
    }
    
    // create portal user
    public static User getPortalUser() {
           Contact con;
           User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
          
           System.runAs (thisUser) {
                 Account a = MockTestData.createAccountRecord('Test',100);
                 con = MockTestData.createContactRecord('lastname',a.id);  
           }
          
           Profile p = [SELECT Id FROM profile WHERE name='Ellucian Communities Profile']; 
           //UserRole r = [SELECT Id FROM UserRole WHERE PortalRole='Executive' LIMIT 1];       
           // mock test user
           UserRole ur = [Select RollupDescription, Id From UserRole Where RollupDescription ='Morehouse College Customer User'];
           User pu = new User(alias = 'newUser', email='newuser@tgerm.com',
                 emailencodingkey='UTF-8', lastname='Testing', 
                 languagelocalekey='en_US', localesidkey='en_US', 
                 profileid = p.Id, contactId = con.Id,UserRole = ur, 
                 timezonesidkey='America/Los_Angeles', username='newuser@tgerm.com' + System.now().getTime());
           Database.insert(pu);
           return pu;
     }    
    
    /* Create Idea V2 Record */
  /*  public static Ideas_v2__c createIdeaV2Record(String ideaTitle) {
        Ideas_v2__c v;
        try {
            v = new Ideas_v2__c(Name='ideaTitle', Idea_Title__c = ideaTitle, Business_Purpose__c = ideaTitle);
            insert v;
        }catch(Exception e) { System.debug('Error :' + e); }
        return v;
    }*/
    
    
    static testMethod void mockUnitTest() {  
        Account a =  MockTestData.createAccountRecord('Test',100);   
        Account acc =  MockTestData.createAccountRecord(null,100);  // Test negativie scenario      
        Contact con = MockTestData.createContactRecord('Test', a.Id);
        Contact cont = MockTestData.createContactRecord('Test', 'Test');  // Test negativie scenario     
        Entitlement  en = MockTestData.createEntlmntRecord('Test',a); 
        Entitlement  ent = MockTestData.createEntlmntRecord(null,a);  // Test negativie scenario                         
        Licensed_Product__c lp = MockTestData.createLPRecord('Test',a);  
        Licensed_Product__c l = MockTestData.createLPRecord(null,a);   // Test negativie scenario     
        Case c = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', 'Test','Test');   
        Case cs = MockTestData.createCaseRecord('Closed', 'Email', 'Level 3', '','Test');
        createTaskRecord(null); // Test negativie scenario       
        createCRRecord(null);   // Test negativie scenario
        createProductRecord('test');
        createNonBillTaskRecord(null);
        Change_Request__c cr = MockTestData.createCRRecord('Test');             
        Idea idea = MockTestData.createIdeaRecord('Test','Test', cr.Id); 
        idea = MockTestData.createIdeaRecord('Test','Test','Test');          // Test negativie scenario  
        idea = MockTestData.createIdeaRecordByCase('Test','Test',cs.Id);
        idea = MockTestData.createIdeaRecordByCase('Test','Test', 'Test');   // Test negativie scenario 
        MockTestData.createRelatedCaseRecord(cs.Id, c.Id);
        MockTestData.createCaseJunctionRecord(cs.Id, c.Id); //AAded BY An
        MockTestData.createAssociatedCaseCRRecord(c.Id, cr.Id);
        MockTestData.createAssociatedCaseCRRecord(c.Id, 'Test');             // Test negativie scenario
        MockTestData.createCaseCommentRecord(c.Id,'Test');
        MockTestData.createCaseCommentRecord('Test','Test');                 // Test negativie scenario
        MockTestData.createEventRecord(c.Id);
        MockTestData.createEventRecord(null);                                // Test negativie scenario
        MockTestData.createCRRecordByPrimaryCR('Test', cr.Id, c.Id);
        MockTestData.createCRRecordByPrimaryCR('Test', 'Test', NULL);        // Test negativie scenario
        MockTestData.createBillableTimeRecord(cr.Id);
        MockTestData.createBillableTimeRecord('Test');                       // Test negativie scenario
        Releases__c rl = MockTestData.createReleaseRecord('Test');
        Project__c pr =  MockTestData.createProjectRecord('Test',rl.Id);
        Project__c prj =  MockTestData.createProjectRecord('Test','Test');    // Test negativie scenario
        Change_Request__c cre = MockTestData.createCRRecordByProject('Test',pr.Id);
        cre = MockTestData.createCRRecordByProject('Test','Test');            // Test negativie scenario
        MockTestData.createConfidentialAttachNoteRecord(c.Id,'Test');
        MockTestData.createConfidentialAttachNoteRecord('Test','Test');      // Test negativie scenario

        
    } 
    
    /* Create Case junction Object Record */
    public static Case_to_case_junction_object__c createCaseJunctionRecord (String RelatedCaseId,String AssociatedCaseId) {
        
        Case_to_case_junction_object__c c;
        try {
            c = new Case_to_case_junction_object__c(Related_Case__c = RelatedCaseId, OriginatingCase__c =AssociatedCaseId);
            insert c;
        }catch(Exception e) { System.debug('Error :' + e); }
        return c;
    }    
    
    static testMethod void mockEmailUnitTest() { 
        Case c = MockTestData.createCaseRecord('Open', 'Email', 'Level 3', 'Test','Test');
        EmailMessage newEmail = MockTestData.createEmailMessageRecord(c.Id);
        Product2 p =  MockTestData.createProductRecord('test');
        Version__c v= MockTestData.createVersionRecord(p.Id);
        Change_Request__c cr = MockTestData.createCRRecord('Test');    
        //Idea idea = MockTestData.createIdeaRecord('Test','Test', cr.Id);   
        //Change_Request__c crIdeaobj = MockTestData.createCRRecordByIdea('Test', idea.Id);
        /*Ideas_v2__c ideav2 = MockTestData.createIdeaV2Record('Test');*/
    }
    
    
    static testMethod void portalUnitTest() {
        User pu = MockTestData.getPortalUser();       
    }
    
}