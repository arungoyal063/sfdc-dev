public class MetadataUtility {
    private static Map<String, String> standrdFieldMap = new Map<String, String>{'NAME' =>'Name','OWNER.ALIAS' => 'Owner.Alias','OWNER.LAST_NAME' => 'Owner.LastName',
                                                            'OWNER.FIRST_NAME' => 'Owner.FirstName', 'OWNER_NAME' =>'Owner.Name', 
                                                            'UPDATEDBY_USER.ALIAS' => 'CreatedBy.Alias', 'CREATEDBY_USER.ALIAS' => 'LastModifiedBy.Alias',
                                                            'OBJECT_ID'  => 'ID','RECORDTYPE' => 'RecordType.Name','CREATED_DATE' => 'CreatedDate',
                                                            'LAST_UPDATE' => 'LastModifiedDate','LAST_ACTIVITY' => 'LastActivityDate',
                                                            'CREATEDBY_USER' => 'CreatedBy.Name','UPDATEDBY_USER' => 'LastModifiedBy.Name',
                                                            'CURRENCY_ISO_CODE' => 'CurrencyIsoCode', 'CASE_NUMBER' => 'CaseNumber', 
                                                            'CLOSED' =>'IsClosed', 'ESCALATED' => 'IsEscalated',
                                                            'CLOSED_DATE' => 'ClosedDate', 'EXTERNAL' => 'IsVisibleInSelfService',
                                                            'ESCALATION_STATE' => 'IsEscalated','CREATED_BY_NICKNAME' => 'CreatedBy.CommunityNickname',
                                                            'CREATED_BY_ALIAS' =>  'CreatedBy.Alias', 'NUM_COMMENTS' =>'NumComments',
                                                            'Vote_stats.Weighted_sum' => 'VoteTotal', 'IDEA_THEME' => 'IdeaTheme.Title',
                                                            'LAST_COMMENT_DATE'=>'LastCommentDate', 'FIRST_NAME' => 'FirstName', 'LAST_NAME' => 'LastName'};
    
     /** method is used to Simplify complex filters **/
     public static String simplifyFilterCriteria(String inputFilter) {
        if(String.isNotEmpty(inputFilter)) {  
            String SPACECHAR = ' ';
            Set<String> oprList = new Set<String>{'AND', 'OR'};
            Map<String, integer> predMap = new Map<String, integer>{'AND' => 2, 'OR' => 1};
            
            inputFilter = '(' + inputFilter + ')';
            List<String> charList  = MetadataUtility.getSplitString(inputFilter);             
            List<String> bufferList = new List<String>();
            integer buffersize;
            Stack stackObj = new Stack();
          
            for(integer i = 0; i < charList.size(); i++) {
                String element = charList[i];
                
                if (element == '('){
                    bufferList.add(element);   
                } else if(charList[i].isNumeric()) {
                    stackObj.push(element);   
                } else if(oprList.contains(element)){
                    
                    if(!bufferList.isEmpty()) {
                        buffersize = bufferList.size() -1;                         
                    
                        while((predMap.containsKey(bufferList[buffersize])) 
                            && (predMap.get(bufferList[buffersize]) == predMap.get(element))){
                            stackObj.push( '( ' + stackObj.pop() + SPACECHAR + bufferList[buffersize] + SPACECHAR + stackObj.pop() + ')');
                            
                            bufferList.remove(buffersize);
                            buffersize--;           
                        }
                     }    
                    bufferList.add(element);    
                   
                } else if(element == ')') {
                    buffersize = bufferList.size() -1;           
                    while(buffersize >= 0){
                        if(bufferList[buffersize] == '('){
                            bufferList.remove(buffersize);
                            break;
                        }
                        else if(oprList.contains(bufferList[buffersize])){
                            stackObj.push( '( ' + stackObj.pop() + SPACECHAR + bufferList[buffersize] + SPACECHAR + stackObj.pop() + ')');           
                            bufferList.remove(buffersize);
                        }
                        buffersize--;
                    }
                }  
            }
            return (stackObj.pop());
        }
        return null;
    }
    
     public static String genStringFilters(String textInput, String field) { 
         if(String.isNotEmpty(textInput)){
             String textQuery = '';
             List<String> charList  = textInput.split('');
             for(integer i = 0; i < charList.size(); i++) {
                 String a = charList[i];
                 if(a == '(') {
                     integer endIndex = textInput.indexOf(')', i);
                     String condition = textInput.subString(i, endIndex);
                     string operator =  (condition.split('=')[0]).trim();
                     String value = (condition.split('=')[1]).trim();
                     i = endIndex - 1;
                     
                     if(operator == 'Is equal to') {
                         //textQuery  +=  field + ' = \'' + String.escapeSingleQuotes(value) + '\'';
                         textQuery  +=  field + ' LIKE \'' +  escapeSpecialChars(value) + '\'';
                     } 
                     else if(operator == 'Is not equal to') {
                         //textQuery  +=  field + ' !=  \'' + String.escapeSingleQuotes(value) + '\'';  
                         textQuery  +=  ' (NOT ' + field + ' LIKE \'' +  escapeSpecialChars(value) + '\')';     
                     } else if(operator == 'Contains'){
                         textQuery  +=  field + ' LIKE \'%' +  escapeSpecialChars(value) + '%\'';          
                     } else if(operator == 'Does not contain'){
                         textQuery  +=  ' (NOT ' + field + ' LIKE \'%' +  escapeSpecialChars(value) + '%\')'; 
                     } else if(operator == 'Starts With'){
                          textQuery  += field + ' LIKE \'' + escapeSpecialChars(value) + '%\'';         
                     } else if(operator == 'Ends With'){
                          textQuery  += field + ' LIKE \'%' + escapeSpecialChars(value) + '\''; 
                     }
                 } else if(a == ')') {
                     integer endIndex =  textInput.indexOf('(', i);
                     if(endIndex != -1) {
                           textQuery += ' ' + textInput.subString(i, endIndex).trim() + ' ';
                           i = endIndex - 1;
                     }  
                 }    
             }
             return textQuery;
         }
         return null;   
     }
    
     public static String parseColumnName(String columnName, String sobjectPluralLabel, String sobjectMember){
         if(columnName.startsWith(sobjectPluralLabel)){   // remove Listview object prefix from field name
            columnName = columnName.replaceFirst(sobjectPluralLabel,'');
         } else if(columnName.startsWith(sobjectMember)){
            columnName = columnName.replaceFirst(sobjectMember,'');    
         } else if (columnName.startsWith('CORE.USERS')){
            columnName = columnName.replaceFirst('CORE.USERS', 'OWNER');   
         } else if(columnName.indexOf('.') != -1){
            List<String> parentFieldMetadata = columnName.split('\\.');
            System.debug('PARENT FIELD ::' + parentFieldMetadata);
            columnName = parentFieldMetadata.get(0).toLowerCase().capitalize() + '.' + parseColumnName(parentFieldMetadata.get(1), parentFieldMetadata.get(0), parentFieldMetadata.get(0)); //parentFieldMetadata.get(1).toLowerCase().capitalize();   
         }
         
          if(columnName.equalsIgnoreCase('NAME') && (sobjectMember.equalsIgnoreCase('Case.')) ){  // replace name field in case of case
            columnName = 'Contact.Name';    
          }
          else if(standrdFieldMap.containsKey(columnName)){
            columnName = standrdFieldMap.get(columnName); 
            
          } else if(columnName.isAllUpperCase()){
            columnName = columnName.swapCase().capitalize();    
          }     
         
         return columnName;
     }
     
     public static List<String> getSplitString(String input){
       
        List<String> charList = new List<String>(); 
        if(input != null) { 
            String buffer = '';         
            for(String a :input.split('')) {
                if(a == '(' || a == ')' || a.isNumeric()) {
                    charList.add(a);    
                } else if(a.isWhitespace()){
                    if(String.isNotEmpty(buffer)){
                        charList.add(buffer); 
                    } 
                    buffer = '';           
                } else {
                      buffer += a;         
                }    
            } 
        }
        return charList;   
    }
    
    /* parse string, picklist, multipicklist filters */  
    public static String parseStringFilter(String field, String operator, String value) {
        String SPACECHAR = ' ';        
        String ESCAPECHAR = '\\\'';
        String EMPTY = '\\\'\\\'';  
        
        String filterCondition = ''; 
       
        if (operator.equalsIgnoreCase('equals')) {
             
             if(value != null) {
                 List<String> valueList = value.split(',');
                 
                 if(valueList.size() == 1){
                     filterCondition += field + SPACECHAR + '=' + SPACECHAR + ESCAPECHAR + value + ESCAPECHAR;    
                 }
                 else {
                     filterCondition += field + SPACECHAR + 'IN' +  SPACECHAR + '(';                     
                     for (String a  : valueList){
                         filterCondition += ESCAPECHAR +  a +  ESCAPECHAR + ',';       
                     }
                     filterCondition = filterCondition.subString(0, filterCondition.length() - 1);
                     filterCondition += ')';  
                 }
             } else {
                 filterCondition += field + SPACECHAR + '=' + SPACECHAR + NULL; 
             }
         } else if (operator.equalsIgnoreCase('notEqual')) {
             if(value != null) {
                 List<String> valueList = value.split(',');
                 
                 if(valueList.size() == 1) {
                       filterCondition += field + SPACECHAR + '!=' + SPACECHAR + ESCAPECHAR + value + ESCAPECHAR;
                 }
                 else{            
                     filterCondition += field + SPACECHAR + 'NOT IN' +  SPACECHAR + '(';  
                     
                     for (String a :value.split(',')){
                         filterCondition += ESCAPECHAR +  a +  ESCAPECHAR + ',';     
                     } 
                     filterCondition = filterCondition.subString(0, filterCondition.length() - 1);  
                     filterCondition += ')';
                 }
             } else {
                 filterCondition += field + SPACECHAR + '!=' + SPACECHAR + NULL;     
             }
             
         } else if(operator.equalsIgnoreCase('lessThan')) {
             if(value != null){
                 List<String> optionList = value.split(',');
                             
                 filterCondition +=  field +  SPACECHAR + '<' + SPACECHAR +  ESCAPECHAR + optionList[0].trim() + ESCAPECHAR + SPACECHAR;     
                 
                 for (integer i = 1; i< optionList.size() ; i++) {
                     filterCondition +=  'OR' + SPACECHAR  + field + SPACECHAR + '<' +  SPACECHAR + ESCAPECHAR  +  optionList[i].trim() + ESCAPECHAR +  SPACECHAR;     
                 } 
             } else {
                 filterCondition += field + SPACECHAR + '<' + SPACECHAR + EMPTY;     
             } 
        } else if(operator.equalsIgnoreCase('greaterThan')){
        
             if(value != null){
                 List<String> optionList = value.split(',');
                             
                 filterCondition +=  field +  SPACECHAR + '>' + SPACECHAR + ESCAPECHAR + optionList[0].trim() + ESCAPECHAR + SPACECHAR;     
                 
                 for (integer i = 1; i< optionList.size() ; i++) {
                     filterCondition +=  'OR' + SPACECHAR  + field + SPACECHAR + '>' +  SPACECHAR  +  ESCAPECHAR + optionList[i].trim() + ESCAPECHAR + SPACECHAR;     
                 } 
             } else {
                 filterCondition += field + SPACECHAR + '>' + SPACECHAR + EMPTY; 
             } 
        
        } else if (operator.equalsIgnoreCase('lessOrEqual')){
           if(value != null){
                 List<String> optionList = value.split(',');
                             
                 filterCondition +=  field +  SPACECHAR + '<=' + SPACECHAR +  ESCAPECHAR + optionList[0].trim() + ESCAPECHAR + SPACECHAR;     
                 
                 for (integer i = 1; i< optionList.size() ; i++) {
                     filterCondition +=  'OR' + SPACECHAR  + field + SPACECHAR + '<=' +  SPACECHAR + ESCAPECHAR  +  optionList[i].trim() + ESCAPECHAR +  SPACECHAR;     
                 } 
             } else {
                 filterCondition += field + SPACECHAR + '<=' + SPACECHAR + EMPTY;     
             }      
        
        }  else if (operator.equalsIgnoreCase('greaterOrEqual')){        
            if(value != null){
                 List<String> optionList = value.split(',');
                             
                 filterCondition +=  field +  SPACECHAR + '>=' + SPACECHAR + ESCAPECHAR + optionList[0].trim() + ESCAPECHAR + SPACECHAR;     
                 
                 for (integer i = 1; i< optionList.size() ; i++) {
                     filterCondition +=  'OR' + SPACECHAR  + field + SPACECHAR + '>=' +  SPACECHAR  +  ESCAPECHAR + optionList[i].trim() + ESCAPECHAR + SPACECHAR;     
                 } 
             } else {
                 filterCondition += field + SPACECHAR + '>=' + SPACECHAR + EMPTY; 
             } 
        
        }  else if(operator.equalsIgnoreCase('contains')){
             if(value != null){
                 List<String> optionList = value.split(',');
                 
                 filterCondition +=  field + SPACECHAR  + 'Like' +  SPACECHAR + ESCAPECHAR + '%' + optionList[0].trim() +  '%' +  ESCAPECHAR + SPACECHAR;     
                 
                 for (integer i = 1; i< optionList.size() ; i++){
                     filterCondition +=  'OR' + SPACECHAR  + field + SPACECHAR + 'Like' +  SPACECHAR + ESCAPECHAR + '%' + optionList[i].trim() +  '%' +  ESCAPECHAR + SPACECHAR;     
                 } 
             } else {
                 
                 filterCondition += field + SPACECHAR + 'Like' + SPACECHAR + ESCAPECHAR + '%%' +ESCAPECHAR;         
               
             }
        }  else if(operator.equalsIgnoreCase('notContain')){
             String notFilter = 'NOT (';
             if(value != null){                 
                 List<String> optionList = value.split(',');
                 
                 filterCondition +=  notFilter + field + SPACECHAR  + 'Like' +  SPACECHAR + ESCAPECHAR + '%' + optionList[0].trim() +  '%' +  ESCAPECHAR + SPACECHAR;     
                 
                 for (integer i = 1; i< optionList.size() ; i++){
                     filterCondition +=  'OR' + SPACECHAR  + field + SPACECHAR + 'Like' +  SPACECHAR + ESCAPECHAR + '%' + optionList[i].trim() +  '%' +  ESCAPECHAR + SPACECHAR;     
                 } 
                 filterCondition += ')';   
             } else {
                 filterCondition +=  field + SPACECHAR  + 'Like' +  SPACECHAR + ESCAPECHAR + '%_%' +  ESCAPECHAR + SPACECHAR;           
             }
                  
        } else if(operator.equalsIgnoreCase('startsWith')){
             if(value != null){
                 List<String> optionList = value.split(',');
                 
                 filterCondition +=  field + SPACECHAR + 'Like' +  SPACECHAR + ESCAPECHAR + optionList[0].trim() +  '%' +  ESCAPECHAR + SPACECHAR;     
                 
                 for (integer i = 1; i< optionList.size() ; i++){
                     filterCondition +=  'OR' + SPACECHAR  + field + SPACECHAR + 'Like' +  SPACECHAR + ESCAPECHAR +  optionList[i].trim() +  '%' +  ESCAPECHAR + SPACECHAR;     
                 } 
             } else {
                 filterCondition += field + SPACECHAR + 'Like' + SPACECHAR + ESCAPECHAR + '%' + ESCAPECHAR;         
             }    
        } else if(operator.equalsIgnoreCase('includes')) {
            if(value != null){
                 filterCondition += field + SPACECHAR + 'INCLUDES' +  SPACECHAR + '(';                     
                 for (String a  : value.split(',')){
                     filterCondition += ESCAPECHAR +  a +  ESCAPECHAR + ',';       
                 }
                 filterCondition = filterCondition.subString(0, filterCondition.length() - 1);
                 filterCondition += ')';              
            }        
        } else if(operator.equalsIgnoreCase('excludes')){
             if(value != null){
                 filterCondition += field + SPACECHAR + 'EXCLUDES' +  SPACECHAR + '(';                     
                 for (String a  : value.split(',')){
                     filterCondition += ESCAPECHAR +  a +  ESCAPECHAR + ',';       
                 }
                 filterCondition = filterCondition.subString(0, filterCondition.length() - 1);
                 filterCondition += ')';  
            }      
        }
               
        return filterCondition;
    }
    
    
    
    /* parse number, currency, date and datetime filters */
    public static String parseNumberFilter(String field, String operator, String value){
        String SPACECHAR = ' ';
        String filterCondition = '';
         
        
        if(operator.equalsIgnoreCase('equals')){
            if(value != null){
                 filterCondition += field + SPACECHAR + '=' + SPACECHAR + value;
            } else {
                 filterCondition += field + SPACECHAR + '=' + SPACECHAR + NULL;         
            }                
        } else if(operator.equalsIgnoreCase('notEqual')){
            if(value != null){
                 filterCondition += field + SPACECHAR + '!=' + SPACECHAR + value;
            }  else {
                 filterCondition += field + SPACECHAR + '!=' + SPACECHAR + NULL;         
            }    
        } else if(operator.equalsIgnoreCase('lessThan')){
            if(value != null){
                 filterCondition += field + SPACECHAR + '<' + SPACECHAR + value;
            }         
        } else if(operator.equalsIgnoreCase('greaterThan')){
            if(value != null){
                 filterCondition += field + SPACECHAR + '>' + SPACECHAR + value;
            }        
        } else if(operator.equalsIgnoreCase('lessOrEqual')){
            if(value != null){
                 filterCondition += field + SPACECHAR + '<=' + SPACECHAR + value;
            }         
        } else if(operator.equalsIgnoreCase('greaterOrEqual')){
            if(value != null){
                 filterCondition += field + SPACECHAR + '>=' + SPACECHAR + value;
            }         
        }  
        return filterCondition;  
    }
    
    
     public static String parseCutsomFilters(String jsonString, Map<String, String> fieldTypeMap) {        
        if(String.isNotEmpty(jsonString)){    
            String queryString = '';
            String ESCAPECHAR = '\'';

            List<Object> filterList = (List<Object>)JSON.deserializeUntyped(jsonString);  //deserialized filter list  
            for(Object obj :filterList) {
                Map<String, Object> filterObj = (Map<String, Object>)obj;
                
                String filterType = (String)filterObj.get('type');
                String field = (String)filterObj.get('field');
                
     
                if(filterType.equalsIgnoreCase('string')) {
                    
                   
                    String filtervalue = (String)filterObj.get('value');
                    System.debug('###'+ filtervalue);
                    String textFilter = genStringFilters(filtervalue , field);
                    System.debug('@@@@' + textFilter);
                    if(String.isNotEmpty(textFilter)) {
                        
                        queryString += ' AND (' + textFilter + ' )';           
                    }
                    
                    /*System.debug(textFilter);
                    
                    
                    String startsWithRegex = '(?i)startswith\\(.+\\)'; 
                    String containsRegex = '(?i)contains\\(.+\\)'; 
                    String isEmptyRegex = '(?i)isempty';
                    String isNotEmptyRegex = '(?i)isnotempty';
                  
                    
                    
                    Pattern startsPattern = Pattern.compile(startsWithRegex);
                    Pattern containsPattern = Pattern.compile(containsRegex);
                    Pattern isEmptyPattern = Pattern.compile(isEmptyRegex);
                    Pattern isNotEmptyPattern =  Pattern.compile(isNotEmptyRegex);
                    
                    Matcher startsMatcher = startsPattern.matcher(filtervalue);
                    Matcher containsMatcher = containsPattern.matcher(filtervalue);
                    
                    String valueList;
                    if((valueList = parseORFilters(filtervalue)) != null) {
                         queryString += ' AND ' + field + ' IN ' + valueList ;        
                    } 
                    else if((valueList = parseExcludeFilters(filtervalue)) != null) {
                        queryString += ' AND ' + field + ' NOT IN ' + valueList ;        
                    }
                    else if (startsMatcher.matches()) {
                        filtervalue = filtervalue.ReplaceFirst('(?i)startswith\\(','');
                        filtervalue = filtervalue.subString(0, filtervalue.length() - 1);                      
                        queryString += ' AND ' + field + ' LIKE \'' + filtervalue + '%\''; 
                    } else if (containsMatcher.matches()){
                        filtervalue = filtervalue.ReplaceFirst('(?i)contains\\(','');
                        filtervalue = filtervalue.subString(0, filtervalue.length() - 1); 
                        queryString += ' AND ' + field + ' LIKE \'%' + filtervalue + '%\'';     
                    } else if ((isEmptyPattern.matcher(filtervalue)).matches()){
                         system.debug('EEEEMMMPP');
                         queryString += ' AND ' + field + ' = NULL' ;        
                    } else if ((isNotEmptyPattern.matcher(filtervalue)).matches()){
                         system.debug('NOT  EEEEMMMPP');
                         queryString += ' AND ' + field + ' != NULL' ;    
                    }else {
                        queryString += ' AND ' + field + ' LIKE \'%' + escapeSpecialChars((String)filterObj.get('value')) + '%\'';       
                    }
                    
                    parseORFilters(filtervalue); */
                } 
                
                else if(filterType.equalsIgnoreCase('list')) {
                    List<Object> valueList = (List<Object>)filterObj.get('value');
                    
                    if(valueList.size() > 1) {
                        String valueString = '';
                        
                        for(Object a : valueList) {
                            valueString += ESCAPECHAR + escapeSpecialChars((String)a) + ESCAPECHAR + ',';     
                        }
                        valueString = valueString.subString(0, valueString.length() - 1);
                        queryString += ' AND ' +  field + ' IN (' + valueString + ')';
                    
                    } else if(valueList.size() == 1){
                    
                        queryString += ' AND ' +  field + ' = ' + ESCAPECHAR  + escapeSpecialChars((String)valueList[0]) + ESCAPECHAR;    
                    }
                } 
                
                else if(filterType.equalsIgnoreCase('boolean')){
                    queryString += ' AND ' +  field + ' = ' + (Boolean)filterObj.get('value');  
                } 
                
                else if(filterType.equalsIgnoreCase('numeric')){
                    String compare =  (String)filterObj.get('comparison'); 
                    
                    if(compare.equals('eq')){
                        queryString += ' AND ' +  field + ' = ' + (integer)filterObj.get('value'); 
                        
                    } else if(compare.equals('lt')){
                         queryString += ' AND ' +  field + ' < ' + (integer)filterObj.get('value'); 
                        
                    } else if(compare.equals('gt')){
                        queryString += ' AND ' +  field + ' > ' + (integer)filterObj.get('value');    
                    }                    
                         
                }  else if(filterType.equalsIgnoreCase('currency')){
                    String compare =  (String)filterObj.get('comparison'); 
                    
                    if(compare.equals('eq')){
                        queryString += ' AND ' +  field + ' = ' + (Decimal)filterObj.get('value'); 
                        
                    } else if(compare.equals('lt')){
                         queryString += ' AND ' +  field + ' < ' + (Decimal)filterObj.get('value'); 
                        
                    } else if(compare.equals('gt')){
                        queryString += ' AND ' +  field + ' > ' + (Decimal)filterObj.get('value');    
                    }                    
                         
                } else if(filterType.equalsIgnoreCase('date')) {
                    
                    if(fieldTypeMap.containsKey(field)) {
                       String fieldType = fieldTypeMap.get(field); 
                         
                        if(fieldType.equalsIgnoreCase('datetime')) {
                            String compare =  (String)filterObj.get('comparison'); 
                            Date cdate = Date.parse((String)filterObj.get('value'));
                           
                           if(compare.equals('eq')){
                                Datetime beforedate = datetime.newInstanceGmt(cdate.year(), cdate.month(),cdate.day());
                                Datetime afterdate = beforedate.addDays(1);
                               
                                 
                                queryString += ' AND ' +  field + ' >= ' +  beforedate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); //beforedate.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
                                queryString += ' AND ' +  field + ' < ' +  afterdate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                                
                            } else if(compare.equals('lt')){
                                 Datetime beforedate = datetime.newInstanceGmt(cdate.year(), cdate.month(),cdate.day());
                                 queryString += ' AND ' +  field + ' < ' +  beforedate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                                
                            } else if(compare.equals('gt')){
                                Datetime afterdate = datetime.newInstanceGmt(cdate.year(), cdate.month(),cdate.day());
                                queryString += ' AND ' +  field + ' >= ' +   afterdate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');    
                            }  
                           
                        } else if(fieldType.equalsIgnoreCase('date')) {
                            String compare =  (String)filterObj.get('comparison'); 
                            Date cdate = Date.parse((String)filterObj.get('value'));
                            Datetime cdatetime =  datetime.newInstanceGmt(cdate.year(), cdate.month(),cdate.day());
                            
                            if(compare.equals('eq')){                                                                                               
                                queryString += ' AND ' +  field + ' = ' +  String.valueOf(cdate);
                              
                            } else if(compare.equals('lt')){
                                 Datetime beforedate = datetime.newInstanceGmt(cdate.year(), cdate.month(),cdate.day());
                                 queryString += ' AND ' +  field + ' < ' + String.valueOf(cdate);
                                
                            } else if(compare.equals('gt')){
                                Datetime afterdate = datetime.newInstanceGmt(cdate.year(), cdate.month(),cdate.day());
                                queryString += ' AND ' +  field + ' >= ' +  String.valueOf(cdate);   
                            }                         
 
                        }                   
                    }
                    
                } 
                
                   
            }  
            
            return queryString;          
        } 
        return null;  
    }
    
    
    /**** parse filter scope like mine or everthing ****/
    public static String parseFilterScope(String filterScope, String objectName) {
     
        Set<String> portalUser = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal', 'SelfService'};
        Set<String> internaluser = new Set<String>{'Standard'};
        
        String filterscopestr = '';
        
        if(String.isNotEmpty(filterScope)){
            if(filterScope.equalsIgnoreCase('Mine')){
                if(objectName.equalsIgnoreCase('Case')){
                    if(portalUser.contains(UserInfo.getUserType())){
                        String contactId = [Select Id,ContactId from User where Id = :UserInfo.getUserId() Limit 1].get(0).ContactId;
                        
                        filterscopestr = ' AND ContactId = \'' + contactId + '\''; 
                         
                    } else if(internaluser.contains(UserInfo.getUserType())){
                        filterscopestr = ' AND OwnerId = \'' + UserInfo.getUserId() + '\'';  
                    } 
               }      
            } else if(filterScope.Startswith('Queue-')){
                String[] queue = filterScope.split('-');
                
                if(queue.size() > 0 && String.isNotEmpty(queue[1])){
                    List<Group> queueList = [Select Id From Group where Type='Queue' and DeveloperName = :queue[1] Limit 1];    
                    
                    if(!queueList.isEmpty()){
                        filterscopestr = ' AND OwnerId = \'' + queueList[0].Id + '\'';     
                    }
                }            
            }       
            
            return filterscopestr;
        }
        
        return filterscopestr;
    }
    
    
    /*** parseORFilters - pasre OR(a,b,c) ***/
    public static String parseORFilters(String searchInput) {      
        String ESCAPECHAR = '\''; 
        Pattern ORPattern = Pattern.compile('^(?i)OR\\(.+?\\)$');
        Matcher matcher = ORPattern.matcher(searchInput);
        if(matcher.matches()){
        
            String ORstring = '(';
            List<String> valueList = searchInput.substring(3, searchInput.length() - 1) .split(',');
            for(String a : valueList){
                ORstring += ESCAPECHAR + String.escapeSingleQuotes(a).trim() + ESCAPECHAR + ',';              
            }
            ORstring =  ORstring.subString(0, ORstring.length() - 1) + ')';
            return ORstring;
        }
        return null;
          
    }
    
    /*** parseExcludeFilters - pasre NOT(a,b,c) ***/
   public static String parseExcludeFilters(String searchInput) {      
        String ESCAPECHAR = '\''; 
        Pattern ORPattern = Pattern.compile('^(?i)NOT\\(.+?\\)$');
        Matcher matcher = ORPattern.matcher(searchInput);
        if(matcher.matches()){
        
            String ORstring = '(';
            List<String> valueList = searchInput.substring(4, searchInput.length() - 1).split(',');
            for(String a : valueList){
                ORstring += ESCAPECHAR + String.escapeSingleQuotes(a).trim() + ESCAPECHAR + ',';              
            }
            ORstring =  ORstring.subString(0, ORstring.length() - 1) + ')';
            return ORstring;
        }
        return null;
          
    }
    
    public static string escapeSpecialChars(String input){
        if(String.isNotEmpty(input)){
            input = input.replace('\'','\\\''); 
            input = input.replace('%','\\%');  
            input = input.replace('_','\\_');         
        }  
        return input;      
    }
    
    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }  
    
    
   public static Boolean checkMetadataPermission() {
       MetadataService.MetadataPort service = MetadataUtility.createService();
      try {
          MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(26);
          return true;
      } catch(Exception e){
          return false;    
      }
   }
   
 
   
  
        
   public static Map<ID, IdeaTheme> getIdeaThemeList(Set<ID> ideaThemeIds){
       if(!ideaThemeIds.isEmpty()) {
           Map<ID, IdeaTheme> themeMap = new Map<ID, IdeaTheme>([SELECT Id, Title FROM IdeaTheme WHERE Id IN :ideaThemeIds]);
           return themeMap;
       }
       return null;
   }     
   
    public static String isRunningInSandbox() {
        String s  = System.URL.getSalesforceBaseUrl().getHost();
        if(Pattern.matches('(.*\\.)?cs[0-9]*(-api)?\\..*force.com',s)){
            // sandbox 
            return 'https://test.salesforce.com';   
        } else {
            // production
            return 'https://login.salesforce.com';
        }
    }   
   
   
        
        
    public class Stack {
        public integer top;
        public List<String> nodeList;
        
        public Stack() {
            top = -1;
            nodeList = new List<String>();   
        }
        
        public void push(String node){
            nodeList.add(node);
            top++;     
            System.debug('>>' + nodeList);   
        }
        
        
        public String pop(){
            String node = nodeList.remove(top);
            top--;
            return node;   
        } 
    }
    
    
    
}