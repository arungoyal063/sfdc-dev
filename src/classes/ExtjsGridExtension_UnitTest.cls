@isTest
public class ExtjsGridExtension_UnitTest{
    static testMethod void RunTestMethod(){
      Map<String,ID> profiles = new Map<String,ID>();
      Change_Request__c cr = MockTestData.createCRRecord('Test');
      
      Idea ideaObject = MockTestData.createIdeaRecord('Test', 'Test', cr.Id);
      
      ApexPages.StandardSetController setCon = new ApexPages.StandardSetController([SELECT Id, Name From Change_Request__c LIMIT 1]);
      ListView__c lwObject = new ListView__c();
      lwObject.ListView_Label__c = setCon.getListViewOptions().get(0).getLabel();
      lwObject.Filter_Criteria__c = 'RecordType.Name = \'Defect\'';
      lwObject.ListView_Name__c = 'Test_CR_Defects';
      lwObject.ListView_Unique_Name__c = 'Change_Request__c.Test_CR_Defects';
      lwObject.Columns__c = 'Name,Status__c,Sub_Status__c,Severity__c,Product_Line__c,Product_Name__c,Module__c,Object_Program__c,Summary__c,CreatedDate,Date_Resolved__c,Resolved_In_Release__c,Patch_Number__c';
      lwObject.Object_Name__c = 'Change_Request__c';   
      lwObject.FilterScope__c = 'Everything';       
      insert lwObject;    
          
      List<Profile> ps = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];

      for(Profile p : ps){
         profiles.put(p.name, p.id);
      }

        User admin = [SELECT Id FROM user WHERE profileid = :profiles.get('System Administrator') and isactive =  true Limit 1  ];
        system.runas(admin){
       
        
        ApexPages.currentPage().getParameters().put('fcf', setCon.getListViewOptions().get(0).getValue()) ;
        ExtjsGridExtension  EX = new ExtjsGridExtension(setCon);
        EX.selListView = lwObject.Id;
        EX.retListView();
        EX.goClick();
        String objName='Change_Request__c';
        List<String> fieldNames = new List<String> ();
        fieldNames.add('Owner.FirstName');
        fieldNames.add('CreatedBy.FirstName');
        fieldNames.add('LastModifiedBy.FirstName');
        fieldNames.add('RecordType.Name');
        fieldNames.add('Idea.Title');
        EX.describeFields(objName, fieldNames);
        Ex.gotoRefreshFilter();
    
      }
    }

}