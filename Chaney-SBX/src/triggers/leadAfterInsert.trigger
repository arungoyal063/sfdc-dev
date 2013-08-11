trigger leadAfterInsert on Lead (after insert) {

	List<string> campaign = new List<string>();
	for (Lead l : Trigger.New) {
		if (l.Lead_Created_From_Sales_Lead__c) {
			campaign.add(l.Lead_Submitted_By__c);
		}	
	}
	
	Map<string, id> campaignmap = new Map<string, id>();
	for (Campaign c : [select id, name from campaign where name in :campaign]) {
		campaignmap.put(c.name, c.id);	
	}
	
	List<CampaignMember> newmembers = new List<CampaignMember>();
	for (Lead l : Trigger.New) {
		if (l.Lead_Created_From_Sales_Lead__c) {
			if (campaignmap.containskey(l.Lead_Submitted_By__c)) {
				CampaignMember cm = new CampaignMember();
				cm.CampaignId = campaignmap.get(l.Lead_Submitted_By__c);
				cm.LeadId = l.id;
				cm.Status = 'Sent';
				newmembers.add(cm);
			}
		}	
	}
	
	if (newmembers.size() > 0)
		insert newmembers;
	
}