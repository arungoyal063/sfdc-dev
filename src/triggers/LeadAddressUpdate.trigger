trigger LeadAddressUpdate on Lead (before insert) 
{

    list<Id> leadAccountIds= new List<Id>();
    for(Lead mylead : trigger.new)
        leadAccountIds.add(mylead.account__c);   //capture account ids related to leads
    Map<id, Account> acclist = new Map<id, Account>([SELECT Id,Street__c,City__c, State__c, Country__c, ZipCode__c 
                             FROM Account WHERE Id in: leadAccountIds]); //fetch the accounts
    Account a;
    
    for(Lead mylead:trigger.new)
    {
        a = acclist.get(mylead.account__c);
        if (a != null)
        {
            if( mylead.Street__c == '' || mylead.Street__c == null)
                mylead.Street__c = a.Street__c;// copies Street from account           
            
            if( mylead.City__c == '' || mylead.City__c == null)        
                mylead.City__c = a.City__c;// copies City from account           
            
            if( mylead.Country__c == '' || mylead.Country__c == null)
                mylead.Country__c = a.Country__c;// copies Country from account           
            
            if( mylead.State__c == '' || mylead.State__c == null)        
                mylead.State__c = a.State__c;// copies State from account           
            
            if( mylead.ZipCode__c == '' || mylead.ZipCode__c == null)
                mylead.ZipCode__c = a.Zipcode__c;// copies Zip/PostalCode from account
                
        }
    }
}