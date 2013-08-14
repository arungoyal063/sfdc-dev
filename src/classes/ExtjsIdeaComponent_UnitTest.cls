@isTest
global class ExtjsIdeaComponent_UnitTest{
    static testMethod void RunTestMethod(){
        Test.StartTest();
        Change_Request__c cr1 = MockTestData.createCRRecord('Test');
        Idea ideaObject = MockTestData.createIdeaRecord('Test', 'Test', cr1.Id);
        String objName='Idea';
        List<String> fieldNames = new List<String> ();
        fieldNames.add('Owner.FirstName');
        fieldNames.add('CreatedBy.FirstName');
        fieldNames.add('LastModifiedBy.FirstName');
        fieldNames.add('RecordType.Name');
        fieldNames.add('IdeaThemeId-IdeaTheme.Title');
        fieldNames.add('Case__c');
        
        
        ExtjsIdeaComponent.describeFields(objName, fieldNames);
        ExtjsIdeaComponent.QueryObj queryObj = new ExtjsIdeaComponent.QueryObj( );
        queryObj.sobjname = 'Idea';
        queryObj.fields = 'Status,Title,Object_Process__c,IdeaThemeId,IdeaTheme.Title';
        queryObj.start = 201;
        queryObj.recordCount = 10;
        queryObj.fieldTypeMap = new Map<String, String>() ;
        queryObj.queryfilter='Product_Line_New__c = \'Banner\'';
        queryObj.queryscope='Mine';
        queryObj.filter='[{"type":"list","value":["New"],"field":"Status"}]';  
        queryObj.sortParams = new List<Map<String, String>>();
        Map<String, String> param1Map = new Map<String, String>{'direction' => 'ASC', 'property' => 'Status'};
        Map<String, String> param2Map = new Map<String, String>{'direction' => 'DESC', 'property' => 'Status'};
        queryObj.sortParams.add(param1Map );
        queryObj.sortParams.add(param2Map );
        ExtjsIdeaComponent.query(queryObj);
       
        ExtjsIdeaComponent.CRUDData crudObj = new  ExtjsIdeaComponent.CRUDData();
        Account testAccount = new Account();
        testAccount.name = 'Test Account1';
        
        insert testAccount;
        crudObj.sobjname = 'Change_Request__c';
        crudObj.fields = 'Summary__c,Status__c,Module__c';
        crudObj.oppId = testAccount.Id;
        crudObj.parentFieldName ='Account__c';
        Change_Request__c cr = MockTestData.createCRRecord('Test');
        List<SObject> sobjList = new List<SObject>();
        sobjList.add(cr);
        
        Map<String, String> fieldMap = new Map<String, String>{'Id' => cr.Id, 'Status__c' => cr.Status__c};
        crudObj.records = new List<Map<String, String>>{fieldMap};
        
        ExtjsIdeaComponent.refreshObjects(crudObj, sobjList);
        ExtjsIdeaComponent.create(crudObj);
        ExtjsIdeaComponent.updat(crudObj);
        ExtjsIdeaComponent.CRUDResponse crdrespose = ExtjsIdeaComponent.delet(crudObj);
    
       Test.StopTest();
    }
    
}