trigger updateCommentOnEmail on EmailMessage (before insert) {

    for(EmailMessage email : Trigger.new)
    {
        Case thisC = [SELECT id,description
                      FROM Case
                      WHERE id =: email.ParentID];
        
        CaseComment cc = new CaseComment(parentID=thisC.id, IsPublished = true);
        if (email.TextBody.length() >= 1000)
        	cc.CommentBody=email.TextBody.substring(0,999);
        else
        	cc.CommentBody=email.TextBody;
        insert(cc);           
    }
}