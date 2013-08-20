public class EmailQuoteController 
{   // Constructor - this only really matters if the autoRun function doesn't work right    
    private final Quote o;   
    public String quoteId {get; set;} 
    public String quoteName {get; set;} 
    public String message {get; set;} 
    public EmailQuoteController (ApexPages.StandardController stdController) 
    {        
        //this.o = (Quote)stdController.getRecord();    
    }     // Code we will invoke on page load.    
    
    public PageReference autoRun() 
    {         
        String myId = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('retURL'),'UTF-8');
        String theId = myId.substring(1,myId.length()); 
        quoteId = theId ;
        Quote ooo = [Select id, Name, Approved__c, Quote.Contact.Account.SAP_External_Id__c, Opportunity.SAP_External_Id__c, ContactId, Email, OpportunityId from Quote where id =:theId];
        quoteName = ooo.Name;
        System.debug('SAP External ID = ' + ooo.Contact.Account.SAP_External_Id__c);
        //check contactID and its email.. these should be present
        
        if((ooo.ContactId == null))
        {
        	message = 'Could not send Email as no Contact found with the Quote ';
        	return null;
        }
        List<Contact> ctc = [SELECT Id, Email FROM Contact where Id =: ooo.ContactId LIMIT 1];
        if((ctc.size() == 0) ||(ctc[0].Email == null) || (ctc[0].Email == ''))
        {
        	message = 'No valid Email address found with the Contact associated with the Quote ';
        	return null;
        }
       
        if(ooo.Approved__c == True)
        {//normal email sending behavior
            PageReference ref = sendEmail(ooo.Contact.Account.SAP_External_Id__c, ooo.ContactId, theId);
            return ref;
        }
        else
        {//check line items Sales price with product J Price
        //get all items prices
            List<QuoteLineItem> quotelineLists = [SELECT QuoteId, Id, UnitPrice, PriceDiff__c FROM QuoteLineItem where QuoteId =:theId AND PriceDiff__c > 0 LIMIT 1000];  
            System.debug('size = ' + quotelineLists.size() );
            if(quotelineLists.size() == 0)      
            {
                PageReference ref = sendEmail(ooo.Contact.Account.SAP_External_Id__c, ooo.ContactId, theId);
                return ref;
            }
            else
            {
                //add error message .. throw exception
                //PageReference pageRef = new PageReference('/' + theId);
                //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, 'testmessage '));
                message = 'Please verify that each selected product is priced above J level, or request quote approval by clicking the Submit for Approval button on the';
                //return pageRef ;            
                return null;                
            }
        }
        
    }
    private PageReference sendEmail(String SAPExternalID, Id contactID, String quoteID)
    {
           
        Blob body = null;
        String PDFName = null;
        
        // returns the output of the page as a PDF
        List<QuoteDocument> quotedoc = [SELECT Name, Document, QuoteId, Id FROM QuoteDocument WHERE QuoteId =:quoteID];
        if(quotedoc.size() > 0)
        {
            body = quotedoc[0].Document;
            PDFName = quotedoc[0].Name;
        }
           
           
           if((SAPExternalID == null) || (SAPExternalID == ''))
           {
                sendEmailWithAttachment(contactID, body, PDFName);
                PageReference pageRef = new PageReference('/' + quoteID );
                return pageRef ;
            }
            else
            {
                //PageReference pageRef = new PageReference('/_ui/core/email/author/EmailAuthor?p3_lkid='+ quoteID + '&retURL=%2F'+ quoteID);        
                sendEmail(contactID, body, PDFName);
                PageReference pageRef = new PageReference('/' + quoteID );
                //pageRef.setRedirect(true);        
                return pageRef; 
            }   
    }

    private void sendEmailWithAttachment(Id contactID, Blob body, String PDFName)
    {
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        if(body != null)
        {
            attach.setContentType('application/pdf');
            attach.setFileName(PDFName);
            attach.setInline(false);
            attach.Body = body;        
        }
       
       
        EmailTemplate et = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName='Sample_User_Registration_form'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactID);       
        mail.setTemplateId(et.id);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setReplyTo('mannington@salesoptimizer.com');
        mail.setSenderDisplayName('Mannington Commercial');
        mail.setSaveAsActivity(false);
        if(body != null)
        {
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }

    private void sendEmail(Id contactID, Blob body, String PDFName)
    {
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        if(body != null)
        {
            attach.setContentType('application/pdf');
            attach.setFileName(PDFName);
            attach.setInline(false);
            attach.Body = body;        
        }
       
       
        EmailTemplate et = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName='Send_PDF_Email'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactID);       
        mail.setTemplateId(et.id);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setReplyTo('mannington@salesoptimizer.com');
        mail.setSenderDisplayName('Mannington Commercial');
        mail.setSaveAsActivity(false);
        if(body != null)
        {
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }



   
  static testMethod void runTestCases() { 
        Account newAccount = new Account(name='XYZ Organization');
        insert newAccount;
        Contact newContact = new Contact (AccountId = newAccount.id, FirstName='AA', LastName='BB', Email='sanjeev.mehta@softappspro.com');
        insert newContact;
        Opportunity newOpportunity = new Opportunity(AccountId = newAccount.id, Name = 'Test Opportunity', StageName='Closed Won', CloseDate = System.today());
        insert newOpportunity;
        Quote newQuote = new Quote(Name = 'Test Quote', OpportunityId = newOpportunity.id, ContactId = newContact.id);
        insert newQuote;
        
        PageReference pageRef = Page.EmailQuoteOverride;
        pageRef.getParameters().put('retURL','/'+newQuote.id);
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.standardController(newQuote);
        EmailQuoteController myPageCon = new EmailQuoteController(sc);
        myPageCon.autoRun();
        
        newAccount.SAP_External_Id__c = '11';
        update newAccount;
        myPageCon.autoRun();

    }
}