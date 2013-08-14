trigger SetOpportunityPricebookForSiebelOpportunities on Opportunity (before update) {
    Id[] rIds = new Id[]{};
    Id[] aIds = new Id[]{};
    for(Opportunity o : trigger.new){
        rIds.add(o.RecordTypeId);
        aIds.add(o.AccountId);
    }
    Map<Id, Account> aMap = new Map<Id, Account>([select Id, Name, Price_Book_ID__c from Account where Id = :aIds]);
    Map<Id, RecordType> rMap = new Map<Id, RecordType>([Select Id, Name from RecordType where Id IN :rIds]);
    for(Opportunity o : Trigger.new)
    {
        if(o.Is_Siebel_Opportunity__c == TRUE || o.RecordType.DeveloperName == 'Siebel Opportunity')
        {
                    o.Pricebook2Id = '01sG0000000HJfHIAW';
        }         
    }
           
}