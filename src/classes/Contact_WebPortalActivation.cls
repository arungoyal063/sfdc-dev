public with sharing class Contact_WebPortalActivation {
//Future Mehtod needed to avoid Mixed DML Operation issues on updating the user
    @future
    public static void Disable(Set<Id> userIds)
    {
        List<User> usersToUpdate = [SELECT
        User.Id,
        User.IsActive,
        User.IsPortalEnabled
        FROM User WHERE User.Id IN:userIds];
                                                                                                  
        for (User u:usersToUpdate)
        {
            u.IsActive = false;
        }
        
       
        if (!usersToUpdate.isEmpty()) {
            try {
            update(usersToUpdate);
            } catch(DMLException e) {
                throw e;
            } catch(Exception e) {
                throw e;
            }
        }
    }
    
    @future
    public static void Enable(Set<Id> userIds)
    {
        List<User> usersToUpdate = [SELECT
        User.Id,
        User.IsActive,
        User.IsPortalEnabled
        FROM User WHERE User.Id IN:userIds];
        
        for (User u:usersToUpdate)
        {
            u.IsActive = true;
        }
        
        if (!usersToUpdate.isEmpty()) {
            try {
                update(usersToUpdate);
            } catch(DMLException e) {
                throw e;
            } catch(Exception e) {
                throw e;
            }
        }
    }
    
    @future
    public static void DisableCommunityUser(Set<Id> userIds)
    {
        
        List<Community_User__c> cuserList = [Select Id, RelatedUserId__c, IsActive__c from Community_User__c where RelatedUserId__c in :userIds];
    
       
                                                        
        for (Community_User__c u:cuserList)
        {
            u.IsActive__c = false;
        }
        
       
        if (!cuserList.isEmpty()) { 
            try {
                update(cuserList);
            } catch(DMLException e) {
                throw e;
            } catch(Exception e) {
                throw e;
            }
        } 
    }
    
    
   @future
    public static void EnableCommunityUser(Set<Id> userIds)
    {
        
        List<Community_User__c> cuserList = [Select Id, RelatedUserId__c, IsActive__c from Community_User__c where RelatedUserId__c in :userIds];
                                        
        for (Community_User__c u:cuserList)
        {
            u.IsActive__c = true;
        }
       
         if (!cuserList.isEmpty()) { 
            try {
                update(cuserList);
            } catch(DMLException e) {
                throw e;
            } catch(Exception e) {
                throw e;
            }
        } 
    }
    
     // method to update community user's user record on update of contact record
    public static void updateUserRecord(Map<ID, Contact> updatedContactMap) {
        if(!updatedContactMap.isEmpty()) {
            Set<String> commUserSet = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
            List<User> usertoUpdate = new  List<User>();
            
            for(User cu :  [SELECT u.Title, u.Street, u.State, u.PostalCode, 
                                   u.Phone, u.MobilePhone, u.LastName, u.Id,
                                   u.ContactId ,u.FirstName, u.Fax, u.Email, 
                                    u.Country, u.City FROM User u WHERE 
                                   ContactId IN :updatedContactMap.keySet() and 
                                   UserType in :commUserSet]) {
                                       
                if(updatedContactMap.containsKey(cu.ContactId)) {
                    Contact fromContact =  updatedContactMap.get(cu.ContactId);
                    User toUser = cu;
                    
                     toUser.FirstName = fromContact.FirstName;
                     toUser.LastName = fromContact.LastName;
                     toUser.Title = fromContact.Title;
                     if(fromContact.Email != null && fromContact.Email.trim() != '') {
                         toUser.Email = fromContact.Email;
                     }
                     toUser.MobilePhone = fromContact.MobilePhone;
                     toUser.Phone = fromContact.Phone;
                     toUser.Fax = fromContact.Fax;
                     toUser.Street = fromContact.Street__c;
                     toUser.City =  fromContact.City__c;
                     toUser.State = fromContact.State__c;
                     toUser.PostalCode = fromContact.ZipCode__c;
                     toUser.Country = fromContact.Country__c;
                     
                     usertoUpdate.add(toUser);  
                }     
            }
            
            if(!usertoUpdate.isEmpty()) {
                try {
                    update usertoUpdate;
                } catch(DMLException e) {
                    throw e;
                } catch(Exception e) {    
                    throw e;
                }
                
            }
        }   
    }
    
    // method to check if contact updated or not
    public static Boolean isContactUpdate(Contact newcon, Contact oldcon) {
        if(newcon != null && oldcon != null) {
            if(newcon.FirstName != oldcon.FirstName || newcon.LastName != oldcon.LastName ||
               newcon.Title != oldcon.Title ||  newcon.Email != oldcon.Email ||  
               newcon.Phone != oldcon.Phone ||  newcon.MobilePhone != oldcon.MobilePhone ||
               newcon.Fax != oldcon.Fax ||  newcon.Street__c != oldcon.Street__c ||  
               newcon.City__c != oldcon.City__c ||  newcon.State__c != oldcon.State__c ||
               newcon.ZipCode__c != oldcon.ZipCode__c ||  newcon.Country__c != oldcon.Country__c) {
                return true;
            }
        }
        return false;
    }
    
}