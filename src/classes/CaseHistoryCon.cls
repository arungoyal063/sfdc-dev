public with sharing class CaseHistoryCon {
/*
 *  The purpose of this class is to take a given case or case record Id and perform a query 
 *  to retrieve the appropriate related objects which will then be added to a collection of
 *  history (apex) objects and ordered chronologically.
 *
 *  This class is used by the caseHistory and caseHistoryPrint Visualforce pages. 
 * 
 *  Note: this class, as per all of Apex, runs in system mode and will currently return all 
 *        records in the system in the query it performs regardless of any sharing rules.
 *        If you want the queries to respect the visibility settings in the application 
 *        (sharing rules) you must append the "WITH SHARING" modifier to the class definition.
 *        Additionally, any fields or objects which are restricted via CRUD or FLS 
 *        (profile security permissions) will be exposed because the binding from the Visualforce 
 *        pages uses the history (apex) object and not the respective SObjects (Case, Task, etc.).
 *        If you wish to have these security settings enforced refer to the Schema.Describe types
 *        in the Apex developer guide for additional information.
 */

    /* Property value that controls the truncation of case comments */
    public boolean fullComments { get; private set; }

    /* Property value that controls visibility of related objects which
       are not visible in the customer portal. */
    public boolean hidePrivate  { get; private set; }
   public boolean isPortalUser  { get; private set; }
  
    /* Property value that controls visibility of related objects which
       are not visible in the customer portal. */
    public boolean hideStatusUpdates  { get; private set; }
    /* Constructor of the class where we default the above property values */
    public CaseHistoryCon() {
        fullComments           = true;
        hidePrivate            = false;
        truncatedCommentLength = 100;
        hideStatusUpdates = true;
        isPortalUser =false;
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String ProfileName = PROFILE[0].Name;
        if (ProfileName != null && ProfileName == 'Ellucian Communities Profile')
            isPortalUser =true;
            
    }
    
    /* Action method for toggling the fullComments property */
    public void toggleComments() { fullcomments = !fullcomments; }
   /* Action method for toggling the fullComments property */
    public void toggleStatus() { hideStatusUpdates = !hideStatusUpdates; }
    /* Action method for toggling the visibility control for private related objects.*/
    public void togglePrivate()  { hidePrivate  = !hidePrivate;  }    
    
    /* Action method for navigating the user back to the case page. */
    public PageReference backToCase() {
        return new ApexPages.StandardController(c).view();
    }

    /* Accessor for retrieving the case object and its related items. If the cid property is null this
       method will return a new, empty case object. The functionality in this method could have been placed
       in the get property accessor for the private property named 'c' below but for simplicity of the page
       author in referencing the current case object this method was created because it is not possible to
       create a variable named 'case' since it is a reserved term in Apex.*/
    public Case getCase() { 

        if(cid == null) return new Case();
        return [SELECT CaseNumber,Legacy_Case_Number__c,
                        Priority,
                        Full_Hierarchy__c,
                        Sub_Status__c,
                        Status,
                        Product_Version__r.Name,
                        Object_Process__c,
                        Subject,
                        Description,
                        Resolution_Summary__c,
                        Account.Name,
                        Contact.Name,
                        Contact.Phone,
                        Contact.Email,
                        Billable_Minutes_on_Case__c,
                       (SELECT CreatedBy.Name, CreatedDate, CommentBody,IsPublished          FROM CaseComments WHERE isdeleted = false  ORDER BY CreatedDate      ASC),
                       (SELECT CreatedBy.Name, CreatedDate, Field, NewValue, OldValue        FROM Histories  WHERE isdeleted = false  and Field in ('Status', 'Owner')             ORDER BY CreatedDate      ASC),
                       (SELECT id, CreatedBy.Name, CreatedDate, Name  ,isprivate                           FROM Attachments WHERE isdeleted = false   ORDER BY CreatedDate      ASC),
                       (SELECT Owner.Name, ActivityDateTime, Subject, IsVisibleInSelfService, Description FROM Events   WHERE isdeleted = false  and  ActivityDateTime <= :System.Now()   ORDER BY ActivityDateTime ASC),
                       (SELECT Owner.Name, CreatedDate, Subject, IsVisibleInSelfService, Description  FROM Tasks      WHERE isdeleted = false  and  CreatedDate     <= :System.Now()  AND IsClosed = true and id not in (select activityid from  EmailMessage where parentid =:cid) ORDER BY CreatedDate ASC),
                       (Select CreatedBy.Name, CreatedDate, TextBody, Subject, FromName, ToAddress, MessageDate From EmailMessages WHERE isdeleted = false  ORDER BY MessageDate      ASC)
                       
                FROM case 
                WHERE id = :cid
                ALL ROWS]; 
    }
     public List<Confidential_Attachment_and_Note__c> getConfidential() { 
    
        if(cid == null) return new List<Confidential_Attachment_and_Note__c>();
        return [SELECT Case__c,   
                        (SELECT CreatedBy.Name, CreatedDate, Body                             FROM Notes  ORDER BY CreatedDate            ASC)
                      , (SELECT id, CreatedBy.Name, CreatedDate, Name                             FROM Attachments  ORDER BY CreatedDate      ASC)
                FROM Confidential_Attachment_and_Note__c
                WHERE Case__c = :cid
                ]; 
    }   
    public List<Task> getTaskAttachments() { 
    
        if(cid == null) return new List<Task>();
        return [SELECT Owner.Name, CreatedDate, Subject, IsVisibleInSelfService, Description  , ( Select  id, CreatedBy.Name, CreatedDate, Name  ,isprivate     from Attachments where isdeleted = false  and  CreatedDate     <= :System.Now() ORDER BY CreatedDate      ASC)FROM Task        WHERE CreatedDate     <= :System.Now() AND IsClosed = true and id not in (select activityid from  EmailMessage where parentid =:cid) 
        and whatid= :cid
        ORDER BY CreatedDate ASC ALL ROWS]; 
    }   
    public List<Attachment> getEmailAttachments() { 
    
        if(cid == null) return new List<Attachment>();
        return [  Select  id, CreatedBy.Name, CreatedDate, Name  ,isprivate     from attachment where parentid in  (Select id From EmailMessage where  parentid =:cid )  and  isdeleted = false ORDER BY CreatedDate      ASC ALL ROWS];
    }     
    /* This accessor provides the page with the ordered collection of history (apex) objects for display in the page. 
       it also processes the truncation of case comments as specified by the fullComments property value.*/
    public History[] getHistories() {
        History[] histories = new history[]{};
        for (CaseComment comment:c.casecomments) { 
            if (!hidePrivate || comment.ispublished) {
                addHistory(histories, new history(comment.createdDate, comment.ispublished, comment.createdby.name, 'Comment Added', '' , truncateValue(comment.commentbody),null) ); 
            }
        }
        
        for (Event e:c.events) { 
            if (!hidePrivate || e.isvisibleinselfservice) {
                addHistory(histories, new history(e.activitydatetime,  e.isvisibleinselfservice, e.owner.name,'Event Completed', '' , truncateValue('Subject: ' +e.subject +'\nDescription: ' + e.Description),null)); 
            }
        }
        
        for (Task t:c.tasks) { 
            if (!hidePrivate || t.isvisibleinselfservice) {
                addHistory(histories, new history(t.CreatedDate,  t.isvisibleinselfservice, t.owner.name,'Activity Added',  '' , truncateValue('Subject: ' +t.subject +'\nDescription: ' + t.Description),null));
            }
        }

        for (CaseHistory ch:c.histories) { 
            if(hideStatusUpdates ==false)
            try{
            	if (String.valueOf(ch.newvalue).Left(3) <> '005' && String.valueOf(ch.newvalue).Left(3) <> '00G')
                addHistory(histories, new history(ch.createdDate, true, ch.createdby.name, ch.field + ' Change', '','Value Changed from "' + String.valueOf(ch.oldvalue) + '" to "' + String.valueOf(ch.newvalue)+'"',null)); 
            }
            catch(Exception e){}
            
            
        }

        for (Attachment a:c.attachments) { 
            if((isPortalUser && !a.isprivate )|| !isPortalUser)
                addHistory(histories, new history(a.createdDate,  !a.isprivate , a.createdby.name, 'Attachment Added', '' , a.name, a.id)); 
        }
        
        for (Task Attachmenttasklist:taskAttachmentList) { 
        	for (Attachment ta:Attachmenttasklist.attachments) {
            	if((isPortalUser && !ta.isprivate )|| !isPortalUser)
                	addHistory(histories, new history(ta.createdDate,  !ta.isprivate , ta.createdby.name, 'Task Attachment Added', '' , ta.name, ta.id)); 
        	}
        }
       for (Attachment ea:emailAttachments) { 
            if((isPortalUser && !ea.isprivate )|| !isPortalUser)
                addHistory(histories, new history(ea.createdDate,  !ea.isprivate , ea.createdby.name, 'Email Attachment Added', '' , ea.name, ea.id)); 
        }
        string subject;
        for (EmailMessage e:c.EmailMessages) { 
            {
                subject='On '+e.MessageDate.format('MM/d/yyyy')+' '+e.FromName+' wrote to '+e.ToAddress +'\nSubject: '+e.Subject+'\nBody: '+e.TextBody+'\n';
                addHistory(histories, new history(e.MessageDate,  true, e.FromName ,'Email Added', '' , truncateValue(subject),null)); 
            }
        }
        if (!hidePrivate)
        {
            for (Confidential_Attachment_and_Note__c caa:caalst)
            {
                for (Attachment a2:caa.attachments) { 
                    addHistory(histories, new history(a2.createdDate,  false, a2.createdby.name, 'Confidential Attachment Added', '' , a2.name, a2.id)); 
                }  
                for (Note n:caa.notes) { 
                    addHistory(histories, new history(n.createdDate,  false, n.createdby.name, 'Confidential Note Added', '' , n.Body, null)); 
                } 
            } 
        }  
        return histories;
    }
    
    /* This method adds the newHistory object to the given histories collection in the appropriate order. 
       The order provided here places the oldest records at the front of the list, i.e. by date ascending. */
    private void addHistory(History[] histories, History newHistory) {
        Integer position = histories.size();
        for (Integer i = 0; i < histories.size(); i++) {
            if (newHistory.historydt < histories[i].historydt) {
                position = i;
                break;
            }
        }
        
        if (position == histories.size()) {
            histories.add(newHistory);
        } else {
            histories.add(position, newHistory);
        }
    }
    
    /* Returns the truncated string value if that is specified in the current state (!fullComments)
       and the current length is greater than the value of the private truncatedCommentLength property. */
    private String truncateValue(String s) {
        if (!fullComments && s.length() > truncatedCommentLength) {
            s = s.substring(0,truncatedCommentLength) + '...';
        }
        
        return s;
    }
    
    /* The ID value of the case that will be used by the getCase() method to query for the related
       objects used to generate the ordered history collection. The value will be based on the request 
       parameter, if available. */
    private Id cid { 
        get { 
            if(ApexPages.currentPage().getparameters().get('cid') != null) {
                cid = ApexPages.currentPage().getparameters().get('cid');
            }
            return cid;
        }
        set { 
            if(value != null) cid = value;
        }
    }
    
    /* The case object set by the getCase method and used by the getHistories method to acquire
       the related records.  */
    private Case c { 
        get { return getCase(); }
        set; 
    }

    private List<Confidential_Attachment_and_Note__c> caalst { 
        get { return getConfidential(); }
        set; 
    }
    private List<Task> taskAttachmentList { 
        get { return getTaskAttachments(); }
        set; 
    }
        private List<Attachment> emailAttachments { 
        get { return getEmailAttachments(); }
        set; 
    }
    /* The length of "Short Comments" which is used by the truncateValue method in this class to
       truncate case comments when specified by the user. */
    private Integer truncatedCommentLength { get; set; }  
    
    /* 
 * This class is used by the CaseHistoryCon controller class and the CaseHistory
 * and CaseHistoryPrint Visualforce pages. The purpose is to hold heterogenous
 * sobject information that allows multiple types to be presented in a uniform manner.
 */
public class history {

    /* Properties of the class */
    public datetime historydt { get; private set; }
    public boolean ispublic   { get; private set; }
    public string actorname   { get; private set; }
    public string historyType { get; private set; }
    public string to          { get; private set; }
    public string fr          { get; private set; }
    
    /* Class constructor */
    public History(Datetime d, boolean p, String actor, String ht, String f, String t, String id) {
        historydt   = d;
        historydate = d.format();
        ispublic    = p;
        actorname   = actor;
        historyType = ht;
        fr          = f;
        if (t==null)
        {
        		t='';
        }
        t.escapeEcmaScript();
        t.escapeHtml4();
        t.escapeXml();
        if(id !=null)
       {
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String ProfileName = PROFILE[0].Name;
            String url ='/';
            if (ProfileName == 'Ellucian Communities Profile')
            {
                    url = '/clients' + url;
            }
            to =  + '<a href ="'+ url + id + '">'+t+'</a>';
       }
        else
            to          = LineFeedToHTMLBreaks(t);
    }
    public  string LineFeedToHTMLBreaks(string stringIn)
  {
    string LF = '\n';
    string CR_LF = '\r\n';
    string HTML_BREAK = '<BR/>';
    string searchArg = null;
    integer startPos = 0;
    integer pos;
    // Determine whether cr/lf or just lf in this string
    pos = stringIn.indexOf(CR_LF, startPos);
    if (pos != -1)
      searchArg = CR_LF;
    else {
      pos = stringIn.indexOf(LF, startPos);
      if (pos != -1)
        searchArg = LF;
    }
    // Replace line feeds if found in string
    if (searchArg != null)
    {
      do {
        pos = stringIn.indexOf(searchArg, startPos);
        if (pos != -1)
        {
      string newString;
      if (stringIn.length() > pos + searchArg.length())
        newString = stringIn.substring(0, pos) + HTML_BREAK + stringIn.substring(pos + searchArg.length());
      else
        newString = stringIn.substring(0, pos) + HTML_BREAK;
      stringIn = newString;
      startPos = pos + HTML_BREAK.length();
    }
      } while (pos != -1 && pos < stringIn.length());
    }
    
    return stringIn;
  }
    /* Formatting methods utilized primarily by the CaseHistoryPrint Visualforce page*/
    public string historydate { get; set; }
    public string dtmonthyr   { get { return historydt.format('MMMMM yyyy'); } }
    public string dttime      { get { return historydt.format('h:mm a');} }
    public string dtdayfmt    { get { return historydt.format('d - EEEE'); } }
    public integer dtmonth    { get { return historydt.month();} }
    public integer dtyear     { get { return historydt.year();} }
    public integer dtday      { get { return historydt.day();} }
    
}
     
}