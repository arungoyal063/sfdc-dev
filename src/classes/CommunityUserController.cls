public class CommunityUserController {
  
  // create community user record on insert of user record
  @future 
  public static void createCommunityUser(Set<ID> userIds) {
      //map<Id,String> pSNameById = getNameOfPermissionSetByUserId(userIds);
      Set<String> CMUser = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
      List<Community_User__c> cuserList = new List<Community_User__c>();
      List<User> userList = [Select Id, Accountid, AboutMe, IsActive, Alias, MobilePhone, 
                              Email, EmployeeNumber, FirstName, LastName, ManagerId, 
                              UserRole.Name ,Profile.Name, Username from User where Id in :userIds and UserType in :CMUser];
                              
       for(User u: userList) {
             if(u.Accountid != null) {
                Community_User__c cu = new Community_User__c();
                if(u.Accountid != null) {
                    cu.Account__c = u.Accountid ;
                }
                cu.AboutMe__c = u.AboutMe;
                cu.IsActive__c = u.IsActive;
                cu.Alias__c = u.Alias;
                cu.MobilePhone__c = u.MobilePhone;
                cu.Email__c = u.Email;
                cu.EmployeeNumber__c = u.EmployeeNumber;
                cu.FirstName__c = u.FirstName;
                cu.LastName__c = u.LastName;
                if(u.ManagerId != null) {
                    cu.Manager__c = u.ManagerId;
                }
                if(u.UserRole != null) {
                    cu.PortalRole__c = u.UserRole.Name;
                }
                if(u.ProfileId != null) {
                    cu.Profile__c = u.Profile.Name; 
                }   
                cu.Username__c = u.Username;
                cu.Name = u.Username;
                cu.isUser__c = true;
                cu.RelatedUserId__c = u.Id;
                //cu.Permission_Set_Name__c = pSNameById.get(u.Id); 
                cuserList.add(cu);
            }
         }
                              
         if(cuserList != null && (!cuserList.isEmpty())) {
            try {
                insert cuserList;
            } catch(Exception e) {
                System.debug('Error' + e);
            }
         }  
  } 
  
  // update community user record on update of user record
  @future 
  public static void updateCommunityUser(Set<ID> userIds) {
    Set<String> CMUser = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
    //map<Id,String> pSNameById = getNameOfPermissionSetByUserId(userIds);
    Map<ID, Community_User__c> cuserMap = new Map<ID, Community_User__c>([Select Id, RelatedUserId__c, Account__c, 
                                            AboutMe__c, IsActive__c, 
                                            Alias__c ,MobilePhone__c, Email__c, 
                                            EmployeeNumber__c, FirstName__c,  LastName__c,
                                            Manager__c, PortalRole__c, Profile__c, 
                                            Username__c, Name, isUser__c 
                                            from Community_User__c where RelatedUserId__c in :userIds]);
                                            
    List<Community_User__c> cuserList =  new List<Community_User__c>();
                                            
    Map<ID,User> userMap = new  Map<ID,User>([Select Id, Accountid, AboutMe, IsActive, Alias, MobilePhone, 
                                                Email, EmployeeNumber, FirstName, LastName, ManagerId, 
                                                UserRole.Name ,Profile.Name, Username from User where Id in :userIds and UserType in :CMUser]);
                              
                              
       for(String u: cuserMap.keySet()) {
             Community_User__c cu  = cuserMap.get(u);
             
             if((cu.Account__c != null) && (cu.RelatedUserId__c != null) && userMap.containsKey(cu.RelatedUserId__c)) {            
                cu.Account__c = userMap.get(cu.RelatedUserId__c).Accountid;
                cu.AboutMe__c = userMap.get(cu.RelatedUserId__c).AboutMe;
                cu.IsActive__c = userMap.get(cu.RelatedUserId__c).IsActive;
                cu.Alias__c = userMap.get(cu.RelatedUserId__c).Alias;
                cu.MobilePhone__c = userMap.get(cu.RelatedUserId__c).MobilePhone;
                cu.Email__c = userMap.get(cu.RelatedUserId__c).Email;
                cu.EmployeeNumber__c = userMap.get(cu.RelatedUserId__c).EmployeeNumber;
                cu.FirstName__c = userMap.get(cu.RelatedUserId__c).FirstName;
                cu.LastName__c = userMap.get(cu.RelatedUserId__c).LastName;
                cu.Manager__c = userMap.get(cu.RelatedUserId__c).ManagerId;
                cu.PortalRole__c = userMap.get(cu.RelatedUserId__c).UserRole.Name;
                cu.Profile__c = userMap.get(cu.RelatedUserId__c).Profile.Name;    
                cu.Username__c = userMap.get(cu.RelatedUserId__c).Username;
                cu.Name = userMap.get(cu.RelatedUserId__c).Username;
                cu.isUser__c = true;
                //cu.Permission_Set_Name__c = pSNameById.get(userMap.get(cu.RelatedUserId__c).Id);                               
                cuserList.add(cu);
            }
         }
                              
         if(!cuserList.isEmpty()) {
            try {
                update cuserList;
            } catch(Exception e) {
                Trigger.New[0].addError('Error' + e);
            }
         }  
  }     
  
  
     // method to update contact record related with community user
     public static void updateCommunityContacts(Set<ID> contactIds) {
         // contactId => User Map         
         Map<ID, User> contactUserMap = new Map<ID, User>();
         List<Contact> contacttoUpdate = new List<Contact>();
         Set<String> commUserSet = new Set<String>{'PowerCustomerSuccess','CustomerSuccess','CspLitePortal'};
         
             List<User> userList = [SELECT u.Title, u.Street, u.State, u.PostalCode, 
                                           u.Phone, u.MobilePhone, u.LastName, u.Id,
                                           u.ContactId ,u.FirstName, u.Fax, u.Email, u.Country, 
                                           u.City FROM User u WHERE ContactId IN :contactIds and 
                                           UserType in :commUserSet];
                                       
         for(User cu:userList) {
             contactUserMap.put(cu.ContactId, cu);    
         }                            
                                       
         for(Contact c: [SELECT c.ZipCode__c, c.Title, c.Street__c, c.State__c, 
                                c.Phone, c.MobilePhone, c.LastName, c.FirstName, 
                                c.Fax, c.Email, c.Country__c, c.City__c 
                                FROM Contact c WHERE Id IN :ContactIds]){
                                
             if(contactUserMap.containsKey(c.Id)) {
                 Contact con =  c;
                 User contactUser = contactUserMap.get(c.Id);
                 
                 c.FirstName = contactUser.FirstName;
                 c.LastName = contactUser.LastName;
                 c.Title = contactUser.Title;
                 c.Email = contactUser.Email;
                 c.MobilePhone = contactUser.MobilePhone;
                 c.Phone = contactUser.Phone;
                 c.Fax = contactUser.Fax;
                 c.Street__c = contactUser.Street;
                 c.City__c =  contactUser.City;
                 c.State__c = contactUser.State;
                 c.ZipCode__c = contactUser.PostalCode;
                 c.Country__c = contactUser.Country;
                 contacttoUpdate.add(c);
             }                       
         }
           
         if(!contacttoUpdate.isEmpty()) {
             try {
                 update contacttoUpdate;
             } catch(DMLException e){  // return exception back to trigger on error
                 throw e;
             } catch(Exception e){ // return exception back to trigger on error
                 throw e;
             }
         }  
     }
     
     // method to check if contact updated or not
    public static Boolean isUserUpdate(User oldUser, User newUser) {
        System.debug(oldUser + '>>' + newUser);
        if(newUser != null && oldUser != null){
            if(newUser.FirstName != oldUser.FirstName || newUser.LastName != oldUser.LastName ||
               newUser.Title != oldUser.Title ||  newUser.Email != oldUser.Email ||  
               newUser.Phone != oldUser.Phone ||  newUser.MobilePhone != oldUser.MobilePhone ||
               newUser.Fax != oldUser.Fax ||  newUser.Street != oldUser.Street ||  
               newUser.City != oldUser.City ||  newUser.State != oldUser.State ||
               newUser.PostalCode != oldUser.PostalCode ||  newUser.Country != oldUser.Country) {
                   return true;
            }
        }
        return false;
    }
    /*
        Map to get permission set name by user Id
    
    private static map<Id,String> getNameOfPermissionSetByUserId(Set<ID> contactIds){
        map<Id,String> userAndPSName = new map<Id,String>(); 
        for(PermissionSet ps:[Select Name,(Select Id, PermissionSetId, AssigneeId, SystemModstamp From Assignments where AssigneeId IN:contactIds) From PermissionSet where IsOwnedByProfile = false ]){
            if(!ps.Assignments.isEmpty()){
                userAndPSName.put(ps.Assignments.get(0).AssigneeId, ps.Name);
            }        
        }
        return userAndPSName;
    }*/
}