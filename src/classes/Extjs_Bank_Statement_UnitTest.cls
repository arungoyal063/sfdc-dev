@isTest
global class Extjs_Bank_Statement_UnitTest{
    static testMethod void RunTestMethod(){
       Extjs_Bank_Statement eBSObj = new Extjs_Bank_Statement();
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
        fieldNames.add('Status');
        Extjs_Bank_Statement.describeFields(objName, fieldNames);
        Extjs_Bank_Statement.QueryObj queryObj = new Extjs_Bank_Statement.QueryObj();
        queryObj.sobjname = 'Idea';
        queryObj.fields = 'Status,Title,Object_Process__c,IdeaThemeId,IdeaTheme.Title';
        queryObj.start = 201;
        queryObj.recordCount = 10;
        queryObj.fieldTypeMap = new Map<String, String>() ;
        queryObj.queryfilter='Product_Line_New__c = \'Banner\'';
        queryObj.queryscope='Mine';
        queryObj.filter='[{"type":"list","value":["New"],"field":"Status"}]';  
        queryObj.sortParams = new List<Map<String, String>>();
        Map<String, String> param1Map = new Map<String, String>{'direction' => 'ASC', 'property' => 'Summary__c'};
        Map<String, String> param2Map = new Map<String, String>{'direction' => 'DESC', 'property' => 'Status__c'};
        queryObj.sortParams.add(param1Map );
        queryObj.sortParams.add(param2Map );
        Extjs_Bank_Statement.query(queryObj);
        
        Extjs_Bank_Statement.CRUDData crdObj = new Extjs_Bank_Statement.CRUDData();
        crdObj.sobjname = 'Idea';
        crdObj.fields = 'Status,Title,Object_Process__c';
        List<SObject> sobjs = (List<SObject>)[SELECT Status,Title,Object_Process__c FROM Idea LIMIT 1];
        Extjs_Bank_Statement.refreshObjects(crdObj, sobjs);
        
        
       
        /*Extjs_Bank_Statement.CRUDData crudObj = new  Extjs_Bank_Statement.CRUDData();
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
        
        Map<String, String> fieldMap = new Map<String, String>{'Id' => cr.Id, 'Module__c' => cr.Module__c, 'Status__c' => cr.Status__c};
        crudObj.records = new List<Map<String, String>>{fieldMap};
        Extjs_Bank_Statement.refreshObjects(crudObj, sobjList);
        Extjs_Bank_Statement.create(crudObj);
        Extjs_Bank_Statement.updat(crudObj);
        Extjs_Bank_Statement.CRUDResponse crdrespose = Extjs_Bank_Statement.delet(crudObj);*/
    
    
    }
    
}