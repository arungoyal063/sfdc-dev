/*******************************************************************************************************************
** Module Name   : MetadataCreateJob
** Description   : Batch Class is used for parsing of metadata xml files
** Throws        : NA
** Calls         : NA
** Test Class    : MetadataCreateJobTest
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-16-07  Rainmaker             Initial Version
******************************************************************************************************************/
public class MetadataCreateJob
    implements Database.Batchable<MetadataFile>, Database.Stateful {
    
    private List<MetadataFile> items;
    /*private Map<String, String> operatorMap = new Map<String, String> {'equals' => '='}; 
    private Map<String, String> standrdFieldMap = new Map<String, String>{'NAME' =>'Name','OWNER.ALIAS' => 'Owner.Alias','OWNER.LAST_NAME' => 'Owner.LastName',
                                                            'OWNER.FIRST_NAME' => 'Owner.FirstName', 'OWNER_NAME' =>'Owner.Name', 
                                                            'UPDATEDBY_USER.ALIAS' => 'LastModifiedBy.Alias', 'CREATEDBY_USER.ALIAS' => 'CreatedBy.Alias', 
                                                            'OBJECT_ID'  => 'ID','RECORDTYPE' => 'RecordType.Name','CREATED_DATE' => 'CreatedDate',
                                                            'LAST_UPDATE' => 'LastModifiedDate','LAST_ACTIVITY' => 'LastActivityDate',
                                                            'CREATEDBY_USER' => 'CreatedBy.Name','UPDATEDBY_USER' => 'LastModifiedBy.Name',
                                                            'CURRENCY_ISO_CODE' => 'CurrencyIsoCode', 'CASE_NUMBER' => 'CaseNumber', 
                                                            'CLOSED' =>'IsClosed', 'ESCALATED' => 'IsEscalated',
                                                            'CLOSED_DATE' => 'ClosedDate', 'EXTERNAL' => 'IsVisibleInSelfService',
                                                            'ESCALATION_STATE' => 'IsEscalated','CREATED_BY_NICKNAME' => 'CreatedBy.CommunityNickname',
                                                            'CREATED_BY_ALIAS' =>  'CreatedBy.Alias'}; */
    
    private static Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();   // describe field map
    private static Map<Schema.SObjectField, DescribeFieldResult> describeFieldResult = new Map<Schema.SObjectField, DescribeFieldResult>(); // describe field result map
    private String sobjectMember;
    private String sobjectPluralLabel;
    private String capsPluralLabel;  // use in case of standard object
    private String capsObjectName;   // use in case of standard object
   
    public MetadataCreateJob(List<MetadataFile> items){
        this.items = items;     
        sobjectMember = '';
        sobjectPluralLabel = '';
    }
    
    public Iterable<MetadataFile> start(Database.BatchableContext info){
        return new JobIterable(items);         
    } 
    
    public void execute(Database.batchableContext info, List<MetadataFile> scope){
        
        System.debug('>>' + scope[0].content);
        if(scope[0].fullname != null && scope[0].content != null){
        
            List<ListView__c> lwList = new List<ListView__c>();
            Dom.Document doc = new Dom.Document();
            doc.load(scope[0].content);
            DOM.XMLNode root = doc.getRootElement(); // root is CustomObject
            
            for (Dom.XMLNode listchild: root.getChildren()) {
                if(listchild.getName() == 'listViews'){
                    
                    ListView__c lwObj = new ListView__c();
                    String booleanFilter  = '';
                    List<String> filtersList = new List<String>();
                    String filterCriteria = '';       // List view filter criteria
                    
                    // get Object Name
                    lwObj.Object_Name__c  = scope[0].fullname.substring(scope[0].fullname.indexOf('/') + 1, scope[0].fullname.indexOf('.'));
                    
                    // get Sobject token
                    Schema.SObjectType sobj = Schema.getGlobalDescribe().get(lwObj.Object_Name__c);
                    Schema.DescribeSObjectResult describeResult = sobj.getDescribe();
                    System.debug('LABEL ::' + describeResult.getLabel() + 'PLURAL LABEL ::'  + describeResult.getLabelPlural());
                    if (describeResult.isCustom()){
                        sobjectPluralLabel = describeResult.getLabelPlural() + '.'; 
                        sobjectMember = lwObj.Object_Name__c + '.';
                    } else {
                        sobjectPluralLabel = describeResult.getLabelPlural().toUpperCase() + '.'; 
                        sobjectMember = lwObj.Object_Name__c.toUpperCase() + '.'; 
                        
                         capsPluralLabel =  sobjectPluralLabel.toLowerCase().capitalize(); 
                         capsObjectName = sobjectMember.toLowerCase().capitalize();      
                    }
                                   
                    fieldMap = describeResult.fields.getMap();                   
                    lwObj.Columns__c = '';             
                    
                    
                                        
                    for(Dom.XMLNode child: listchild.getChildren()) {
                         if(child.getName() == 'fullName') {
                             lwObj.ListView_Name__c = child.getText();
                         }  
                         else if(child.getName() == 'label') {
                             lwObj.ListView_Label__c = child.getText();
                         }
                         else if(child.getName() == 'columns') {
                            string columnName =  MetadataUtility.parseColumnName(child.getText(), sobjectPluralLabel, sobjectMember);
                            lwObj.Columns__c  = lwObj.Columns__c + columnName + ',';     
                         }
                         else if(child.getName() == 'filterScope') {
                               lwObj.FilterScope__c =  child.getText();
                         }
                         else if(child.getName() == 'sharedTo') {
                             lwObj.SharedTo__c =  child.getText();    
                         }
                         else if(child.getName() == 'booleanFilter'){
                             booleanFilter = child.getText();       
                         } 
                         else if(child.getName() == 'filters'){
                            String field;
                            String operator;
                            String value;
                            
                            for(Dom.XMLNode filterChild: child.getChildren()){
                                
                                  if(filterChild.getName() == 'field') {
                                      field =   MetadataUtility.parseColumnName(filterChild.getText(), sobjectPluralLabel, sobjectMember);
                                      
                                     /* if(field.startsWith(sobjectPluralLabel)) {  // remove object prefix from field name
                                         field = field.replaceFirst(sobjectPluralLabel,'');    
                                      }  else if(field.indexOf('.') != -1) {                                
                                          List<String> parentFieldMetadata = field.split('\\.');                                            
                                          field = parentFieldMetadata.get(0).toLowerCase().capitalize() + '.' + parentFieldMetadata.get(1).toLowerCase().capitalize();
                                      }  */                                 
                                  } else if(filterChild.getName() == 'operation'){
                                      operator = filterChild.getText(); 
                                  } else if(filterChild.getName() == 'value'){
                                        value = filterChild.getText();
                                  }
                            }
                            String filterCondition = getFilterCondition(field, operator, value);
                            
                            if(filterCondition != null) {
                                filtersList.add(filterCondition);
                            }
                         } else if(child.getName() == 'queue'){
                             
                             if(lwObj.FilterScope__c  != null && lwObj.FilterScope__c == 'Queue'){
                                 lwObj.FilterScope__c = 'Queue-' + child.getText();
                             } 
                             
                            
                              // in case of queue it is possibe there is no field on ListView
                             if(lwObj.Object_Name__c.equalsIgnoreCase('Case') && String.isEmpty(lwObj.Columns__c)){  // default case listview columns // use comma at last  
                                 lwObj.Columns__c = 'CaseNumber,Contact.Name,Subject,Status,Priority,CreatedDate,Owner.Alias,';             
                             }            
                         }  
                    }
                   
                    if(lwObj.Columns__c != null && lwObj.Columns__c.trim() != ''){
                        lwObj.Columns__c = lwObj.Columns__c.subString(0, lwObj.Columns__c.length() - 1);        
                    }
                    
                    filterCriteria = getAllFilterCriteria(filtersList, booleanFilter);
                    lwObj.Filter_Criteria__c = filterCriteria;
                    
                    lwObj.ListView_Unique_Name__c = sobjectMember + lwObj.ListView_Name__c;
                    
                    lwList.add(lwObj);
                }
            }           
            
            if(!lwList.isEmpty()) {
                upsert lwList ListView_Unique_Name__c;    
            }   
        }
        
    }
    
    public void finish(Database.batchableContext info){
        
    }  
    
   

    // get single filter codition
    public String getFilterCondition(String field, String operator, String value) {
            String filterCondition = '';
            String SPACECHAR = ' ';
            String ESCAPECHAR = '\\\'';
            
            String fieldname;
            /*if (standrdFieldMap.containsKey(field)) {  // standard field
                fieldname = standrdFieldMap.get(field);
            } else if(field.isAllUpperCase()){         // stnadard field with all uppercase
                fieldname = field.swapCase();        
            } else {
                fieldname = field;    
            }*/
           
            // Describe Sobject Field
            fieldname = field;
            DescribeFieldResult dfr = getFieldMetadata(fieldname);
             
            
            if(String.isNotEmpty(value)){
               
               
               
                System.debug(value);
                System.debug(sobjectPluralLabel);
                System.debug(sobjectMember);
                System.debug(capsPluralLabel);
                System.debug(capsObjectName);
                
                if(value.startsWith(sobjectPluralLabel)) {
                    value = value.replace(sobjectPluralLabel, '');
                } else if (value.startsWith(sobjectMember))    {
                    value = value.replace(sobjectMember, '');
                } else if (capsPluralLabel != null && value.startsWith(capsPluralLabel))    {
                    value = value.replace(capsPluralLabel, '');
                } else if (capsObjectName != null && value.startsWith(capsObjectName))    {
                    value = value.replace(capsObjectName, '');
                } 
            }
            
       
            if(dfr != null){            
                // date field
                if(dfr.getType() == Schema.DisplayType.Date) {
                    if(String.isNotEmpty(value)){
                        try{
                            String dtvalue = String.valueOf(Date.parse(value));
                            value = dtvalue;
                        }catch(Exception e) {
                            System.debug('Error::' + e.getMessage());
                        } 
                    }
                    filterCondition =  MetadataUtility.parseNumberFilter(fieldname, operator, value);                                       
                }
                
                // datetime field
                else if(dfr.getType() == Schema.DisplayType.DateTime) {  
                    
                    if(String.isNotEmpty(value)){
                        try {
                            String dtvalue = String.valueOf(DateTime.parse(value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                            value = dtvalue;
                        } catch(Exception e) {
                            System.debug('Error::' + e.getMessage());
                        } 
                    }
                    filterCondition =  MetadataUtility.parseNumberFilter(fieldname, operator, value);                                       
                } 
                
                // numeric field 
                else if(dfr.getType() == Schema.DisplayType.Double 
                    || dfr.getType() == Schema.DisplayType.Integer){ 
                    
                    filterCondition =  MetadataUtility.parseNumberFilter(fieldname, operator, value);      
                } 
                
                // currency field
                else if(dfr.getType() == Schema.DisplayType.Currency) {   
                    
                    // currency filter is in the form of "USD 10"
                    if(String.isNotEmpty(value)){
                        value = value.subString(4, value.length());   
                    }
                    filterCondition = MetadataUtility.parseNumberFilter(fieldname, operator, value); 
                }
                
                // boolean field
                else if(dfr.getType() == Schema.DisplayType.Boolean){  
                    
                    // Boolean filter is in the form of 0 or 1
                    if(String.isNotEmpty(value)) {
                        value = integer.valueOf(value) >= 1 ? 'true' : 'false';
                    }   
                    filterCondition =  MetadataUtility.parseNumberFilter(fieldname, operator, value); 
                    
                } 
                
                // reference field 
                else if(dfr.getType() == Schema.DisplayType.Reference){  
                   
                   String parentFieldName = dfr.getRelationshipName() + '.Name';
                   filterCondition =  MetadataUtility.parseStringFilter(parentFieldName, operator, value); 
                   
                } 
                
                // picklist or multipicklist
                else if (dfr.getType() == Schema.DisplayType.Picklist || dfr.getType() == Schema.DisplayType.MultiPicklist) { 
                     filterCondition =   MetadataUtility.parseStringFilter(fieldname,  operator, value);     
                }
                
                else if(dfr.getType() == Schema.DisplayType.String){    // string field types
                    filterCondition =  MetadataUtility.parseStringFilter(fieldname, operator, value);        
                }  
            } else { // if field is on other object like User or Record Type
                 System.debug('FIELDNAME::' + fieldname);
                 filterCondition =  MetadataUtility.parseStringFilter(fieldname, operator, value);    
                 System.debug('CONDITION::' + filterCondition);   
            }
            return filterCondition;
    }
    
    /* concatenate all single filter */
    public String getAllFilterCriteria(List<String> filterList, String booleanFilter) {
        String SPACECHAR = ' ';
        String ANDCHAR = 'AND';
        if(!filterList.isEmpty()) {
            String criteria = '';
            
            if(String.isNotEmpty(booleanFilter)) {
                booleanFilter = MetadataUtility.simplifyFilterCriteria(booleanFilter);
                List<String> charList = booleanFilter.split('');
                
                for(String chr : charList){
                    if(chr.isNumeric()){
                        criteria = criteria +  filterList.get(integer.valueOf(chr) -1);  
                    } else{
                        criteria = criteria + chr;    
                    }
                }
                
            } else {
                for(String c :filterList){
                    criteria = criteria + c + SPACECHAR + ANDCHAR + SPACECHAR;     
                }
                if(criteria.trim() != ''){
                    criteria = criteria.subString(0, criteria.length() - ANDCHAR.length() -1);    
                }
            }
            
            return criteria;
        }
        return null;
    }
    
    

    public DescribeFieldResult getFieldMetadata(String fieldName){
        System.debug('FIELD NAME ::' + fieldName);
        
        if(fieldName != null && fieldName.contains('.')){ // if field on other object like owner.firstname, RecordType.Name
            return null;
        }
        else if(fieldName != null) {
            Schema.SObjectField fieldtoken = fieldMap.get(fieldname);
            
            DescribeFieldResult dfr ;
            
            if((!describeFieldResult.isEmpty()) && describeFieldResult.containsKey(fieldtoken)){
                dfr = describeFieldResult.get(fieldtoken);
            } 
            else {
                dfr = fieldtoken.getDescribe(); 
            }
            return dfr;
        }
        return null;   
    }

    public class MetadataFile extends MetadataService.MetadataWithContent
    {
        public String getFullname()
        {
            return fullName;
        }
        
        public String getContent()
        {
            return content;
        }
    }
    
    private class JobIterator
            implements Iterator<MetadataFile> {
            
        private List<MetadataFile> items;
        private Integer nextIdx;
        
        public JobIterator(List<MetadataFile> items)
        {
            this.items = items;
            this.nextIdx = 0;
        }
        
        public boolean hasNext()
        {
            return nextIdx >= items.size() ? false : true;
        }
        
        public MetadataFile next()
        {
            return items[nextIdx++];
        }
    }

    
    private class JobIterable
        implements Iterable<MetadataFile> {
        
        private List<MetadataFile> iteratorItems;
        
        public JobIterable(List<MetadataFile> items)
        {
            iteratorItems = new List<MetadataFile>(); 
            iteratorItems.addAll(items);
        }
        
        public Iterator<MetadataFile> Iterator()
        {
            return new JobIterator(iteratorItems);
        }       
    }
   
    
}