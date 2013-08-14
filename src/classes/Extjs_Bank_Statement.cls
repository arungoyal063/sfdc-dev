global with sharing class Extjs_Bank_Statement {

    global static String ObjectName;
    global static List<SelectOption> ListViewList;
    global static ListView__c selListView;
    
   
    // a class for supplying field property info to the VF component for use in setting up the grid
    global Extjs_Bank_Statement() {
    
    }
    global class FieldInfo {
        global String name;
        global Boolean modifiable;
        global Boolean sortable;
        global Boolean nillable;
        global Boolean filterable;
        global String fieldType;
        global String label;
        global List<List<String> > picklistValues;      // a list of string pairs as needed by picklist column editor
        global String relationName;
        global String relatedField; // get the relation name for parent field
        global Boolean relObjectAccess; // if related object is accessible or not
    }
    
   
    global class DescribeException extends Exception {}
    // get object metadata and supply to component
    @RemoteAction
    global static List<FieldInfo>
    describeFields(String objName,
                   List<String> fieldNames) {     
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
            throw new DescribeException('No SObject named ' + objName + ' found');
        }
        // TODO: check for accessibility as well
        Schema.SObjectType sobj = objTypeMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();
        // iterate, supplying meta information in format Ext likes
        List<FieldInfo> result = new List<FieldInfo>();
        for (String field : fieldNames) {
            FieldInfo fi = new FieldInfo();
            Schema.DescribeFieldResult dfr;
            String linkedField;  // ContactId- Contact.Name
            if(field.indexOf('-') != -1 && field.indexOf('.') != -1) {                
                linkedField = field.substring(field.indexOf('-') + 1, field.length()); 
                field = field.subString(0, field.indexOf('-'));   
            }
            
            if(fieldMap.containsKey(field)) {
                dfr = fieldMap.get(field).getDescribe(); 
                fi.label = dfr.getLabel();    
            }
             // check for user fields
            else if(field.containsIgnoreCase('Owner.') || field.containsIgnoreCase('CreatedBy.') || field.containsIgnoreCase('LastModifiedBy.')) {
               sobj =  objTypeMap.get('User');
               dfr  =  sobj.getDescribe().fields.getMap().get(field.subString(field.indexOf('.') + 1, field.length()) ).getDescribe();        
               if(field.containsIgnoreCase('Owner.')){
                   fi.label = 'Owner ' + dfr.getLabel();       
               } else if(field.containsIgnoreCase('CreatedBy.')){
                   fi.label = 'Created By';         
               } else if(field.containsIgnoreCase('LastModifiedBy.')){
                  fi.label = 'Last Modified By';      
               }
               
            }
            // check for record type fields
            else if(field.containsIgnoreCase('RecordType.')){
               sobj =  objTypeMap.get('RecordType');
               dfr  =  sobj.getDescribe().fields.getMap().get(field.subString(field.indexOf('.') + 1, field.length())).getDescribe();
               fi.label = 'RecordType ' + dfr.getLabel(); 
            } 
             
            
            else if(!fieldMap.containsKey(field)) {
                throw new DescribeException('No field named ' + field + ' found in SObject ' + objName);
            } 
            
            
            fi.name = field;
            fi.modifiable = dfr.isCreateable() | dfr.isUpdateable();
            fi.sortable = dfr.isSortable();
            fi.nillable = dfr.isNillable();
            fi.filterable = dfr.isFilterable();
            
            if(String.isEmpty(fi.fieldType)) {
                fi.fieldType = String.valueOf(dfr.getType()).toLowerCase();
            }
            
            if (dfr.getType() == Schema.DisplayType.Picklist) {
                fi.picklistValues = new List<List<String> >();
                for (Schema.PicklistEntry plv : dfr.getPicklistValues()) {
                    if (plv.isActive()) {
                        fi.picklistValues.add(new String[]{plv.getLabel(), plv.getValue()});
                    }
                }
                // add empty string option if nillable
                if (dfr.isNillable()) {
                    fi.picklistValues.add(new String[]{'None', ''});
                }
            } else if(dfr.getType() == Schema.DisplayType.Reference) {
                Schema.SObjectType relObject;
                String relfield;
                String member = '.';
                fi.relationName =  dfr.getRelationshipName();  // get relationship name
                relObject = dfr.getReferenceTo().get(0);       // get related object 
                Schema.DescribeSObjectResult relObjInfo = relObject.getDescribe();
                if(relObjInfo.isAccessible()){
                    fi.relObjectAccess = true;    
                } else {
                    fi.relObjectAccess = false; 
                }
                
                Map<String, Schema.SObjectField> relObjfieldMap = relObjInfo.fields.getMap();
                
                if(String.isNotEmpty(linkedField)) {
                    // for standard relationships;
                    fi.relatedField = fi.relationName + member + linkedField.split('\\.')[1];
                    fi.label = linkedField.replaceFirst('\\.', ' '); 
                } else {
                // for custom relationships
                // find primary field of an Sobject
                    if(relObjfieldMap.containsKey('Name')){ 
                        relfield =  'Name';     
                    } else if(relObjfieldMap.containsKey('Title')) { 
                        relfield =  'Title'; 
                    } else if(relObjfieldMap.containsKey('CaseNumber')) { 
                        relfield =  'CaseNumber';        
                    }
                    fi.relatedField =  fi.relationName + member + relfield; 
                    
                    if(!dfr.isCustom()){
                        if(relfield == 'Name') {
                            fi.label = dfr.getRelationshipName()  + ' ' + relfield;  
                        }  else {
                            fi.label = dfr.getRelationshipName();    
                        }
                    } else {
                        fi.label = dfr.getLabel(); 
                    }         
                }
                     
            }
            result.add(fi);
            dfr = null;
        }
   
        return result;
    }

    // a user-defined class that will serialize to the JSON expected by the ExtJS DirectProxy api methods
  
    global class CRUDResponse {
        global Boolean success;
        global String errorMessage;
        global List<SObject> records;
        global Integer total;
        CRUDResponse() {
            records = new List<SObject>();
            success = true;
        }
    }
    
    // Unfortunately JS Remoting member functions must be static, so cannot access non-static class members,
    // which means we cannot cache query results in this controller but must respond to each request anew
    
    
    global class QueryObj {
        global String sobjname;
        global String fields;
        global Map<String, String> fieldTypeMap;
        global String queryfilter;
        global String queryscope;
        global Integer start;
        global Integer recordCount;
        global String filter;     // json filter string
        global List<Map<String, String> > sortParams;
    }

    // turn grid's page load/sort request into SOQL and return data
    @RemoteAction @readOnly
    global static CRUDResponse query(QueryObj qobj) {
        CRUDResponse resp = new CRUDResponse();
        String gridFilter = '';
        String totalFilter = '';
        
        /* parse filter scope */
        String filterScope = MetadataUtility.parseFilterScope(qobj.queryscope, qobj.sobjname);
        /* parse filter scope */
        
        /* parse json filter */    
            if(qobj.filter != null){
                gridFilter = MetadataUtility.parseCutsomFilters(qobj.filter, qobj.fieldTypeMap); 
                System.debug('USER FILTER ::' + gridFilter);  
                 System.debug('USER FILTER--->>>>>>>qobj.filter ::' + qobj.filter);  
                 System.debug('USER FILTER--->>>>>>>qobj.fieldTypeMap ::' + qobj.fieldTypeMap); 
            }      
        /* parse json filter */
        
        /* add listview and grid filter */
         if(String.isNotEmpty(qobj.queryfilter)){
            
                if(String.isNotEmpty(gridFilter)) {
                    totalFilter += ' WHERE (' + qobj.queryfilter + ')' + filterScope + gridFilter;
                } else { 
                    totalFilter += ' WHERE ' + qobj.queryfilter + filterScope; 
                } 
          } else if(String.isNotEmpty(gridFilter)){              
              totalFilter += ' WHERE ' + gridFilter.subString(4, gridFilter.length()) + filterScope; 
          } else if(String.isNotEmpty(filterScope)){
              totalFilter += ' WHERE ' +  filterScope.subString(4, filterScope.length());
          } 
         /* add listview and grid filter  */
           
        /* Create paging response */ 
        try {
            String countQuery = 'SELECT COUNT() FROM ' + qobj.sobjname + totalFilter + ' Limit 100000' ;         
            System.debug('countQuery >>>' + countQuery); 
            resp.total = Database.countQuery(countQuery);
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        /* Create paging response */
        
       
     
        // Sobject Query 
        String qstr = 'SELECT ' + qobj.fields + ' FROM ' + qobj.sobjname;
        
        // Query Filter
        if (String.isNotEmpty(totalFilter)){
            qstr += totalFilter;    
        }
      
       if (qobj.sortParams != null) {
            qstr += ' ORDER BY ';
            // collect sort fields/directions
            qstr += qobj.sortParams[0].get('property');
            for (Integer i = 1; i < qobj.sortParams.size(); i++) {
                qstr += ',' + qobj.sortParams[i].get('property');
            }
            // SOQL only supports a single direction, so ignoring others. Probably should return error instead.
            qstr += ' ' + qobj.sortParams[0].get('direction');
            qstr += ' NULLS LAST';

        }       
        System.debug('Query>>>>>' + qstr);       
        qstr +=  ' Limit 100000';
        
        try {
            
            integer counter  = 1;
            for (List<SObject> rlit : Database.query(qstr)) {
                
                if(counter + rlit.size() <= qobj.start) {
                    counter = counter + rlit.size();
                    continue;
                } 
                 
                           
                for (SObject rit : rlit) {
                    
                        if(counter > qobj.start && counter <= (qobj.start + qobj.recordCount)) { 
                             resp.records.add(rit);
                        }
                     
                     counter ++;
                     if(counter > (qobj.start + qobj.recordCount)){
                         break;
                     }
                }
                
                 if(counter > (qobj.start + qobj.recordCount)){
                         break;
                 }
                
            }
                                                 
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

   
    

   
    // C,U,D methods from DirectProxy all have the same argument format:
    global class CRUDData {
        global String sobjname;
        global String fields;
        global String oppId;
        global String parentFieldName;
        global List<Map<String, String> > records;
    }

    // Utility method to refresh newly created/updated objects after the DML operation, for returning to the grid
   global static CRUDResponse refreshObjects(CRUDData crudData, List<SObject> sobjs) {
        CRUDResponse resp = new CRUDResponse();

        String objName = crudData.sobjname;
        String fieldList = crudData.fields;
        String[] fieldNames = fieldList.split(',');
        Set<ID> updatedIds = new Set<ID>();
        for (SObject sobj : sobjs) {
            updatedIds.add(sobj.id);
        }
        for (List<SObject> rlit : Database.query('SELECT ' + fieldList + ' FROM ' + objName +
                                                 ' WHERE Id IN :updatedIds')) {
            for (SObject rit : rlit) {
                resp.records.add(rit);
            }
        }
        return resp;        
    }
    

    // Create and Update are very similar.
    // Create supplies all specified fields but no Id; Update specifies Id and only the fields that changed
   /*  @RemoteAction
    global static CRUDResponse create(CRUDData crudData) {
        CRUDResponse resp = new CRUDResponse();
        List<SObject> sobjs = unpackSobjects('create', crudData, resp);
        if (!resp.success) {
            return resp;
        }

        try {
            insert sobjs;
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = 'create: insert failed with error ' + e.getMessage();
            return resp;
        }

        return refreshObjects(crudData, sobjs);
    }

    // "update" and "delete" are keywords so must pick something else
    // Ken Thompson is supposed to have said that if he could redo anything about Unix,
    // he'd spell "creat" with an extra "e".  So in that spirit:
   @RemoteAction
    global static CRUDResponse updat(CRUDData crudData) {
        CRUDResponse resp = new CRUDResponse();
        List<SObject> sobjs = unpackSobjects('update', crudData, resp);
        if (!resp.success) {
            return resp;
        }

        try {
            update sobjs;
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = 'update: failed with error ' + e.getMessage();
            return resp;
        }

        return refreshObjects(crudData, sobjs);
    }
    
    @RemoteAction
    global static CRUDResponse delet(CRUDData crudData) {
        CRUDResponse resp = new CRUDResponse();

        // produce a list of IDs from each supplied sObject
        List<Map<String, String> > sobjs = crudData.records;
        List<String> idlist = new List<String>();
        for (Map<String, String> sobj : sobjs) {
            idlist.add(sobj.get('Id'));
        }
        
        try {
            Database.delete(idlist);
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = 'delete: failed with error ' + e.getMessage();
        }
        
        return resp;
    }

    // utility functions
    
    // create, update, and delete all supply things that resemble SObjects
    // (although update only has changed fields and delete only has IDs)

    // this method may seem a bit redundant when Remoting can now accept SObjects.  There are two important
    // things we do here that can't be done just by accepting List<sObject> in our methods:
    // 1) a generic sObject (not created from a describe "token") and without an Id cannot be used in DML,
    //    so we have to generate a new sObject anyway for "create" operations
    // 2) There is something funny about Date fields - I haven't been able to find a format
    //    that the server will accept.  A plain Date parameter can be supplied via UTC string, but
    //    one that is a field inside an SObject gives problems.  Converting from a string works fine though.
    
    
   static List<SObject> unpackSobjects(String action, CRUDData crudData, CRUDResponse resp) {
        resp.success = false;

        // use "base" params to find the sobject type we need to create
        if (crudData.sobjname == null) {
            resp.errorMessage = 'SObject name not supplied in client call';
            return null;
        }
        String objName = crudData.sobjname;
        String oppId = crudData.oppId;
        String parentField = crudData.parentFieldName;
        
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
            resp.errorMessage = 'No SObject named ' + objName + ' found';
            return null;
        }
        Schema.SObjectType sobjToken = objTypeMap.get(objName);  // "token" representing this sObject type
        Map<String, Schema.SObjectField> fieldMap = sobjToken.getDescribe().fields.getMap();
        
        if (crudData.records == null) {
            resp.errorMessage = 'argument ' + crudData + ' contained no records field';
            return null;
        }
        
        List<Map<String, String> > records = crudData.records;
        List<SObject> sobjs = new List<SObject>();
        
        for (Map<String, String> recmap : records) {
            SObject sobj;
            if (recmap.containsKey('Id')) {
                // create SObject using supplied Id (setting it as a field will fail)
                sobj = sobjToken.newSObject(recmap.get('Id'));
            } else {
                sobj = sobjToken.newSObject();
            }
            
            for (String k : recmap.keySet()) {
                // definitely an empty value if null, empty string, or the string 'null' but the type is not string
                // TODO it does seem like I should be able to map 'null' to null somehow in mapUnpack()
                Boolean emptyValue = (recmap.get(k) == null) || (recmap.get(k) == '') ||
                                      (fieldMap.get(k).getDescribe().getType() != Schema.DisplayType.string) &&
                                      (recmap.get(k) == 'null');
                if ((k != 'Id') &&  // never try to set Id this way (see above)
                    ((action == 'update') || // don't try to set an empty value unless this is an update
                     !emptyValue)) {
                    if (emptyValue) {
                        sobj.put(k, null);
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.date) {
                        // Date fields appear to need to be set from Date values, not strings, so:
                        sobj.put(k, Date.valueOf(recmap.get(k)));
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.boolean) {
                        sobj.put(k, Boolean.valueOf(recmap.get(k)));
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.integer) {
                        sobj.put(k, Integer.valueOf(recmap.get(k)));
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.double) {
                        sobj.put(k, Double.valueOf(recmap.get(k)));
                    }else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.Currency) {
                        sobj.put(k, Decimal.valueOf(recmap.get(k)));
                    } else {
                        sobj.put(k, recmap.get(k));
                    } // TODO: handle other types, esp. Currency
                    //sobj.put('Opportunity__c', crudData.oppId); 
                    if(action == 'create') {
                        sobj.put(parentField , crudData.oppId);
                    }
                }
            }
            sobjs.add(sobj);
        }
        resp.success = true;
        return sobjs;
    } */
}