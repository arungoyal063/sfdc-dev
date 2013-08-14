public with sharing class ArticleExtension {
    //Custom Article Extension allowing for Email to be sent to the Context User
    public string APIobjectName{get;set;}
    public Apexpages.StandardController controller;
    Map<String,Schema.SObjectField> fields{get;set;}
    public List<FieldInfo> dynamicFields{get;set;}
    public List<FieldInfo> dynamicAttachmentFields{get;set;}
    public List<FieldInfo> dynamicAdditionalEmailFields{get;set;}
    public transient Sobject record{get;set;} 
    
    private Set<String> excludedFields = new Set<String>();
    private Map<String,Integer> displayFields = new Map<String,Integer>();
    private Map<String,Integer> extraEmailFields = new Map<String,Integer>();
    
    public String PageMessage{get;set;}
        
    public ArticleExtension(Apexpages.StandardController c)
    {
        PageMessage = '';
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
        
        //Excluded fields
        excludedFields.add('ViewScore');
        excludedFields.add('VoteScore');
        excludedFields.add('IsMasterLanguage');
        excludedFields.add('MasterVersionId');
        controller = c;
        //Determine Which Article has called this page
        APIobjectName = controller.getRecord().getSObjectType().getDescribe().getName();
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,APIobjectName));
        //Retieve all fields for this object
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
        query += ' FROM '+APIobjectName+' WHERE KnowledgeArticleId =\''+controller.getId()+'\' AND PublishStatus=\'online\'';
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,query));
        try
        {
            record = database.query(query);
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getmessage()));
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
    }
    
    public String ArticleTitle
    {
        get
        {
            for(Schema.SObjectField f:fields.values())
            {
                if (f.getDescribe().getLabel() == 'Title')
                try
                {
                    return string.valueOf(record.get(f.getDescribe().getName()));
                }
                catch (Exception ex){return '';}
            }
            return '';
        }
        set;
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
    public String LegacyArticleNumber
    {
        get
        {
            for(Schema.SObjectField f:fields.values())
            {
                if (f.getDescribe().getLabel() == 'Legacy Article Number')
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
    
    
    public void Email()
    {
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
        query += ' FROM '+APIobjectName+' WHERE KnowledgeArticleId =\''+controller.getId()+'\' AND PublishStatus=\'online\'';
        try
        {
            record = database.query(query);
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getmessage()));
        }
        //Create Email Attachments
        List<Messaging.Emailfileattachment> attachments = new List<Messaging.Emailfileattachment>();
        
        Set<String> fileFields = new Set<String>();
        
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
                    attachments.add(temp);      
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Valid Attachment found: '+s));
                }
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
            }
        }       
        //Create Email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //User
        message.setTargetObjectId(Userinfo.getUserId());
        //message.setToAddresses(new list<String>{'jpadilla@rainmaker-llc.com'});
        //Subject
        String subjectLine = '*** From Ellucian: Article ';
        if (ArticleNumber != null && ArticleNumber != '')
            subjectLine += ArticleNumber;
        if (LegacyArticleNumber != null && LegacyArticleNumber != '' && LegacyArticleNumber != 'null')
            subjectLine += ' / Legacy Article '+LegacyArticleNumber;
        message.setSubject(subjectLine);
        //message.setSubject(ArticleTitle);
        //Set body to Page Contents     
        //Pagereference pageContents = ApexPages.currentPage();
        String HTML = '';
        String Plain = '';
        //Add in Link to the Article
        //Create the URL
        String URL_Link = '';
        //Get the User Role - to determine if it's a portal user or not
        UserRole ur = [SELECT UserRole.Id, UserRole.PortalType FROM UserRole WHERE UserRole.Id =: Userinfo.getUserRoleId()];
        if (ur.PortalType != 'None') //Is a Portal User, provide community URL
        	URL_Link += System.Label.PortalBaseUrl;
        else //Standard User
        	 URL_Link += URL.getSalesforceBaseUrl().toExternalForm();
        try
        {
            URL_Link += '/articles/'+APIobjectName.replace('__kav','')+'/'+record.get('UrlName');
            System.debug('>>>>>>>>>>>>>>>>>>>'+URL_Link);
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,URL_Link));
        //HTML += '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+apexpages.currentPage().getUrl()+'" target="_blankPage">Link to Knowledge Article</a><br></br>';
        //Plain += 'Link to Knowledge Article: '+apexpages.currentPage().getUrl()+'\r\n';
        //HTML += '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+string.valueOf(record.get('Id'))+'" target="_blankPage">Link to Knowledge Article</a><br></br>';
        //Plain += 'Link to Knowledge Article: '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+string.valueOf(record.get('Id'))+'\r\n';
        HTML += subjectLine.replace('*** From Ellucian: ','')+' <a href="'+URL_Link+'" target="_blankPage">(Click here to view Article in the Support Center)</a><br></br>';
        Plain += subjectLine.replace('*** From Ellucian: ','')+' Link to Knowledge Article: '+URL_Link+'\r\n';
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()+' '+ex.getLineNumber()));
            }
        }
        
        HTML += '</table>';
        
        
        /*
        //Channels
        HTML += 'Channels: ';
        Plain += 'Channels: ';
        //Map keyed on fieldName - value to be printed on email
        Map<string,string> channelNames = new Map<string,string>();
        channelNames.put('IsVisibleInPkb','Public Knowledge Base');
        channelNames.put('IsVisibleInApp','Internal App');
        channelNames.put('IsVisibleInPrm','Partner Portal');
        channelNames.put('IsVisibleInCsp','Customer Portal');
        for (String s:channelNames.keySet())
        {
            if ((Boolean)record.get(s) != null && (Boolean)(record.get(s)))
            {
                HTML += channelNames.get(s)+',';
                Plain += channelNames.get(s)+',';
            }
        }
        */
        //HTML += '<br></br>';
        //Plain += '\r\n';      
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
        
        Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{ message };
		
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].isSuccess())
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Email Sent Successfully'));
            PageMessage = 'Email Sent Successfully';
        } 
        else
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Error Sending Email!'));
            PageMessage = 'Error Sending Email!'+results[0].getErrors();
        } 
  		
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
    
    static testMethod void ArticleExtensionTEST()
    {
        //Create a FAQ Article
        FAQ__kav article = new FAQ__kav(Title='Test',Legacy_Article_Number__c = '100', FAQ_Details__c = 'Details Section', Language = 'en_US');
        //Create Controller
        Apexpages.StandardController controller = new Apexpages.StandardController(article);
        //Create an Instance of the Page
        ArticleExtension page = new ArticleExtension(controller);
        page.Email();
    }
}