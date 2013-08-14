@isTest
private class ExtjsGridControllerTest {
   static testmethod void extjsGridController_UnitTest() {
       Test.startTest();
       ExtjsGridController extObj = new ExtjsGridController();
       extObj.init();
       extObj.checkAsyncRequest();
       extObj.MetadataFiles = new List<MetadataCreateJob.MetadataFile>(); 
       extObj.MetadataFileName = 'Case.object';
       extObj.MetadataFileData = '<?xml version="1.0" encoding="UTF-8"?>' + 
                              '<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">' +
                                '<listViews>' +  
                                '<fullName>AllOpenCases</fullName>' + 
                                '<columns>CASES.CASE_NUMBER</columns>' + 
                                '<columns>NAME</columns>' + 
                                '<columns>CASES.STATUS</columns>' + 
                                '<columns>CASES.PRIORITY</columns>' + 
                                '<columns>Product_Line__c</columns>' + 
                                '<columns>Product_Name__c</columns>' + 
                                '<columns>Module__c</columns>' + 
                                '<columns>CASES.SUBJECT</columns>' +  
                                '<columns>OK_to_Close_Case__c</columns>' + 
                                '<columns>CASES.CREATED_DATE</columns>' + 
                                '<columns>CASES.LAST_UPDATE</columns>' + 
                                '<columns>ACCOUNT.NAME</columns>' + 
                                '<filterScope>Everything</filterScope>' + 
                                '<filters>' + 
                                '<field>CASES.CLOSED</field>' + 
                                '<operation>equals</operation>' + 
                                '<value>0</value>' + 
                                '</filters>' +
                                 '<filters>' + 
                                '<field>CASE.RECORDTYPE</field>' + 
                                '<operation>equals</operation>' + 
                                '<value>Internal</value>' + 
                                '</filters>' + 
                                 '<filters>' + 
                                '<field>Milestone_Target_Date__c</field>' + 
                                '<operation>lessOrEqual</operation>' + 
                                '<value>TODAY</value>' + 
                               ' </filters>' + 
                                '<filters>' + 
                                    '<field>Completion_Date__c</field>' + 
                                   ' <operation>equals</operation>' + 
                                '</filters>' + 
                                '<filters>' + 
                                    '<field>CASES.CREATED_DATE</field>' + 
                                    '<operation>greaterThan</operation>' + 
                                    '<value>1/1/2013 12:00 AM</value>' + 
                                '</filters>' + 
                                '<filters>' +
                                    '<field>Product_Line__c</field>' +
                                    '<operation>equals</operation>' +
                                    '<value>Banner</value>' +
                                '</filters>' +
                               ' <filters>' +
                                   ' <field>PRODUCT.NAME</field>' +
                                    '<operation>equals</operation>' +
                                    '<value>Student</value>' +
                                '</filters>' +
                                '<booleanFilter> (((1 AND 2) AND (4 AND 5)) OR ((1 AND 3) AND (6 AND 7)))</booleanFilter>'+
                                '<label>All Open Cases</label>' + 
                                '<queue>Queue_Admin</queue>' + 
                               ' <sharedTo>' + 
                                    '<allInternalUsers></allInternalUsers>' + 
                                '</sharedTo>' + 
                                '</listViews>' +  
                                '</CustomObject>';
                                
        extObj.receiveMetadataZipFile();
        extObj.receiveComplete();
                                
       Test.stopTest();
   }
}