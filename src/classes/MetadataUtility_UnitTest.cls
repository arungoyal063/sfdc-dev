@isTest
public class MetadataUtility_UnitTest{
    static testMethod void runTestMethod(){
           
           Map<String,ID> profiles = new Map<String,ID>();
           List<Profile> ps = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];

           for(Profile p : ps){
               profiles.put(p.name, p.id);
           }

            User admin = [SELECT Id FROM user WHERE profileid = :profiles.get('System Administrator')  and isactive = true Limit 1 ];
            system.runas(admin){
            String inputfilter ='(((1 AND 2) AND (4 AND 5)) OR ((1 AND 3) AND (4 AND 5)))';
            MetadataUtility.simplifyFilterCriteria(inputfilter);
            
            String columnName='NAME'; 
            String sobjectPluralLabel='NameSTD ';
            String sobjectMember='Case.';
            MetadataUtility.parseColumnName(columnName, sobjectPluralLabel, sobjectMember);
                       
            columnName='NAME'; 
            sobjectPluralLabel='Case';
            sobjectMember='NAMECase.';
            MetadataUtility.parseColumnName(columnName, sobjectPluralLabel, sobjectMember);
            
            columnName='NAME'; 
            sobjectPluralLabel='Cases';
            sobjectMember='Case.';
            MetadataUtility.parseColumnName(columnName, sobjectPluralLabel, sobjectMember);
            
            String input = '12';
            MetadataUtility.getSplitString(input);
            
            String field='name';
            String operator='equals';
            String value='Test';
            String listvalue = 'test1, test2, test3';
            MetadataUtility.parseStringFilter(field,  operator, value);
            MetadataUtility.parseStringFilter(field,  operator, listvalue); 
            value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
            
            Operator='notEqual';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value); 
            value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
                       
            Operator='lessThan';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
            value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
            
            Operator='greaterThan';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
             value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
            
            Operator='lessOrEqual';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
             value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
            
            Operator='greaterOrEqual';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
            value=null;
            MetadataUtility.parseStringFilter(field,  operator, value);
             
            Operator='contains';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
            value=null;
            MetadataUtility.parseStringFilter(field,  operator, value);
             
            Operator='notContain';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
             value=null;
            MetadataUtility.parseStringFilter(field,  operator, value);
             
            Operator='startsWith';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
             value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
            
            Operator='includes';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
            value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
            
            Operator='excludes';
            value='Test';
            MetadataUtility.parseStringFilter(field,  operator, value);
            value=null;
            MetadataUtility.parseStringFilter(field,  operator, value); 
            
            
            String field1='Days_Open__c';
            String operator1='equals';
            String value1='12';
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            value1=null;
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            
            value1='12';
            Operator1='notEqual';
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            value1=null;
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            
            value1='12';
            Operator1='lessThan';
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            value1=null;
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            
            value1='12';
            Operator1='greaterThan';
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            value1=null;
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            
            value1='12';
            Operator1='lessOrEqual';
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            value1=null;
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            
            value1='12';
            Operator1='greaterOrEqual';
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
            value1=null;
            MetadataUtility.parseNumberFilter(field1, operator1, value1);
             
           //MetadataUtility.parseCutsomFilters(String jsonString, Map<String, String> fieldTypeMap);
            
            
            
            String filterScope='Mine';
            String objectName='Case';
            MetadataUtility.parseFilterScope(filterScope, objectName);
            
            objectName='Case';
            filterScope='Queue-Dtata1233-1Test';
            MetadataUtility.parseFilterScope(filterScope, objectName);
            
            objectName='Idea';
            filterScope='Queue';
            MetadataUtility.parseFilterScope(filterScope, objectName);
            
            
            String searchInput='OR(a,b,c)';
            MetadataUtility.parseORFilters(searchInput);
            
            String searchInput1='NOT(a,b,c)';
            MetadataUtility.parseExcludeFilters(searchInput1) ;
            
            String input1='anc%\\-';
            MetadataUtility.escapeSpecialChars(input1);
            
            //MetadataUtility.genStringFilters()
            String resourceName='MetaDataBatchResource';
           // MetadataUtility.GetResourceURL(resourceName);
            
            String resPath='MetaDataBatchResource';
           // MetadataUtility.getResourceContent(resPath,'Case');
           
           MetadataUtility.genStringFilters('(Is equal to = banner)', 'Product_Line__c');
           MetadataUtility.genStringFilters('(Is not equal to = banner)', 'Product_Line__c');
           MetadataUtility.genStringFilters('(Contains = banner)', 'Product_Line__c');
           MetadataUtility.genStringFilters('(Does not contain = banner)', 'Product_Line__c');
           MetadataUtility.genStringFilters('(Starts With = banner)', 'Product_Line__c');
           MetadataUtility.genStringFilters('(Ends With = banner)', 'Product_Line__c');
           
           MetadataUtility.createService();
           MetadataUtility.getIdeaThemeList(new Set<ID>{'01pZ0000000ENSj'});
           MetadataUtility.checkMetadataPermission();
           String jsonInput = '[{"type":"list","value":["New","Open"],"field":"Status"},{"type":"string","value":"(Is equal to = banner)","field":"Product_Line__c"},{"type":"date","comparison":"lt","value":"07/17/2013","field":"CreatedDate"},{"type":"string","value":"(Is equal to = test)","field":"Account.Name"}]';
           Map<String, String> fieldTypeMap  = new Map<String, String>();
           fieldTypeMap.put('ClosedDate', 'datetime');
           fieldTypeMap.put('CreatedDate', 'datetime');
           fieldTypeMap.put('LastModifiedDate', 'datetime');
           MetadataUtility.parseCutsomFilters(jsonInput, fieldtypeMap);
           MetadataUtility.isRunningInSandbox();
           
       } 
    }



}