trigger contactAddressTest on Contact (before insert) 
{

    list<Id> contactAccountIds= new List<Id>();
    for(Contact mycontact : trigger.new)
        contactAccountIds.add(mycontact.accountId);   //capture account ids related to contacts
    Map<id, Account> acclist = new Map<id, Account>([SELECT Id,Street__c,City__c, State__c, Country__c, ZipCode__c 
                             FROM Account WHERE Id in: contactAccountIds]); //fetch the accounts
    Account a;
    
    for(Contact mycontact:trigger.new)
    {
        a = acclist.get(mycontact.accountId);
        if (a != null)
        {
            if( mycontact.Street__c == '' || mycontact.Street__c == null)
                mycontact.Street__c = a.Street__c;// copies Street from account           
            
            if( mycontact.City__c == '' || mycontact.City__c == null)        
                mycontact.City__c = a.City__c;// copies City from account           
            
            if( mycontact.Country__c == '' || mycontact.Country__c == null)
                mycontact.Country__c = a.Country__c;// copies Country from account           
            
            if( mycontact.State__c == '' || mycontact.State__c == null)        
                mycontact.State__c = a.State__c;// copies State from account           
            
            if( mycontact.ZipCode__c == '' || mycontact.ZipCode__c == null)
                mycontact.ZipCode__c = a.Zipcode__c;// copies Zip/PostalCode from account
                
        }
    }
}