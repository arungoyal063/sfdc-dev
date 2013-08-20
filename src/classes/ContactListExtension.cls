public with sharing class ContactListExtension {

    public List<Wrapper> wrapList{get;set;}
    public List<Wrapper> wrapListSendEMail{get;set;}
    public string quoteid;
    string templateId;
    public String keyword{get;set;}
    public Id[] selectedAccounts{get;set;}
    public List<Account> allAccountList = new List<Account>();
    Set<String> contactsAdded = new Set<String>();
   /* public List<SelectOption> getAllAccounts()
    {
        allAccountList = [select Id, Name from Account];
        List<SelectOption> options = new List<SelectOption>();
        for(Account a :allAccountList)
        {
            options.add(new SelectOption(a.Id,a.Name));
        }
        return options;
    }*/
    
    /*public Id[] selectedAccounts()
    {
        return selectedAccounts;
    }*/
    
    public PageReference SearchContacts2()
    {
       if(keyword == '' || keyword.length() < 2)
       {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Search string should be at least 2 characters long.');
            ApexPages.addMessage(myMsg);
            return null;
       }
       selectedAccounts = new Id[]{};
       quoteid = ApexPages.currentPage().getParameters().get('quoteId');
       if(quoteid != null && quoteid !='')
       {
           List<List<SObject>> searchList = [FIND :keyword IN ALL FIELDS RETURNING Account (Id, Name)];
           for(List<SObject> l: searchList)
           {
               for(SObject s: l)
               {
                   selectedAccounts.add(s.Id);
               }
           }
           //Quote q = [Select Id, Opportunity.AccountId from Quote where Id =: quoteid];       
           List<Contact> contactList = [Select id, Account.Name,Phone, Title, Email, FirstName, Lastname from Contact where AccountId in :selectedAccounts ORDER BY FirstName, LastName];
           wrapList = new List<Wrapper>();
           for(Contact c: contactList)
           {
                if(!contactsAdded.contains(c.Id))
                {
                    Wrapper w =  new Wrapper();
                    w.check = false;
                    w.con = c;
                    wrapList.add(w);
                }
           }
       }
       MultipleRecipientSetting__c x = MultipleRecipientSetting__c.getInstance();   
       System.debug('TmpId:'+x);   
       templateId = x.templateId__c;
       System.debug('TmpId:'+templateId);
       return null;
    }
    
    public ContactListExtension(ApexPages.StandardController controller)
    {
       wrapList = new List<Wrapper>();
       wrapListSendEMail = new List<Wrapper>();
    }
    public class Wrapper
    {
        public Contact con{get;set;}
        public boolean check{get;set;}
    }
    
    public void addSelected()
    {
        for(Wrapper w: wrapList)
        {
            boolean selected = w.check;
            if(selected && !contactsAdded.contains(w.con.Id))
            {
                wrapListSendEMail.add(w);
                contactsAdded.add(w.con.Id);
            }
        }
    }
    public void resetEmailList()
    {
        wrapListSendEMail.clear();
        contactsAdded.clear();
    }
    public void sendEmail(){
        try{
            Boolean clearPreviousList = false;
            for(Wrapper w: wrapListSendEMail)
            {
                string conEmail = w.con.email;
                boolean selected = w.check;
                string conId = w.con.Id;
                if(conEmail != null && conEmail !='')
                {
                    clearPreviousList = true;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(conId);
                    mail.setWhatId(quoteid);
                    mail.setTemplateID(templateId);
                    mail.setSaveAsActivity(true);
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setSenderDisplayName('Mannington Mills');
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
            if(clearPreviousList) {
                wrapList.clear();
                keyword = '';
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email Sent Successfully.');
            ApexPages.addMessage(myMsg);
        }catch(System.Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    public PageReference sendEmail2(){
        try{
            Boolean clearPreviousList = false;
            for(Wrapper w: wrapListSendEMail)
            {
                string conEmail = w.con.email;
                boolean selected = w.check;
                string conId = w.con.Id;
                if(conEmail != null && conEmail !='')
                {
                    clearPreviousList = true;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(conId);
                    mail.setWhatId(quoteid);
                    mail.setTemplateID(templateId);
                    mail.setSaveAsActivity(true);
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setSenderDisplayName('Mannington Mills');
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
            if(clearPreviousList) {
                wrapList.clear();
                keyword = '';
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email(s) Sent Successfully.');
            ApexPages.addMessage(myMsg);
            return null;
        }catch(System.Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}