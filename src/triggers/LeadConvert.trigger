trigger LeadConvert on Lead (after update) {

  // THIS TRIGGER SETS THE PRIMARY FLAG ON THE OPPTY CONTACT ROLE WHEN CONVERTING LEAD TO OPPORTUNITY/CONTACT
 
  // no bulk processing; will only run from the UI
  if (Trigger.new.size() == 1) {

      if (Trigger.old[0].isConverted == false && Trigger.new[0].isConverted == true) {
      // Get the new oppcontactrole record
          if (Trigger.new[0].ConvertedOpportunityId != null && Trigger.new[0].ConvertedContactId != null)
          {
            OpportunityContactRole ocr = [select Id,IsPrimary from OpportunityContactRole where OpportunityId = :Trigger.new[0].ConvertedOpportunityId and ContactId = :Trigger.new[0].ConvertedContactId];
            ocr.IsPrimary = true;
            update ocr;
          }
   }    // end check for just converted
  }     // end check for mass convert
}