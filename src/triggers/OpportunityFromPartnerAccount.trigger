trigger OpportunityFromPartnerAccount on Opportunity (before insert) {
/*
Author: LGMK
Date: 11/7/2011
Purpose: Set the Opportunity Owner to the Partner User and the Pricebook to
the one indicated on the Partner Account when Opp.Partner_Account__c
is non-null.
*/
    Id[] pid = new Id[]{};
    for(Opportunity o : trigger.new)
    {
        if(o.Partner_Account__c != null) pid.add(o.Partner_Account__c);
    }
    Map<Id, Account> aMap = new Map<Id, Account>([select id, Price_Book_Id__c from Account where id IN :pid]);
    User[] uList = [select id, AccountID from User where AccountID IN :pid];
    Map<Id, User> uMap = new Map<Id, User>();
    for(User u : uList)
    {
        uMap.put(u.AccountId, u);
    }

    for(Opportunity opp : trigger.new){
        if(opp.RecordTypeId == '012G0000000yBnD' && opp.Partner_Account__c != null){
            if(uMap.containsKey(opp.Partner_Account__c)){
                opp.OwnerId = uMap.get(opp.Partner_Account__c).id;
            }
            if(aMap.containsKey(opp.Partner_Account__c)){
                opp.Pricebook2Id = aMap.get(opp.Partner_Account__c).Price_Book_Id__c;
            }
        }
    }
}