global class batchClassArticle implements Database.batchable<FAQ__kav>{ 
   Map<String,Schema.SObjectField> fields{get;set;}
   public string APIobjectName{get;set;}
   public List<FieldInfo> dynamicFields{get;set;}
   public List<FieldInfo> dynamicAttachmentFields{get;set;}
   public List<FieldInfo> dynamicAdditionalEmailFields{get;set;}
   public transient Sobject record{get;set;}
   private Set<String> excludedFields = new Set<String>(); 
   private Map<String,Integer> displayFields = new Map<String,Integer>();
   private Map<String,Integer> extraEmailFields = new Map<String,Integer>();
   global Iterable<FAQ__kav> start(Database.batchableContext info){ 
       return new fooArticle(); 
   }     
   global void execute(Database.batchableContext info, List<FAQ__kav> scope){ 
       List<FAQ__kav> faqList = new List<FAQ__kav>(); 
       /*for(Account a : scope){ 
           a.Name = 'true'; 
           a.NumberOfEmployees = 69; 
           accsToUpdate.add(a); 
       } 
       update accsToUpdate; */
       system.debug(scope);
       //faqList.add(scope); 
        Set<Id> articleId = new Set<Id>();
   for(sObject a : scope){ 
        FAQ__kav fq = (FAQ__kav)a;
        articleId.add(fq.KnowledgeArticleId);   
   }
   system.debug(articleId);
   List<EntitySubscription> entityList = [SELECT Id, ParentID, SubscriberId, subscriber.id FROM EntitySubscription WHERE ParentId IN: articleId LIMIT 200]; 
   Set<Id> userId = new Set<Id>();
   for(EntitySubscription ent : entityList){
       userID.add(ent.SubscriberId);
   }
   List<User> u = [Select Id, Email FROM User WHERE Id IN: userId];
   Map<Id,String> userEmail = new Map<Id,String>();
   
   for(User cu: u){
       userEmail.put(cu.Id,cu.Email);
   }
   
   Map<Id,List<String>> artFollower = new Map<Id,List<String>>();
   
   for(Id art : articleId){
      List<String> eml = new List<String>();
      for(EntitySubscription ent : entityList){
          if(ent.ParentId == art)
              eml.add(userEmail.get(ent.SubscriberId));
      }
      artFollower.put(art,eml);
   
   }  
   
       //Set up fields to be displayed and emailed
        displayFields.put('Solution Details',1);
        //displayFields.put('Legacy Article Number',2);
        displayFields.put('Type',3);
        displayFields.put('Partner',4);
        displayFields.put('Partner Article ID',5);
        displayFields.put('Attachment 1 (Name)',6);
        displayFields.put('Attachment 2 (Name)',7);
        displayFields.put('Attachment 3 (Name)',8);
        displayFields.put('Attachment 4 (Name)',9);
        displayFields.put('Attachment 5 (Name)',10);
        //Set up additional fields for email only (not displayed or displayed in the knowledge article bar)
        extraEmailFields.put('First Published Date',0);
        extraEmailFields.put('Last Modified Date',1);
        extraEmailFields.put('Last Published Date',2);
        extraEmailFields.put('Article Number',3);
        extraEmailFields.put('Summary',4);
        extraEmailFields.put('Products',5);
      //Excluded fields
        excludedFields.add('ViewScore');
        excludedFields.add('VoteScore');
        excludedFields.add('IsMasterLanguage');
        excludedFields.add('MasterVersionId');
     APIobjectName = 'FAQ__kav';
     string query = 'SELECT ';
        for (string s: GetDBFieldNames(APIobjectName)) //Also populates Fields Listing
        {
            if (!excludedFields.contains(s))// && s.contains('__c'))
            {
                query+= APIobjectName+'.'+s+',';
            }
        }
        //Remove last instance of comma
        query = query.substring(0,query.length()-1);
        query += ' FROM '+APIobjectName+' WHERE KnowledgeArticleId In: articleId AND PublishStatus=\'online\'';
        System.debug(query);
        try
        {
            //record = database.query(query);
            record = scope[0];
        }
        catch (Exception ex)
        {
            System.debug(ex.getmessage());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getmessage()));
        }
        dynamicFields = new List<FieldInfo>();
        dynamicAttachmentFields = new List<FieldInfo>();
        dynamicAdditionalEmailFields = new List<FieldInfo>();
        
        Set<String> fileFields = new Set<String>();
        
        for(Schema.SObjectField f:fields.values())
        {               
            if (displayFields.keySet().contains(f.getDescribe().getLabel()))
            {
                Integer displayOrder = displayFields.get(f.getDescribe().getLabel());
                if (f.getDescribe().getLabel().toLowerCase().contains('attachment'))
                  dynamicAttachmentFields.add(new FieldInfo(f,displayOrder));
                else
                  dynamicFields.add(new FieldInfo(f,displayOrder));
            }
            if (extraEmailFields.keySet().contains(f.getDescribe().getLabel()))
            {
                Integer displayOrder = extraEmailFields.get(f.getDescribe().getLabel());
                dynamicAdditionalEmailFields.add(new FieldInfo(f,displayOrder));
            }                   
            //dynamicFields.add(new FieldInfo(f,0));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,f.getDescribe().getLabel()+' '+string.valueOf(f.getDescribe().getType())));
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Dynamic Fields '+dynamicFields));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Dynamic Attachment Fields '+dynamicAttachmentFields));
        //Sort Display Listing
        dynamicFields.sort();
        dynamicAttachmentFields.sort();
        dynamicAdditionalEmailFields.sort();
        
        //Create Email Attachments
        List<Messaging.Emailfileattachment> attachments = new List<Messaging.Emailfileattachment>();
        
        //Set<String> fileFields = new Set<String>();
        
        for (Schema.SObjectField f:fields.values())
        {
            if (string.valueOf(f.getDescribe().getType()) == 'BASE64')
            {
                //We've identified a fiel field - add the name to the fileFieldListing
                if (!fileFields.contains(f.getDescribe().getLabel()))
                    fileFields.add(f.getDescribe().getName().remove('__Body__s').trim());
            }
        }
        //Now that we have a set of the Attachment Database Names - Create attachments dynamically
        for (string s: fileFields)
        {
            try
            {
                if (record.get(s+'__Body__s') != null) //Attachment Exists
                {
                    Messaging.Emailfileattachment temp = new Messaging.Emailfileattachment();
                    temp.setFileName(string.valueOf(record.get(s+'__Name__s')));
                    temp.setBody((blob)record.get(s+'__Body__s'));
                    temp.setContentType(string.valueOf(record.get(s+'__ContentType__s')));
                    temp.setInline(false); 
                    system.debug(temp);
                    attachments.add(temp);      
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Valid Attachment found: '+s));
                }
            }
            catch (Exception ex)
            {
                System.debug(ex.getMessage());
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
            }
        } 
        //List<String> emailsStr = new List<String>();
        List<String> emailsStr = artFollower.get((Id)record.get('KnowledgeArticleId'));
        emailsStr.add('musman@rainmaker-llc.com');
        emailsStr.add('agupta@rainmaker-llc.com');
        system.debug(emailsStr);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'actionline@ellucian.com'];
        CaseCommentEmail__c customSetting = CaseCommentEmail__c.getValues('default');
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        
      for(EntitySubscription sub : entityList)
      {      
        //Create Email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //User
        message.setTargetObjectId(sub.subscriber.id);
        //message.setToAddresses(emailsStr);
        //message.setToAddresses('agupta@rainmaker-llc.com');
        //Subject
        //String subjectLine = '*** From Ellucian: Article ';
         String subjectLine = 'Article ' + record.get('ArticleNumber') + ' Has Been Updated';
        //if (ArticleNumber != null && ArticleNumber != '')
        //    subjectLine += ArticleNumber;
        //if (LegacyArticleNumber != null && LegacyArticleNumber != '' && LegacyArticleNumber != 'null')
          //  subjectLine += ' / Legacy Article '+LegacyArticleNumber;
        message.setSubject(subjectLine);
        //message.setSubject(ArticleTitle);
        //Set body to Page Contents     
        //Pagereference pageContents = ApexPages.currentPage();
        String HTML = '';
        String Plain = '';
        //Add in Link to the Article
        //Create the URL
        String URL_Link = URL.getSalesforceBaseUrl().toExternalForm();
        try
        {
            URL_Link += '/clients/articles/'+APIobjectName.replace('__kav','')+'/'+record.get('UrlName');
        }
        catch (Exception ex)
        {
            System.debug(ex.getmessage());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
        }
        //HTML += subjectLine.replace('*** From Ellucian: ','')+' <a href="'+URL_Link+'" target="_blankPage">(Click here to view Article in the Support Center)</a><br></br>';
        //Plain += subjectLine.replace('*** From Ellucian: ','')+' Link to Knowledge Article: '+URL_Link+'\r\n';
        //Extra Line Break
        HTML += '<br></br>';
        Plain += '\r\n';

        //Add in the rest of the page data
        Integer counter = 0;
        for (FieldInfo fi:dynamicFields)
        {
            try
            {
                if (record.get(fi.APIName) != null)
                {
                    if (counter == 0)
                    {
                        //HTML +=  '<p style="text-decoration:underline">'+fi.Label+'</p><br></br>'+string.ValueOf(record.get(fi.APIName))+'<br></br><br></br>';
                        HTML +=  '<br></br>'+string.ValueOf(record.get(fi.APIName))+'<br></br><br></br>';
                        HTML +=  '_____________________________________________________________________________________<br></br>';
                        Plain += fi.Label+': '+string.ValueOf(record.get(fi.APIName))+'\r\n';
                    }
                    else
                    {
                        HTML +=  fi.Label+': '+string.ValueOf(record.get(fi.APIName))+'<br></br>';
                        Plain += fi.Label+': '+string.ValueOf(record.get(fi.APIName))+'\r\n';
                    }
                    counter++;
                }
            }
            catch (Exception ex)
            {
                System.debug(ex.getmessage());
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
            }
        }
        //Extra Line Break
        HTML += '<br></br>';
        Plain += '\r\n';
        
        //Add in Metadata
        HTML += '=====================================================================================<br></br>';
        Plain += '=====================================================================================\r\n';
        HTML += '<table>';
        for (FieldInfo fi:dynamicAdditionalEmailFields)
        {
            try
            {
                HTML += '<tr><td>'+fi.Label+':</td><td>'+string.ValueOf(record.get(fi.APIName))+'</td></tr>';
                Plain += fi.Label+': '+string.ValueOf(record.get(fi.APIName))+'\r\n';
            }
            catch (Exception ex)
            {
                System.debug(ex.getmessage());
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
            }
        }
        //Create Article Audience Information
        //Retrieve from the DataCategory Selection
        List<Sobject> datacats = new List<Sobject>();
        string articleDataCategory = APIobjectName.remove('__kav');
        articleDataCategory += '__DataCategorySelection';
        Id RecordId;
        try
        {
            RecordId = (Id)record.get('Id');
        }
        catch (Exception ex){}
        string dataQuery = 'SELECT DataCategoryName, DataCategoryGroupName FROM '+articleDataCategory+' WHERE ParentId=:RecordId';
        datacats = database.query(dataQuery);       
        for (Sobject sobj:datacats)
        {
            try
            {
                HTML += '<tr><td>'+string.valueOf(sobj.get('DataCategoryGroupName')).replace('_',' ')+':</td><td>'+string.valueOf(sobj.get('DataCategoryName')).replace('_',' ')+'</td></tr>';
                Plain += string.valueOf(sobj.get('DataCategoryGroupName')).replace('_',' ')+': '+string.valueOf(sobj.get('DataCategoryName')).replace('_',' ')+'\r\n';
            }
            catch (Exception ex)
            {
                System.debug(ex.getmessage());
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
            }
        }
        
        HTML += '</table>';
        
        
        
        HTML += '=====================================================================================<br></br>';
        Plain += '=====================================================================================\r\n';
        HTML += '<br></br>';
        Plain += '\r\n';
        
        
        
        message.setHtmlBody(HTML);
        message.setPlainTextBody(Plain);
        //Save As Activity Flag
        message.setSaveAsActivity(false);
        
        //Attachments if available
        if (!attachments.isEmpty())
            message.setFileAttachments(attachments);
        
        if (owea.size() > 0 ) {
            message.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{ message.setSenderDisplayName(customSetting.From_Name__c);}
        listmail.add(message);
        //Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{ message };
        
      }  
      if(!listmail.IsEmpty()){
        Messaging.SendEmailResult[] results = Messaging.sendEmail(listmail);
        if (results[0].isSuccess())
        {
            System.debug('Email Sent Successfully');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Email Sent Successfully'));
            //PageMessage = 'Email Sent Successfully';
        } 
        else
        {
            System.debug('Error Sending Email!');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Error Sending Email!'));
            //PageMessage = 'Error Sending Email!'+results[0].getErrors();
        }
      }   
         System.debug('this is test');

   }     
   global void finish(Database.batchableContext info){     
   }
   public String ArticleNumber
    {
        get
        {
            for(Schema.SObjectField f:fields.values())
            {
                if (f.getDescribe().getLabel() == 'Article Number')
                {
                    try
                    {
                        return string.valueOf(record.get(f.getDescribe().getName()));
                    }
                    catch (Exception ex){return '';}
                }
            }
            return '';
        }
        set;
    }

