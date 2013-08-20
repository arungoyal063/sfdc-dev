public with sharing class vfxProjectBillingItems {

    public Billing_Line_Item__c b {get; set;}
    Id projectid;
    ApexPages.StandardController c;
    
    public vfxProjectBillingItems(ApexPages.StandardController controller) {
        c = controller;
        projectid = c.getRecord().id;
        b = new Billing_Line_Item__c();
    }

    public vfxProjectBillingItems(Id project) {
        projectid = project;
        b = new Billing_Line_Item__c();
        b.date__c = date.valueOf('2010-02-20');
    }

    public static testMethod void testme() {
        Account a = new account();
        a.name = 'Test';
        insert a;
        
        // added code 
        // create oOpportunity
        Opportunity opp = new Opportunity();   
        opp.AccountId = a.Id;  
        opp.Name = 'testOpp';
        opp.CloseDate = System.Today()+7;
        opp.StageName = 'Qualification';
        opp.ForecastCategoryName = 'Pipeline';
        opp.Deposit_Amount__c = 20000;
        opp.Total_number_users__c = 2;
        insert opp;
    
        Appirio_PSAe__Proj__c p = new Appirio_PSAe__Proj__c();
        p.Name = 'test';
        p.Appirio_PSAe__Account__c = a.id;
        p.Appirio_PSAe__Project_Stage__c = 'Development';
        p.Appirio_PSAe__Type__c = 'xxx';
        p.rate__c = 100;
        p.Appirio_PSAe__Opportunity__c = opp.Id;
        p.Appirio_PSAe__Hours_Allocated__c = 200;
        insert p; 
        
        
        
        Appirio_PSAe__Resource__c r = [select id from Appirio_PSAe__Resource__c limit 1];
        Appirio_PSAe__Assignment__c assignObj = Util.createAssignment(r.id, p.id);
        
        Appirio_PSAe__Timecard__c t = new Appirio_PSAe__Timecard__c();
        t.Appirio_PSAe__SFDC_Resource__c = r.id;
        t.Appirio_PSAe__Bill_To__c = 'Billable'; 
		t.Appirio_PSAe__Assignment__c =  assignObj.id;
		

        t.Appirio_PSAe__Sun__c = 1;
        t.Appirio_PSAe__Week_Ending__c = date.valueOf('2010-02-20');
        t.Appirio_PSAe__Notes_Sun__c = 'Worked';
        t.Appirio_PSAe__SFDC_Projects__c = p.id;
        t.Appirio_PSAe__Mon__c = 1;
        t.Appirio_PSAe__Notes_Mon__c = 'Worked';
        t.Appirio_PSAe__Tue__c = 1; 
        t.Appirio_PSAe__Notes_Tue__c = 'Worked';
        t.Appirio_PSAe__Wed__c = 1;
        t.Appirio_PSAe__Notes_Wed__c = 'Worked';
        t.Appirio_PSAe__Thur__c = 1;
        t.Appirio_PSAe__Notes_Thu__c = 'Worked';
        t.Appirio_PSAe__Fri__c = 1;
        t.Appirio_PSAe__Notes_Fri__c = 'Worked';
        t.Appirio_PSAe__Sat__c = 1;
        t.Appirio_PSAe__Notes_Sat__c = 'Worked';
        t.Appirio_PSAe__Status__c = 'Approved';
        insert t;
                
        vfxProjectBillingItems x = new vfxProjectBillingItems(p.id);
        x.pushbill();
    
        
    }
    public PageReference pushbill() {

        List<Billing_Line_Item__c> newitems = new List<Billing_Line_Item__c>();
      //  RMA_Invoice__c dummy = [select id from RMA_Invoice__c where name = 'Rainmaker Invoice-06166'];
        List<appirio_PSAe__Timecard__c> cards = new List<appirio_PSAe__Timecard__c>();
        for (appirio_PSAe__Timecard__c t : [select id, 
                    Appirio_PSAe__Bill_To__c,
                    Appirio_PSAe__Sun__c, Appirio_PSAe__Week_Ending__c, Appirio_PSAe__Notes_Sun__c, Appirio_PSAe__SFDC_Projects__c,
                    Appirio_PSAe__Mon__c, Appirio_PSAe__Notes_Mon__c,
                    Appirio_PSAe__Tue__c, Appirio_PSAe__Notes_Tue__c,
                    Appirio_PSAe__Wed__c, Appirio_PSAe__Notes_Wed__c,
                    Appirio_PSAe__Thur__c, Appirio_PSAe__Notes_Thu__c,
                    Appirio_PSAe__Fri__c, Appirio_PSAe__Notes_Fri__c,
                    Appirio_PSAe__Sat__c, Appirio_PSAe__Notes_Sat__c, Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c,
                    Appirio_PSAe__SFDC_Projects__r.Rate__c from appirio_PSAe__Timecard__c where Appirio_PSAe__SFDC_Projects__c = :projectid and Appirio_PSAe__Status__c = 'Approved' and Appirio_PSAe__Week_Ending__c <= :b.date__c]) {
            boolean billed = false;
            if (t.Appirio_PSAe__Sun__c != null && t.Appirio_PSAe__Sun__c > 0) {
                Billing_Line_Item__c item = new Billing_Line_Item__c();
                //item.Invoice__c = dummy.id;
                item.Date__c = t.Appirio_PSAe__Week_Ending__c.AddDays(-6);
                item.Hours__c =  t.Appirio_PSAe__Sun__c;
                item.Notes__c = t.Appirio_PSAe__Notes_Sun__c;
                item.Project__c = t.Appirio_PSAe__SFDC_Projects__c;
                if (t.Appirio_PSAe__Bill_To__c == 'Billable')
                    //Changed SM WO 1101 Get rate from Assignment instead of Project
                    //item.Rate_Per_Hour__c = t.Appirio_PSAe__SFDC_Projects__r.Rate__c;
                    item.Rate_Per_Hour__c = t.Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c;
                else
                    item.Rate_Per_Hour__c = 0;
                item.TimeCard__c = t.id;
                item.Invoiced__c = 'Not Invoiced';
                newitems.add(item);
                billed = true;
            }
            
            if (t.Appirio_PSAe__Mon__c != null && t.Appirio_PSAe__Mon__c > 0) {
                Billing_Line_Item__c item1 = new Billing_Line_Item__c();
                //item1.Invoice__c = dummy.id;
                item1.Date__c = t.Appirio_PSAe__Week_Ending__c.AddDays(-5);
                item1.Hours__c =  t.Appirio_PSAe__Mon__c;
                item1.Notes__c = t.Appirio_PSAe__Notes_Mon__c;
                item1.Project__c = t.Appirio_PSAe__SFDC_Projects__c;
                if (t.Appirio_PSAe__Bill_To__c == 'Billable')
                    //item1.Rate_Per_Hour__c = t.Appirio_PSAe__SFDC_Projects__r.Rate__c;
                    item1.Rate_Per_Hour__c = t.Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c;
                  
                else
                    item1.Rate_Per_Hour__c = 0;
                item1.TimeCard__c = t.id;
                item1.Invoiced__c = 'Not Invoiced';
                newitems.add(item1);
                billed = true;
            }
            if (t.Appirio_PSAe__Tue__c != null && t.Appirio_PSAe__Tue__c > 0) {
                Billing_Line_Item__c item2 = new Billing_Line_Item__c();
                //item2.Invoice__c = dummy.id;
                item2.Date__c = t.Appirio_PSAe__Week_Ending__c.AddDays(-4);
                item2.Hours__c =  t.Appirio_PSAe__Tue__c;
                item2.Notes__c = t.Appirio_PSAe__Notes_Tue__c;
                item2.Project__c = t.Appirio_PSAe__SFDC_Projects__c;
                if (t.Appirio_PSAe__Bill_To__c == 'Billable')
                    item2.Rate_Per_Hour__c = t.Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c;
                   // item2.Rate_Per_Hour__c = t.Appirio_PSAe__SFDC_Projects__r.Rate__c;
                    
                else
                    item2.Rate_Per_Hour__c = 0;
                item2.TimeCard__c = t.id;
                item2.Invoiced__c = 'Not Invoiced';
                newitems.add(item2);
                billed = true;
            }
            if (t.Appirio_PSAe__Wed__c != null && t.Appirio_PSAe__Wed__c > 0) {
                Billing_Line_Item__c item3 = new Billing_Line_Item__c();
                //item3.Invoice__c = dummy.id;
                item3.Date__c = t.Appirio_PSAe__Week_Ending__c.AddDays(-3);
                item3.Hours__c =  t.Appirio_PSAe__Wed__c;
                item3.Notes__c = t.Appirio_PSAe__Notes_Wed__c;
                item3.Project__c = t.Appirio_PSAe__SFDC_Projects__c;
                if (t.Appirio_PSAe__Bill_To__c == 'Billable')
                    item3.Rate_Per_Hour__c = t.Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c;
                    //item3.Rate_Per_Hour__c = t.Appirio_PSAe__SFDC_Projects__r.Rate__c;
                else
                    item3.Rate_Per_Hour__c = 0;
                item3.TimeCard__c = t.id;
                item3.Invoiced__c = 'Not Invoiced';
                newitems.add(item3);
                billed = true;
            }
            if (t.Appirio_PSAe__Thur__c != null && t.Appirio_PSAe__Thur__c > 0) {
                Billing_Line_Item__c item4 = new Billing_Line_Item__c();
                //item4.Invoice__c = dummy.id;
                item4.Date__c = t.Appirio_PSAe__Week_Ending__c.AddDays(-2);
                item4.Hours__c =  t.Appirio_PSAe__Thur__c;
                item4.Notes__c = t.Appirio_PSAe__Notes_Thu__c;
                item4.Project__c = t.Appirio_PSAe__SFDC_Projects__c;
                if (t.Appirio_PSAe__Bill_To__c == 'Billable')
                    //item4.Rate_Per_Hour__c = t.Appirio_PSAe__SFDC_Projects__r.Rate__c;
                    item4.Rate_Per_Hour__c = t.Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c;
                    
                else
                    item4.Rate_Per_Hour__c = 0;
                item4.TimeCard__c = t.id;
                item4.Invoiced__c = 'Not Invoiced';
                newitems.add(item4);
                billed = true;
            }
            if (t.Appirio_PSAe__Fri__c != null && t.Appirio_PSAe__Fri__c > 0) {
                Billing_Line_Item__c item5 = new Billing_Line_Item__c();
                //item5.Invoice__c = dummy.id;
                item5.Date__c = t.Appirio_PSAe__Week_Ending__c.AddDays(-1);
                item5.Hours__c =  t.Appirio_PSAe__Fri__c;
                item5.Notes__c = t.Appirio_PSAe__Notes_Fri__c;
                item5.Project__c = t.Appirio_PSAe__SFDC_Projects__c;
                if (t.Appirio_PSAe__Bill_To__c == 'Billable')
                    //item.Rate_Per_Hour__c = t.Appirio_PSAe__SFDC_Projects__r.Rate__c;
                    item5.Rate_Per_Hour__c = t.Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c;
                   
                else
                    item5.Rate_Per_Hour__c = 0;
                item5.TimeCard__c = t.id;
                item5.Invoiced__c = 'Not Invoiced';
                newitems.add(item5);
                billed = true;
            }
            if (t.Appirio_PSAe__Sat__c != null && t.Appirio_PSAe__Sat__c > 0) {
                Billing_Line_Item__c item6 = new Billing_Line_Item__c();
                //item6.Invoice__c = dummy.id;
                item6.Date__c = t.Appirio_PSAe__Week_Ending__c;
                item6.Hours__c =  t.Appirio_PSAe__Sat__c;
                item6.Notes__c = t.Appirio_PSAe__Notes_Sat__c;
                item6.Project__c = t.Appirio_PSAe__SFDC_Projects__c;
                if (t.Appirio_PSAe__Bill_To__c == 'Billable')
                    //item6.Rate_Per_Hour__c = t.Appirio_PSAe__SFDC_Projects__r.Rate__c;
                    item6.Rate_Per_Hour__c = t.Appirio_PSAe__Assignment__r.Appirio_PSAe__Rate_Per_Hour__c;
                   
                else
                    item6.Rate_Per_Hour__c = 0;
                item6.TimeCard__c = t.id;
                item6.Invoiced__c = 'Not Invoiced';
                newitems.add(item6);
                billed = true;
            }

            if (billed) {
                t.Appirio_PSAe__Status__c = 'Billed';
                cards.add(t);
            }
                


        }
            System.debug('newitems....'+newitems.size());
        if (newitems.size() > 0) insert newitems;
        if (cards.size() > 0) update cards;
        
        PageReference NewPage = new PageReference('/' + projectid);
        NewPage.setRedirect(true); 
        return NewPage;
    }
}