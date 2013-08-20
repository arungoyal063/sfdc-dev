@isTest

public class testUpdateCommentOnEmail {
/*
    static testMethod void testUpdateComment() {
       
       Case exCase = new Case();
       
       insert(exCase);
       
       EmailMessage exEmail = new EmailMessage(parentid = exCase.id);
       
       insert(exEmail);
   }
*/
    static testMethod void testUpdateCommentsOnEmail(){
    
        Contact con1 = new Contact();
        List<RecordType> conids = [Select id from RecordType where Name = 'General Contact' limit 1];
        con1.RecordType = conids[0];
        con1.lastname = 'Lanka';
        con1.email = 'dmurali@rainmaker-llc.com';
        
        insert(con1);
        
        Case case1 = new Case();
        case1.Type = 'Problem';
        case1.Reason = 'Trigger';
        case1.Origin = 'Email';
        case1.Contact = [SELECT id FROM Contact WHERE id =: con1.id][0];
        //case1.ContactEmail = 'dmurali@rainmaker-llc.com';
        
        insert(case1);
        
        EmailMessage email = new EmailMessage(parentID = case1.id, TextBody = 'This is an email.', Subject = 'Your Email', 
                                                FromAddress = 'klanka@rainmaker-llc.com', ToAddress = 'dmurali@rainmaker-llc.com');
        
        insert(email);
    }
}