/****************************************** Utilities ********************************************************/  
  
//JGP 1/30/2013 Added functionality to dynamically retrieve Account Fields  
  private List<String> GetDBFieldNames(String objectname)
  {
    List<String> retval = new List<String>();
    //Use GlobalDescribe to get a list of all available Objects
    Map<String,Schema.Sobjecttype> gd = Schema.getGlobalDescribe();
    Set<String> objectKeys = gd.keySet();
    for (String objectKey:objectKeys) //Iterate through all of the objects until we get to the one we need
    {
        if (objectKey == objectname.toLowerCase()) //Object exists, get field names
        {
            Schema.SObjectType systemObjectType = gd.get(objectKey);
            Schema.DescribeSObjectResult r = systemObjectType.getDescribe();
            Map<String, Schema.SObjectField> M = r.fields.getMap();
            Set <String>fieldNames = M.keySet();
            fields = new Map<String,Schema.SObjectField>();
            //Create a copy of the Map with the Display Name, and Properties for retreival in the Selection
            for (String fieldName:fieldNames)
            {
                //For each field, Add to List
                Schema.SObjectField field = M.get(fieldName);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();                                     
                //retval.add(fieldDesc.getLabel()); //Adds the Salesforce UI label to listing
                retval.add(fieldDesc.getName());
                if (!excludedFields.contains(fieldDesc.getName()))// && fieldDesc.getName().contains('__c'))
                    fields.put(fieldDesc.getLabel(),field);
            }
         }
       }                               
    return retval;
    }
    
     public class FieldInfo Implements Comparable
    {
        public string Label{get;set;}
        public string APIName{get;set;}
        public Integer displayOrder{get;set;}
        public string FileAPIName{get;set;}
        public FieldInfo(Schema.SObjectField f, Integer displayorder)
        {
            this.Label = f.getDescribe().getLabel();
            this.APIName = f.getDescribe().getName();
            if (f.getDescribe().getName().contains('__Name__s'))
            {
              FileAPIName = f.getDescribe().getName().remove('__Name__s').trim()+'__Body__s';
            }
            this.displayOrder = displayorder;
        }
        public Integer compareTo(Object compareTo)
        {
            FieldInfo compareToFieldInfo = (FieldInfo)compareTo;
            if (displayOrder == compareToFieldInfo.displayOrder) return 0;
            if (displayOrder > compareToFieldInfo.displayOrder) return 1;
            else return -1;
        }
    }  
}