//This is provided as a sample to require a contact on opportunities it is provided without warranty and support. 

trigger opportunity_contact_required on Opportunity (before insert, before update) {

    //map to keep track of the contact_required = 1
    Map<String, Opportunity> oppy_contact = new Map<String, Opportunity>();

    //Trigger.new is an array of opportunities 
    //and adds any that have Contact_Required = 1 to the oppy_contact Map
    for (Integer i = 0; i < Trigger.new.size(); i++) {
            oppy_contact.put(Trigger.new[i].id,Trigger.new[i]);
        
    }

    //map to keep track of the opportunity contact roles
    map<Id, OpportunityContactRole> oppycontactroles = new map<Id, OpportunityContactRole>();

    //select OpportunityContactRoles for the opportunities with contact role required 

    List<OpportunityContactRole> roles = [select OpportunityId, IsPrimary from OpportunityContactRole
        where (OpportunityContactRole.IsPrimary = True and OpportunityContactRole.OpportunityId
        in :oppy_contact.keySet())];


    for (OpportunityContactRole ocr : roles) {
        //puts the contact roles in the map with the Opportunity ID as the key
        oppycontactroles.put(ocr.OpportunityId,ocr);
    }

    // Loop through the opportunities and check if they exists in the contact roles map or contact role isn't required    
    for (Opportunity oppy : system.trigger.new) {
        //system.debug('List oppy Id - '+oppy.id);
        if  (oppycontactroles.containsKey(oppy.id))              
        {
            oppy.Has_Primary_Contact__c =True;
        }
        else
        {
             oppy.Has_Primary_Contact__c =False;
        
        }
    } //for    
 }