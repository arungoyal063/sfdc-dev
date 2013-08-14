/*----------------------------------------------------------------------------------------------------------------------------
// Project Name...........: <<Ellucian>>
// File...................: <<CreateCROnIdea>> 
// Version................: <<1.0>>
// CreatedBy..............: <<musman@rainmaker-llc.com>>
// Created Date...........: <<4-12-2012>>
// Last Modified Date.....: <<6-12-2012>>
// Description/Requirement: <<Create Change request by Idea>>
//---------------------------------------------------------------------------------------------------------------------------*/

public with sharing class CreateCROnIdea {
   
    public Change_Request__c crObj;
    public Idea ideaObj;
    public String ideaId;  
    public Associated_Case_Change_Request__c assoInsertObj {get; set;}
    public String paramStr{get; set;}
    private Map<String, String> fieldValueMap;
    private RecordType rdData;
    
  public CreateCROnIdea(ApexPages.StandardController stdController)
  {
    paramStr = '';
    fieldValueMap = new Map<String, String>(); 
    ideaId = ApexPages.currentPage().getParameters().get('ideaID');
    rdData = [Select Id,Name from RecordType WHERE  Name = 'Enhancement' and SobjectType = 'Change_Request__c']; 
     
    if(ideaId != '' && ideaId != null)
    {
         createFieldMapping(ideaId);
         Map<String, String> CRFieldMap = getFieldsIdsMap('Change_Request__c');
         CRFieldMap.put('RecordType','RecordType');
         CRFieldMap.put('ent','ent');
         
         for(String fieldLabel : CRFieldMap.keySet()) {
               String value = getDefaultValue(fieldLabel);
               if (value != null) {
                   paramStr = paramStr + '&' + CRFieldMap.get(fieldLabel) + '=' + value; 
               }     
               String lkidLabel = fieldLabel + '_lkid';
               String lkidvalue = getDefaultValue(lkidLabel);
               if (lkidvalue != null) {
                   paramStr = paramStr + '&' + CRFieldMap.get(fieldLabel) + '_lkid=' + lkidvalue; 
               }   
          }
            
    } 
      
  }
  
  
   private String getDefaultValue(String fieldName) {
        if(fieldName != null && fieldValueMap.containsKey(fieldName)) {           
            return fieldValueMap.get(fieldName);
        }   
        return null;   
   }
  
  
  
 public void createFieldMapping(String ideaId) {
       fieldValueMap = new Map<String, String>(); 
       DescribeFieldResult f;
       
       try {
           if(ideaId != '' && ideaId != null) {  
                
               List<Idea> ideaList = [Select Id, Body , Idea_Product__c, Idea_Product__r.Name, Case__c, Case__r.CaseNumber, Change_Request__c, Module_New__c,  Institution__c, Institution__r.Name, Status, Title, Business_Purpose__c from Idea WHERE  Id =: ideaId];
               
               if(!ideaList.isEmpty())  {
                   RecordType rdData = [Select Id, Name from RecordType WHERE  Name = 'Enhancement' and SobjectType = 'Change_Request__c'];
                   ideaObj = ideaList.get(0);
                    if(rdData != null) {
                        fieldValueMap.put('RecordType',rdData.Id);
                        fieldValueMap.put('ent','01IZ00000004YPO');
                    }
                    
                    if(ideaObj.Module_New__c != null) {
                        f = Change_Request__c.Module__c.getDescribe();
                        fieldValueMap.put(f.getLabel(), ideaObj.Module_New__c);
                    }
                    
                   /*if(ideaObj.Version__c != null) {
                        f = Change_Request__c.Found_in_Version__c.getDescribe();
                        fieldValueMap.put(f.getLabel(), ideaObj.Version__r.Name);
                        fieldValueMap.put(f.getLabel()+ '_lkid'.trim(), ideaObj.Version__c);                    
                    } */
                    
                    if(ideaObj.Title != null) {
                        //f = Change_Request__c.Originating_Idea_v2__c.getDescribe();
                        f = Change_Request__c.Originating_Idea__c.getDescribe();
                        fieldValueMap.put(f.getLabel(), ideaObj.Title);
                        fieldValueMap.put(f.getLabel()+'_lkid', ideaObj.Id);
                    }
                    
                    if(ideaObj.Institution__r.Name != null) {
                        f = Change_Request__c.Account_Name__c.getDescribe();
                        fieldValueMap.put(f.getLabel(), ideaObj.Institution__r.Name);
                        fieldValueMap.put(f.getLabel()+'_lkid', ideaObj.Institution__c);
                    }
                   
                    if(ideaObj.Idea_Product__r.Name != null) {
                        f = Change_Request__c.Product__c.getDescribe();
                        fieldValueMap.put(f.getLabel(), ideaObj.Idea_Product__r.Name);
                        fieldValueMap.put(f.getLabel()+'_lkid', ideaObj.Idea_Product__c);
                    }
                   
                    if(ideaObj.Case__c != null) {
                        f = Change_Request__c.Originating_Case__c.getDescribe();
                        fieldValueMap.put(f.getLabel(), ideaObj.Case__r.CaseNumber);
                        fieldValueMap.put(f.getLabel()+'_lkid', ideaObj.Case__c);
                    }  
                    
                    if(ideaObj.Business_Purpose__c != null) {
                        f = Change_Request__c.Business_purpose__c.getDescribe();
                        fieldValueMap.put(f.getLabel(), ideaObj.Business_Purpose__c);
                    }  
                   
                    String sw = ideaObj.Body; 
                    if(sw != null) {   
                           sw = sw.replaceAll('<[^>]+>','');
                           if(sw.trim().length() > 255) {
                              sw = sw.trim().subString(0,255);
                           }               
                    }      
                   String descStr = 'Title: '+ ideaObj.Title ;
                   
                   if(sw != null) {
                       descStr = descStr + '\nBody:' + sw;
                       //for encode the special character ---- //START added for ISSUE#305 CR Not Creating Correctly From Ideas
                       descStr = EncodingUtil.urlEncode(descStr, 'UTF-8');
                   }
                   
                   f = Change_Request__c.Description__c.getDescribe();
                   fieldValueMap.put(f.getLabel(), descStr);     
             }
           }
       } catch(Exception e) {
           System.debug('Error ::' + e);
       }
 }
  
   private  map<String, String> getFieldsIdsMap(String sObjectName) { 
        map<String, String> label_IdMap = new map<String, String>();
        if(null!= sObjectName && sObjectName.trim() != '') {
            PageReference p = new PageReference('/' +  Schema.getGlobalDescribe().get(sObjectName).getDescribe().getKeyPrefix() + '/e?RecordType='+ rdData.Id + '&ent=01IZ00000004YPO&nooverride=1');
            String html = '';
            if(!Test.isRunningTest()) {
                html = p.getContent().toString();
            } else {
                html = '<label for="test"><span class="requiredMark"></span> </label>';  
            }
            Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
            while(m.find()) {
                String label = m.group(3);
                String id = m.group(1);
                label_IdMap.put(label, id);
            }
        }
        return label_IdMap;
    }
    
  
  public Pagereference RedirectToCR() {
     //paramStr = '/' + Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1&retURL=%2Fa0G%2Fo' + paramStr;
     if(ideaId != '' && ideaId != null){
     	paramStr = '/' + Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1&retURL=%2F'+ideaId + paramStr;
     }
     else{
     	paramStr = '/' + Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1&retURL=%2F087' + paramStr;
     }
     System.debug('$$$' + paramStr);
     Pagereference pageRef = new Pagereference(paramStr);
     pageRef.setRedirect(true);
     return pageRef;     
  }  
  
}