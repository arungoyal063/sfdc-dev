@isTest
private class LeadTests {

    static testMethod void testLeadMethod() {
Account a = new Account();        a.Name = 'TestAccount';    
    a.CRM_Org_ID__c = 'testAccount';              a.Type = 'Client';        a.AccountNumber = 'X0102';        insert a;                       update a;
Lead lead = new Lead();        lead.LastName = 'Derp';        lead.FirstName = 'Herp';        lead.Company = 'Wingo Ducks';        lead.LeadSource = 'Web Site';        lead.Status = 'Open - Not Contacted';        lead.Account__c = a.Id;        insert lead;                Database.LeadConvert lc = new Database.LeadConvert();        lc.accountId = a.Id;        lc.setLeadId(lead.Id);        lc.setConvertedStatus('Converted');        Database.LeadConvertResult lcr = Database.convertLead(lc);
}
}