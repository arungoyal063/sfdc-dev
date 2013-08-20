trigger Set_Account_Owner_On_Insert on Account (before insert) 
{
    
    // Map Account owner to user records based upon Sales Group Id.
    
    map<String,User> userMap = new map<String,User>();  //map<Group Id, User>
    list<User> users = new list<User>([select id, sales_group_id__c from user where sales_group_id__c != null AND isActive = true]);  //all active users with a Sales Group Id
    
    //Map users to Sales Groups
    for(User u : users)
    {
        if(!userMap.containskey(u.sales_group_id__c))
        {
            userMap.put(u.sales_group_id__c,u);
            System.Debug('Group Id: ' + u.sales_group_id__c + ' User Id: ' + u.id);
        }
        
    }
        
    // Set the owner of the Account based upon the Sales Group Id
    for (Account a : system.trigger.new)
    {
        if(a.Sales_Group_Id__c != null)
        {
            try
            {
                a.OwnerId = userMap.get(a.sales_group_id__c).id;
                System.Debug('Group Id: ' + a.sales_group_id__c + ' Owner Id: ' + a.OwnerId);
            }
            catch (Exception e)
            {
                //error is usually due to sales group not matching to a user, so just skip the operation and ownerid will default to importing user
            }
        }
    }
    

}