trigger SetPortalOpportunityPricebook on Opportunity (before insert) {
    Id[] uIds = new Id[]{};
    Id[] aIds = new Id[]{};
    for(Opportunity o : trigger.new){
        if(o.RecordTypeId == '012G0000000yBnDIAU') uIds.add(o.OwnerId);
        aIds.add(o.AccountId);
    }
    Map<Id, Account> aMap = new Map<Id, Account>([Select Id, Name, Price_book_Id__c from Account where Id IN :aIds]);
    Map<Id, User> uMap = new Map<Id, User>([Select Id, Contact.Account.Price_Book_Id__c from User where Id IN :uIds]);
//    Map<Id, RecordType> rMap = new Map<Id, RecordType>([Select Id, Name from RecordType where Id IN :rIds]);
    for(Opportunity o : Trigger.new){
       // if(o.RecordTypeId != '012G0000000yBnDIAU'){
             /*List<Account> l = [select Name, Price_Book_ID__c from Account where Id = :o.AccountId];
             if(l.isEmpty())
                break;
             Account a = l[0];*/
      //      Account a = aMap.get(o.AccountId);
      //       if( a != null && a.Price_Book_ID__c != null){
      //          o.Pricebook2Id = a.Price_Book_ID__c;
      //       }
      //  }else 
        
        if(o.RecordTypeId == '012G0000000yBnDIAU'&& o.Partner_Account__c == NULL)
        {
            String pbId;
            System.debug(uMap);
            System.debug(uMap.get(o.OwnerId));
            if(uMap.containsKey(o.OwnerId)) o.Pricebook2Id = uMap.get(o.OwnerId).Contact.Account.Price_Book_Id__c;
            /*
            List<User> l1 = [select ContactId from User where Id = :o.OwnerId];
            if(l1.isEmpty())
                break;
            User u = l1[0];
            List<Contact> l2 = [select AccountId from Contact where Id = :u.ContactId];
            if(l2.isEmpty())
                break;
            Contact c = l2[0];
            List<Account> l3 = [select Price_Book_ID__c from Account where Id = :c.AccountId];
            if(l3.isEmpty())
                break;
            Account a2 = l3[0];
            
            if(a2.Price_Book_ID__c != null){
                o.Pricebook2Id = a2.Price_Book_ID__c;
            }*/
        }
    }
    
}