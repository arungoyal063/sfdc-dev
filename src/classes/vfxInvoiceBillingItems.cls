public with sharing class vfxInvoiceBillingItems 
{
    public RMA_Invoice__c theInvoice { get; set; }
    public List<Billing_Line_Item__c> theLineItemsToInvoice { get; set; }

    private Id theInvoiceId;
    private ApexPages.StandardController theController;
    

    
    public void InitializeController()
    {
        theInvoice = 
            [
                select 
                    Id, Account__c, Account__r.name, Invoice_Total__c 
                from 
                    RMA_Invoice__c 
                where 
                    Id = :theInvoiceId
            ]; 

        theLineItemsToInvoice = 
            [
                select 
                    Id, Invoiced__c, Line_Item_Charge__c, Timecard__r.Appirio_PSAe__SFDC_Resource__r.Name,
                    Project__r.Name,  Date__c, hours__c, Rate_per_Hour__c, Notes__c
                from 
                    Billing_Line_Item__c 
                where 
                    Invoiced__c = 'Not Invoiced' 
                    and 
                    Project__r.Appirio_PSAe__Account__c = :theInvoice.Account__c
                order by
                    Date__c, Project__r.Name,  Timecard__r.Appirio_PSAe__SFDC_Resource__r.Name
            ];
    }

    public vfxInvoiceBillingItems(ApexPages.StandardController newController) 
    {
        theController = newController;
        theInvoiceId = theController.getRecord().Id;
        InitializeController();
    }

    public vfxInvoiceBillingItems(Id InvoiceId) 
    {
        theInvoiceId = InvoiceId;
        InitializeController();
    }

    public static testMethod void testme() 
    {
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
        
                
        RMA_Invoice__c quote = new RMA_Invoice__c();
        quote.Account__c = a.id;
        insert quote;
        
        vfxInvoiceBillingItems y = new vfxInvoiceBillingItems(quote.id);
        y.CompleteInvoice();    
    }
    
    public PageReference CompleteInvoice() 
    {
        double Amount = 0;
        
        if (theInvoice.Invoice_Total__c != null) 
            Amount = theInvoice.Invoice_Total__c;
        
        List<Invoice_Line_Item__c> lineitems = new List<Invoice_Line_Item__c>();
        
        for (Billing_Line_Item__c BillingLineItem : theLineItemsToInvoice) 
        {
            Amount += BillingLineItem.Line_Item_Charge__c;
            BillingLineItem.invoiced__c = 'Invoiced';
            //BillingLineItem.invoice__c = theInvoice.id;
            
            
            Invoice_Line_Item__c lineitem = new Invoice_Line_Item__c();
            lineitem.Timecard__c = BillingLineItem.Timecard__c;
            lineitem.Project__c = billinglineitem.Project__c ;
            lineitem.Timecard__c = billinglineitem.Timecard__c ;
            lineitem.Date__c = billinglineitem.Date__c ;
            lineitem.Hours__c = billinglineitem.Hours__c ;
            lineitem.Invoiced__c = billinglineitem.Invoiced__c ;
            lineitem.Notes__c = billinglineitem.Notes__c ;
            lineitem.Rate_Per_Hour__c = billinglineitem.Rate_Per_Hour__c ;
            lineitem.Invoice__c = theInvoice.id;
            
            lineitems.add(lineitem);
            
        }
        
        theInvoice.Invoice_Total__c = Amount;
        
        update theInvoice;
        
        if (lineitems.size() > 0) insert lineitems;
        if (theLineItemsToInvoice.size() > 0) update theLineItemsToInvoice;
        
        PageReference NewPage = new PageReference('/' + theInvoiceId);
        NewPage.setRedirect(true); 
        return NewPage;

    }

}