trigger SetOpportunityPricebook on Opportunity (before insert, before update) {
    Id[] rIds = new Id[]{};
    Id[] aIds = new Id[]{};
    Id[] oIds = new Id[]{};
    for(Opportunity o : trigger.new){
        rIds.add(o.RecordTypeId);
        aIds.add(o.AccountId);
        oIds.add(o.OwnerId);
    } 
    
    String NASRole = 'HD NAS';
    Id SiebelPricebook;
    try
    {
    	SiebelPricebook = ([SELECT Id FROM Pricebook2 Where Name ='Siebel Products' Limit 1]).Id;
    }
      Catch( Exception e){} 
    Map<Id, Account> aMap = new Map<Id, Account>([select Id, Name, Price_Book_ID__c from Account where Id = :aIds]);
    Map<Id, RecordType> rMap = new Map<Id, RecordType>([Select Id, DeveloperName from RecordType]);
    Map<Id, User> uMap = new Map<Id, User>([select Id, UserRoleId from User where Id = :oIds]);
    Map<Id, UserRole> roleMap = new Map<Id, UserRole>([SELECT Id, Name  FROM UserRole Where Name like '%(HD NAS)%' ]);
    
    for(Opportunity o : Trigger.new){
        if (o.PriceBook2Id == null && o.Team__c != null )
        {
            if(aMap.containsKey(o.AccountId) )
            {
                Account a = aMap.get(o.AccountId);
      
                    if(o.RecordTypeId != null && rMap.get(o.RecordTypeId).DeveloperName != null && rMap.get(o.RecordTypeId).DeveloperName != 'Partner_Portal_Datatel')
                    { 
                        
                        Boolean InNASRole = false;
                        InNASRole = roleMap.containsKey(uMap.get(o.OwnerId).UserRoleId);
                        if (o.Team__c == '05 - Colleague CBR' || o.Team__c == '09 - Colleague CBR - Inside Sales'||  inNASRole || o.Team__c == '20 - Business Advisory Services' || (o.Solution__c != null && o.Solution__c == 'Recruiter' ))
                        {
                        	if(a.Price_Book_ID__c != null)
                        	{
                            	o.Pricebook2Id = a.Price_Book_ID__c;
                        	}
                        	else
                        	{
                        		if (SiebelPricebook != null)
                               	 	o.Pricebook2Id = SiebelPricebook;  
                        	
                        	}
                            system.debug(o.Pricebook2Id);
                        }
                        else
                        {
                            if (SiebelPricebook != null)
                                o.Pricebook2Id = SiebelPricebook;   
                        }
                    }
                  
                }
        }
        
        
    }
    
}