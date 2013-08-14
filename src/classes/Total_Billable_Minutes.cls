public class Total_Billable_Minutes{
    public list<AggregateResult> listOBJ{get;set;}      
    public Total_Billable_Minutes(){   
        List<User> userList = [SELECT Id,AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(userList.get(0).AccountId != null) { 
            listOBJ  = new list<AggregateResult>();    
            listOBJ.addAll([SELECT Sum(Minutes__c) Billable_Minutes, Type__c 
                            FROM Billable_Time__c 
                            WHERE Allocated_Date__c <> null AND Account__c = :userList.get(0).AccountId group by Type__c]); 
        }    
                            
    }   
}