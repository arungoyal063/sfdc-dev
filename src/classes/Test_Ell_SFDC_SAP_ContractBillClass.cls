@isTest
Public Class Test_Ell_SFDC_SAP_ContractBillClass {


    static testMethod void myUnitTest() {
         
         User TempObjUser=[SELECT Id,FirstName,LastName, EmployeeNumber FROM User WHERE Id=:UserInfo.getUserId() ];
         
         Address__c ObjAdd= new Address__c();
         ObjAdd.City__c='Malvern';
         //ObjAdd.AccountId__c=TempObjAccount.Id
         ObjAdd.Country__c='United States';
         ObjAdd.Postal_Code__c='12345';
         ObjAdd.State__c='Pensylvenia';
         ObjAdd.Street_Address1__c='XYZ1';
         ObjAdd.Street_Address2__c='XYZ2';
          
         insert ObjAdd;
                    
         Account TempObjAccount = new Account();
         TempObjAccount.OwnerId=TempObjUser.Id;        
         TempObjAccount.Name = 'Test'; 
         TempObjAccount.BillToCity__c = 'Malvern';       
         TempObjAccount.CRM_Org_ID__c = 'test';        
                 
         TempObjAccount.Type = 'Client';        
         TempObjAccount.AccountNumber = 'X01';
        
         //TempObjAccount.Billing_Address_Name__c=ObjAdd.Id;
        // TempObjAccount.Shipping_Address_Name__c=ObjAdd.Id;        
         //TempObjAccount.Price_Book__c = 'Tier 4C';
         
         insert TempObjAccount;
         
         ObjAdd.AccountId__c=TempObjAccount.Id;
         
         update ObjAdd;
         
         TempObjAccount.Billing_Address_Name__c=ObjAdd.Id;
         TempObjAccount.Shipping_Address_Name__c=ObjAdd.Id;
         
         update TempObjAccount;
Contact con = new Contact(LastName = 'OptyTester');
con.AccountId = TempObjAccount.Id;
con.Inactive__c = false;
Insert con;
    
     
         Opportunity TempObjOpp=new Opportunity();
         
         TempObjOpp.accountid = TempObjAccount.id;        
         TempObjOpp.name = 'partner test';        
         TempObjOpp.amount = 100;        
         TempObjOpp.closedate = Date.today();        
         //TempObjOpp.recordtypeid = '012G0000000yBnDIAU';        
         TempObjOpp.stagename = 'Proposal';        
         TempObjOpp.LeadSource = 'Contract Vehicle';        
         TempObjOpp.Has_Primary_Contact__c = TRUE;        
         TempObjOpp.Type = 'CBR';        
         TempObjOpp.Category__c = 'Strategic Solutions';        
         TempObjOpp.Summary__c ='Recruiter';        
         TempObjOpp.Primary_Contact_2__c = con.Id;
         insert TempObjOpp;
         
         
         Contract ObjContract = new Contract();
            ObjContract.AccountID=TempObjOpp.AccountID;
            //ObjContract.BillToId__c=TempObjOpp.AccountID;
            //ObjContract.ShipToId__c=TempObjOpp.AccountID;
            ObjContract.CompanyCode__c='SG51';
            ObjContract.Status='Draft';
            //ObjContract.CurrencyIsoCode='USD';
            ObjContract.StartDate=TempObjOpp.CloseDate;
            ObjContract.ContractTerm=12;
            
            ObjContract.BillToFirstName__c=TempObjUser.FirstName;
            ObjContract.BillToLastName__c=TempObjUser.LastName;
            ObjContract.BillToStreetAddress1__c=TempObjOpp.Account.BillToStreetAddress1__c;
            ObjContract.BillToStreetAddress2__c=TempObjOpp.Account.BillToStreetAddress2__c;
            ObjContract.BillToCity__c=TempObjOpp.Account.BillToCity__c;
            ObjContract.BillToPostalcode__c=TempObjOpp.Account.BillToPostalcode__c;
            ObjContract.BillToState__c=TempObjOpp.Account.BillToState__c;
            ObjContract.BillToCountry__c=TempObjOpp.Account.BillToCountry__c;
            ObjContract.OpportunityId__c=TempObjOpp.Id;
            ObjContract.ContractExecutionDate__c=ObjContract.StartDate;
            insert ObjContract;
            
            Ellu_Software_Billing__c ObjElluSoftBill= new  Ellu_Software_Billing__c();
            ObjElluSoftBill = new Ellu_Software_Billing__c(Name='Software',Item_Type__c='Software',Billing_Terms__c='On Execution',Percentage_OR_Amount__c='Payment Percentage',Payment_Timing__c = 'Monthly',Number_Of_Payment__c=1,Payment_Percentage__c=100);
            insert ObjElluSoftBill;
            
            Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluCustDefRecExcepSoft = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
            ObjElluCustDefRecExcepSoft= new Ellu_CustDefaultBillRecordsExcepSoftware__c(Name='Fixed Services',Item_Type__c='Fixed',Billing_Terms__c='On Execution',Percentage_OR_Amount__c='Payment Percentage',Payment_Timing__c = 'Monthly',Number_Of_Payment__c=1,Payment_Percentage__c=100,Product_Family__c='Services');
            insert ObjElluCustDefRecExcepSoft;
            
            ApexPages.currentPage().getParameters().put('ContractId__c',ObjContract.Id);
            ApexPages.currentPage().getParameters().put('Item_Type__c','Software');
            ApexPages.currentPage().getParameters().put('Billing_Type__c','Software');
            ApexPages.currentPage().getParameters().put('Total_Amount__c','345');
            //ApexPages.currentPage().getParameters().put('Grouping_Type','On Execution');
            ApexPages.currentPage().getParameters().put('Payment_Timing__c','Monthly');
            
            ApexPages.StandardController stc = new ApexPages.StandardController(ObjContract);

            Ellu_SFDC_SAP_ContBill_Class02 TempObjBillClassInst = new Ellu_SFDC_SAP_ContBill_Class02(stc);
            
            Test.StartTest();
            
             Contract_Billing__c ObjCon= new Contract_Billing__c(ContractId__c=ObjContract.Id/*,CurrencyIsoCode='USA'*/,Comments__c='XYZ',NumberofPayments__c=1,Percentage_OR_Amount__c='Payment Amount',
                                                                           Payment_Timing__c='Monthly',Total_Amount__c=3456,Billing_Type__c='Software',BillingDate__c=ObjContract.StartDate,PaymentPercentage__c=100 );
               TempObjBillClassInst.setVfObjContBilling(ObjCon);
               TempObjBillClassInst.getVfObjContBilling();
               TempObjBillClassInst.GoToOpportunity ();
               TempObjBillClassInst.DependencyPick ();
               TempObjBillClassInst.MethPayTiming ();
               TempObjBillClassInst.BoolPercentage=true;
               //TempObjBillClassInst.BoolPaymentAm=true;
               TempObjBillClassInst.Save();
   
               TempObjBillClassInst.SaveAndNew();
               //Ellu_SFDC_SAP_ContBill_Class TempObjBillClassInst = new Ellu_SFDC_SAP_ContBill_Class(stc);
            
            
            ApexPages.currentPage().getParameters().put('ContractId__c',ObjContract.Id);
            ApexPages.currentPage().getParameters().put('Item_Type__c','Software');
            ApexPages.currentPage().getParameters().put('Billing_Type__c','On Execution');
            ApexPages.currentPage().getParameters().put('Total_Amount__c','345');
            ApexPages.currentPage().getParameters().put('Grouping_Type','On Execution');
            ApexPages.currentPage().getParameters().put('Payment_Timing__c','Monthly');
            
            ApexPages.StandardController stc01 = new ApexPages.StandardController(ObjContract);

            Ellu_SFDC_SAP_ContBill_Class02 TempObjBillClassInst01 = new Ellu_SFDC_SAP_ContBill_Class02(stc01);
            

            
            Contract_Billing__c ObjCon01= new Contract_Billing__c(ContractId__c=ObjContract.Id/*,CurrencyIsoCode='USA'*/,Comments__c='XYZ',NumberofPayments__c=2,Percentage_OR_Amount__c='Payment Percentage',
                                                                           Payment_Timing__c='Monthly',Total_Amount__c=3456,Billing_Type__c='On Execution',BillingDate__c= ObjContract.StartDate,PaymentPercentage__c=50 );
               TempObjBillClassInst01.setVfObjContBilling(ObjCon01);
               TempObjBillClassInst01.getVfObjContBilling();
               TempObjBillClassInst01.DependencyPick ();
               TempObjBillClassInst01.BoolPercentage=true;
               TempObjBillClassInst01.PerOrAmount ();
               //TempObjBillClassInst.BoolPaymentAm=true;
               TempObjBillClassInst01.Save();
               TempObjBillClassInst01.SaveAndNew();
               TempObjBillClassInst01.SaveAndNew();
               TempObjBillClassInst01.Save();
               
               
            ApexPages.currentPage().getParameters().put('ContractId__c',ObjContract.Id);
            ApexPages.currentPage().getParameters().put('Item_Type__c','Software');
            ApexPages.currentPage().getParameters().put('Billing_Type__c','On Execution');
            ApexPages.currentPage().getParameters().put('Total_Amount__c','100');
            ApexPages.currentPage().getParameters().put('Grouping_Type','On Execution');
            ApexPages.currentPage().getParameters().put('Payment_Timing__c','Monthly');
            
               ApexPages.StandardController stc02 = new ApexPages.StandardController(ObjContract);

               Ellu_SFDC_SAP_ContBill_Class02 TempObjBillClassInst02 = new Ellu_SFDC_SAP_ContBill_Class02(stc01);
               
               Contract_Billing__c ObjCon02= new Contract_Billing__c(ContractId__c=ObjContract.Id/*,CurrencyIsoCode='USA'*/,Comments__c='XYZ',NumberofPayments__c=2,Percentage_OR_Amount__c='Payment Amount',
                                                                           Payment_Timing__c='Monthly',Total_Amount__c=3456,Billing_Type__c='On Execution',BillingDate__c= ObjContract.StartDate,Payment_Amount__c=50 );
               TempObjBillClassInst02.setVfObjContBilling(ObjCon02);
               TempObjBillClassInst02.getVfObjContBilling();
               TempObjBillClassInst02.DependencyPick ();
               TempObjBillClassInst02.BoolPercentage=true;
               TempObjBillClassInst02.PerOrAmount ();
               //TempObjBillClassInst.BoolPaymentAm=true;
               TempObjBillClassInst02.Save();
               TempObjBillClassInst02.SaveAndNew();
               TempObjBillClassInst02.SaveAndNew();
               TempObjBillClassInst02.Save();
               
               Ellu_SFDC_SAP_ContBill_Class02 TempObjBillClassInst03 = new Ellu_SFDC_SAP_ContBill_Class02(stc01);
               Contract_Billing__c ObjCon03= new Contract_Billing__c(ContractId__c=ObjContract.Id/*,CurrencyIsoCode='USA'*/,Comments__c='XYZ',NumberofPayments__c=2,Percentage_OR_Amount__c='Payment Amount',
                                                                           Payment_Timing__c='Monthly',Total_Amount__c=3456,Billing_Type__c='On Execution',BillingDate__c= ObjContract.StartDate,Payment_Amount__c=50 );
               TempObjBillClassInst03.setVfObjContBilling(ObjCon03);
               TempObjBillClassInst03.getVfObjContBilling();
               TempObjBillClassInst03.DependencyPick ();
               TempObjBillClassInst03.BoolPaymentAm=true;
              // TempObjBillClassInst03.BoolPercentage=true;
               TempObjBillClassInst03.PerOrAmount ();
               TempObjBillClassInst03.BoolPaymentAm=true;
               TempObjBillClassInst03.Save();
               TempObjBillClassInst03.SaveAndNew();
               TempObjBillClassInst03.SaveAndNew();
               TempObjBillClassInst03.Save();
               
               
               Ellu_SFDC_SAP_ContBill_Class02 TempObjBillClassInst04 = new Ellu_SFDC_SAP_ContBill_Class02(stc01);
               Contract_Billing__c ObjCon04= new Contract_Billing__c(ContractId__c=ObjContract.Id/*,CurrencyIsoCode='USA'*/,Comments__c='XYZ',NumberofPayments__c=2,Percentage_OR_Amount__c='Payment Amount',
                                                                           Total_Amount__c=3456,Billing_Type__c='On Execution',BillingDate__c= ObjContract.StartDate,Payment_Amount__c=50 );
               TempObjBillClassInst04.setVfObjContBilling(ObjCon04);
               TempObjBillClassInst04.getVfObjContBilling();
               TempObjBillClassInst04.DependencyPick ();
               TempObjBillClassInst04.BoolPaymentAm=true;
              // TempObjBillClassInst03.BoolPercentage=true;
               TempObjBillClassInst04.PerOrAmount ();
               TempObjBillClassInst04.BoolPaymentAm=true;
               try{
               TempObjBillClassInst04.Save();
               TempObjBillClassInst04.SaveAndNew();
               
               //TempObjBillClassInst04.SaveAndNew();
               //TempObjBillClassInst04.Save();
               }
               catch(exception e){
               } 
               
               Test.StopTest();
               //TempObjBillClassInst.SaveAndCreateServiceBilling();
               //TempObjBillClassInst.GoToOpportunity();
               
            /*
           // TempObjBillClassInst.VfObjContBilling.NumberofPayments__c=3;
            TempObjBillClassInst.VfVarNum=1;
            
            TempObjBillClassInst.VfObjContBilling.ContractId__c=ObjContract.Id;
            //TempObjBillClassInst.VfObjContBilling.CurrencyIsoCode='USA';
            TempObjBillClassInst.VfObjContBilling.Comments__c='XYZ';
            TempObjBillClassInst.VfObjContBilling.NumberofPayments__c=1;
            TempObjBillClassInst.VfObjContBilling.DaysfromEvent__c='5';
            TempObjBillClassInst.VfObjContBilling.Percentage_OR_Amount__c='Payment Percentage';
           // TempObjBillClassInst.VfObjContBilling.Billing_Terms__c='On Execution';
            TempObjBillClassInst.VfObjContBilling.Item_Type__c='Software';
            TempObjBillClassInst.VfObjContBilling.PaymentPercentage__c=25;
            TempObjBillClassInst.VfObjContBilling.BillingDate__c=null;
            TempObjBillClassInst.VfObjContBilling.Payment_Amount__c=null;
            TempObjBillClassInst.VfObjContBilling.Payment_Timing__c='On Execution';
            TempObjBillClassInst.VfObjContBilling.Total_Amount__c=3456;
            TempObjBillClassInst.VfObjContBilling.Billing_Type__c='Software';
            TempObjBillClassInst.BoolPercentage=true;
            //TempObjBillClassInst.BoolPaymentAm=true;
            TempObjBillClassInst.PerOrAmount ();
            TempObjBillClassInst.DependencyPick (); 
             
            TempObjBillClassInst.SaveAndNew ();
            TempObjBillClassInst.Save ();
            TempObjBillClassInst.SaveAndCreateServiceBilling();
            //TempObjBillClassInst.VfObjContBilling.Percentage_OR_Amount__c='Payment Amount';
            //TempObjBillClassInst.SaveAndNew ();
            TempObjBillClassInst.VarHnPercent=75;
            TempObjBillClassInst.VfVarNum=4;
            //TempObjBillClassInst.SaveAndNew ();
            TempObjBillClassInst.Save ();
            TempObjBillClassInst.SaveAndCreateServiceBilling();

            Ellu_SFDC_SAP_ContBill_Class TempObjBillClassInst01 = new Ellu_SFDC_SAP_ContBill_Class(stc);

            TempObjBillClassInst01.VfVarNum=1;
            TempObjBillClassInst01.VfObjContBilling.ContractId__c=ObjContract.Id;
            //TempObjBillClassInst01.VfObjContBilling.CurrencyIsoCode='USA';
            TempObjBillClassInst01.VfObjContBilling.Comments__c='XYZ';
            TempObjBillClassInst01.VfObjContBilling.NumberofPayments__c=4;
            TempObjBillClassInst01.VfObjContBilling.DaysfromEvent__c='5';
            TempObjBillClassInst01.VfObjContBilling.Percentage_OR_Amount__c='Payment Amount';
            //TempObjBillClassInst01.VfObjContBilling.Billing_Terms__c='On Execution';
            TempObjBillClassInst01.VfObjContBilling.Item_Type__c='Fixed';
            //TempObjBillClassInst01.VfObjContBilling.PaymentPercentage__c=100;
            TempObjBillClassInst01.VfObjContBilling.Payment_Amount__c=1000;
            TempObjBillClassInst01.VfObjContBilling.BillingDate__c=null;
            TempObjBillClassInst01.VfObjContBilling.Payment_Amount__c=null;
            TempObjBillClassInst01.VfObjContBilling.Payment_Timing__c='On Execution';
            TempObjBillClassInst01.VfObjContBilling.Total_Amount__c=4000;
            TempObjBillClassInst01.VfObjContBilling.Billing_Type__c='Services';
            TempObjBillClassInst01.BoolPercentage=false;
            TempObjBillClassInst01.BoolPaymentAm=true;
            TempObjBillClassInst01.PerOrAmount ();
            TempObjBillClassInst01.DependencyPick ();  
            TempObjBillClassInst01.SaveAndNew ();
             TempObjBillClassInst01.GoToOpportunity ();

            TempObjBillClassInst01.VfVarNum=4;
            //TempObjBillClassInst01.Save ();
            
            TempObjBillClassInst01.VarHnAmount=3000;
            
            TempObjBillClassInst01.Save ();

            //TempObjBillClassInst.VfVarNum=3;
            TempObjBillClassInst01.SaveAndCreateServiceBilling(); */

                        
         
         }
}