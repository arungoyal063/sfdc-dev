trigger Contact_WebPortalActivation on Contact (before Update, after update) {
    
    //[JGP 9/14/2012] Disable Web Portal User depending on the Inactive Status
    //Requires Test Class: TriggerTests for Unit Testing - Appended Code to existing class
    
    //Set of Id's containing Contact Ids of changed Inactive Contacts
    if(Trigger.isBefore && Trigger.isUpdate) {
         
         Map<ID, Contact> updatedContactMap = new Map<ID, Contact>();
         
         for (Integer i=0;i<trigger.size;i++) {
             if (trigger.old[i].Inactive__c != trigger.new[i].Inactive__c) {
                 trigger.new[i].Inactivate_Portal__c =  trigger.new[i].Inactive__c;   
             }
             /* check if user fields available in community update
             if(Contact_WebPortalActivation.isContactUpdate(trigger.new[i], trigger.old[i])) {
                 updatedContactMap.put(trigger.new[i].Id,trigger.new[i]);
             } */
         }
         
         // update related user record on update of contact record
        
    }
    
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        if(TriggerRunOnce.runOnce()) {
            Set<Id> Inactive = new Set<Id>();
            Set<Id> Active = new Set<Id>();
            Map<ID, Contact> updatedContactMap = new Map<ID, Contact>();
            
            for (Integer i=0;i<trigger.size;i++)
            {
                //@Usman on 28/11/2012 : Updated field inactive__c to Inactivate_Portal__c
                
                if ((trigger.old[i].Inactivate_Portal__c != trigger.new[i].Inactivate_Portal__c) && trigger.new[i].Inactivate_Portal__c == true && !Inactive.contains(trigger.new[i].Id))
                    Inactive.add( trigger.new[i].Id);                
                if ((trigger.old[i].Inactivate_Portal__c != trigger.new[i].Inactivate_Portal__c) && trigger.new[i].Inactivate_Portal__c == false && !Active.contains(trigger.new[i].Id))
                    Active.add( trigger.new[i].Id);
                
                if(Contact_WebPortalActivation.isContactUpdate(trigger.new[i], trigger.old[i])) {
                     updatedContactMap.put(trigger.new[i].Id,trigger.new[i]);
                }    
                    
            }
            if (!Inactive.isEmpty())
            {
                Set<Id> usersToUpdate = new Set<Id>();
                //Get all of the new Inactive Contact's User's and Deactivate them
                for(User u : [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where u.ContactId in :Inactive]){
                    if(u.IsActive)
                    {
                        usersToUpdate.add(u.Id);
                    }
                }
                if (!usersToUpdate.isEmpty())
                {
                    //Call future method to avoid mixed DML Operation
                    Contact_WebPortalActivation.Disable(usersToUpdate);
                    Contact_WebPortalActivation.DisableCommunityUser(usersToUpdate);
                }
            }
            if (!Active.isEmpty())
            {
                Set<Id> usersToUpdate = new Set<Id>();
                for(User u : [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where u.ContactId in :Active]){
                    if(!u.IsActive)
                    {
                        usersToUpdate.add(u.Id);
                    }
                }
                if (!usersToUpdate.isEmpty())
                {
                    //Call future method to avoid mixed DML Operation
                    Contact_WebPortalActivation.Enable(usersToUpdate);
                    Contact_WebPortalActivation.EnableCommunityUser(usersToUpdate);
                }
            }
            
            if(!updatedContactMap.isEmpty()) {
                 try {
                     Contact_WebPortalActivation.updateUserRecord(updatedContactMap);
                 } catch(DMLException e){
                     Trigger.New[0].addError(e.getDMLMessage(0));    
                 } catch(Exception e){
                     Trigger.New[0].addError(e.getMessage());    
                 } 
             }
         }
    }
}