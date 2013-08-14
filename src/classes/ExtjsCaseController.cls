public with sharing class ExtjsCaseController {

   public List<SelectOption> ListViewList{get;set;}
   public String selListView{get;set;}
   public String listViewFilter{get;set;}
   public String listViewScope{get;set;}
   public String collist{get; set;}
   
   public List<SelectOption> leftPickListValues{get; private set;}
   public List<SelectOption> rightPickListValues{get; private set;}
   public String getSelectedValues{get;set;}
   public Boolean isMetadataPermission{get; private set;}
   private Map<String, String> fieldLabelNameMap = new Map<String, String>();
   
   
    public ExtjsCaseController(ApexPages.StandardSetController controller) {
       Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
       ListViewList = new List<SelectOption>();     
       String selfilter;
       ID selfilterid;
       
       // use below if StandardSetController constructor is not used
       //ApexPages.StandardSetController setCon = new ApexPages.StandardSetContoller([SELECT Id, CaseNumber From Case LIMIT 1]);
       if(ApexPages.currentPage().getParameters().get('fcf') != null) {
           selfilterid = ID.valueOf(ApexPages.currentPage().getParameters().get('fcf')); 
       }      
       List<SelectOption> optionList = controller.getListViewOptions();
       List<String> availOptionList = new List<String>();    
       for(SelectOption sp :optionList){
           availOptionList.add(sp.getLabel()); 
           
           if(String.isNotEmpty(selfilterid)){
               if((ID)sp.getValue() ==  selfilterid) 
                   selfilter = sp.getLabel();  
           }              
       }   
       
       List<ListView__c> lwList = [SELECT Id, ListView_Label__c, Columns__c, 
                                        Filter_Criteria__c,Object_Name__c
                                        FROM ListView__c 
                                        WHERE Object_Name__c = 'Case' 
                                        and ListView_Label__c IN :availOptionList ORDER BY ListView_Label__c ]; 
                                        
       if(lwList.isEmpty()){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No public ListViews are available to current user'));
       } else {
              
           for(ListView__c lw :lwList){
               ListViewList.add(new SelectOption(lw.Id, lw.ListView_Label__c)); 
               if(selfilter != null && selfilter.equals(lw.ListView_Label__c)){
                   selListView =  lw.Id;   
               }    
           } 
           
           if(String.isEmpty(selListView)) {                    
               selListView = ListViewList.get(0).getValue(); 
           }                         
           retListView();
       } 
       
       isMetadataPermission = MetadataUtility.checkMetadataPermission();   
    }

   
   

   
   
   public ExtjsCaseController(){
      
   }
   
  
   
  
   
   public void retListView() {
        leftPickListValues = new List<SelectOption>();
        rightPickListValues = new List<SelectOption>();
       
        List<ListView__c> lwList = [SELECT Id, ListView_Label__c, Columns__c, 
                                        Filter_Criteria__c,Object_Name__c,
                                        FilterScope__c
                                        FROM ListView__c 
                                        WHERE Id = :selListView LIMIT 1];
                                
        if(!lwList.isEmpty()) {
            listViewFilter = lwList.get(0).Filter_Criteria__c;
            listViewScope = lwList.get(0).FilterScope__c;
            
            if(String.isNotEmpty(lwList.get(0).Columns__c)) {
                collist = describeFields('Case', lwList.get(0).Columns__c.split(',')); // describe fields to get field label
                getSelectedValues = collist;
                
                for(String a :collist.split(',')){
                    System.debug('>>>>' + a);
                    rightPickListValues.add(new selectOption(a, fieldLabelNameMap.get(a)));    
                }        
            }
        }                                
   } 
   
   
   
   public void goClick(){
       collist = '';
       System.debug('@@@@@@' + getSelectedValues); 
       if(String.isNotEmpty(getSelectedValues)){
           collist = getSelectedValues;  
           System.debug('>>' + collist);    
       } else {
           ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select at least one Column to Display'));    
       }   
   }
   
   
   // get field label and check its accessbility by current user
   public String describeFields(String objName,
                   List<String> fieldNames) {
                             
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No SObject named ' + objName + ' found'));   
             return null;
        }
        // TODO: check for accessibility as well
        Schema.SObjectType sobj = objTypeMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();
        // iterate, supplying meta information in format Ext likes 
        List<String> columnList = new List<String>();
       
       for (String field : fieldNames) {
            Schema.DescribeFieldResult dfr;
            String label;
            if(fieldMap.containsKey(field)) {
                dfr = fieldMap.get(field).getDescribe(); 
                
                if (dfr.isAccessible()){  // if field is accessibe add field to column list
                    label = dfr.getLabel();
                    columnList.add(field); 
                }
            }
             // check for user fields
            else if(field.containsIgnoreCase('Owner.') || field.containsIgnoreCase('CreatedBy.') || field.containsIgnoreCase('LastModifiedBy.')) {
               sobj =  objTypeMap.get('User');
               dfr  =  sobj.getDescribe().fields.getMap().get(field.subString(field.indexOf('.') + 1, field.length()) ).getDescribe();        
               
               if (dfr.isAccessible()) {              // if field is accessibe add field to column list
                   if(field.containsIgnoreCase('Owner.')){
                       label = 'Owner ' + dfr.getLabel(); 
                       fieldLabelNameMap.put(dfr.getLabel(), field);       
                   } else if(field.containsIgnoreCase('CreatedBy.')){
                       label = 'Created By' ;         
                   } else if(field.containsIgnoreCase('LastModifiedBy.')){
                       label = 'Last Modified By';      
                   } 
                   
                   columnList.add(field);
               } 
            }
            // check for record type fields
            else if(field.containsIgnoreCase('RecordType.')){
               sobj =  objTypeMap.get('RecordType');
               dfr  =  sobj.getDescribe().fields.getMap().get(field.subString(field.indexOf('.') + 1, field.length())).getDescribe();
               
               if (dfr.isAccessible()){   // if field is accessibe add field to column list
                   label = 'RecordType ' + dfr.getLabel(); 
                   columnList.add(field); 
               }
            } else if(field.indexOf('.') != -1) {  //stnadard field like Account.Name
                System.debug('REF::' + field);
                label = field.replaceFirst('\\.', ' '); // replace Account.Name with Account Name                 
                string relfield = field.split('\\.')[0] + 'Id';
              
                
                if(fieldMap.containsKey(relfield)){
                    dfr = fieldMap.get(relfield).getDescribe(); // check field accessibility 
                    if (dfr.isAccessible()){  
                         columnList.add(relfield + '-' +field);  // replace Account.Name with AccountId 
                         field =  relfield + '-' + field; 
                    } 
                }   
            } 
            /*else if(!fieldMap.containsKey(field)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No field named ' + field + ' found in SObject ' + objName));   
                return null;
            }*/ 
            fieldLabelNameMap.put(field, label);  
            dfr = null;
        }
        if(!columnList.isEmpty()){
            return (String.join(columnList, ','));
        }
        return null;
   
   }
   
       
   public PageReference gotoRefreshFilter() {
       PageReference page = new PageReference('/apex/RefreshFilterPage');
       page.setRedirect(true);
       return page;
   }
   
  
   
}