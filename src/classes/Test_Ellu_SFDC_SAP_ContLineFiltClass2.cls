@isTest(seeAllData=true)
 Public Class Test_Ellu_SFDC_SAP_ContLineFiltClass2 {
 
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
         //TempObjAccount.Price_Book__c = 'Tier 1';        
         TempObjAccount.Type = 'Client';        
         TempObjAccount.AccountNumber = 'X01';
         //TempObjAccount.Billing_Address_Name__c=ObjAdd.Id;
        // TempObjAccount.Shipping_Address_Name__c=ObjAdd.Id;        
         
         
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
         TempObjOpp.Business_Unit__c = 'SG51 - Ellucian Inc.';
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
            ObjContract.BillToCity__c = TempObjAccount.BillToCity__c ;
            ObjContract.CompanyCode__c='SG51';
            ObjContract.Status='Draft';
            //ObjContract.CurrencyIsoCode='USD';
            ObjContract.StartDate=TempObjOpp.CloseDate;
            ObjContract.ContractTerm=12;
            //ObjContract.Billing_AddressID__c=ObjAdd.Id;
            //ObjContract.Shipping_AddressID__c=ObjAdd.Id; 
            ObjContract.BillToFirstName__c=TempObjUser.FirstName;
            ObjContract.BillToLastName__c=TempObjUser.LastName;
            ObjContract.BillToStreetAddress1__c=TempObjOpp.Account.BillToStreetAddress1__c;
            ObjContract.BillToStreetAddress2__c=TempObjOpp.Account.BillToStreetAddress2__c;
            ObjContract.BillToCity__c=TempObjOpp.Account.BillToCity__c;
            ObjContract.BillToPostalcode__c=TempObjOpp.Account.BillToPostalcode__c;
            ObjContract.BillToState__c=TempObjOpp.Account.BillToState__c;
            ObjContract.BillToCountry__c=TempObjOpp.Account.BillToCountry__c;
            ObjContract.OpportunityId__c=TempObjOpp.Id;
            
            insert ObjContract;
            
            Pricebook2 ObjPricebook2 = new  Pricebook2(name = 'abc02');
            
            insert ObjPricebook2;  
            
            Contact ObjCon = new Contact( FirstName='ABC', LastName='XYZ');
            insert ObjCon;
            
            OpportunityContactRole ObjConRole = new OpportunityContactRole(OpportunityId=TempObjOpp.Id,ContactId=ObjCon.Id , IsPrimary=true );
            
            insert ObjConRole;
           
            product2 ObjProduct2 = new product2( Name='XYZ' , Family = 'Services');
            
            insert ObjProduct2;
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

            PricebookEntry ObjPricebookEntry = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct2.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            insert ObjPricebookEntry;
            
            OpportunityLineItem ObjOppLI = new OpportunityLineItem();
            ObjOppLI.OpportunityID=TempObjOpp.Id;
            //ObjOppLI.Discount_Amount__c=20;
            ObjOppLI.Discount_Percent__c=20;
            //ObjContractLine.LOB__c=TempObjOppLineItem.LOB__c;
            
            ObjOppLI.PricebookEntryId=ObjPricebookEntry.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjOppLI.Quantity=3;
            ObjOppLI.TotalPrice=300;
            ObjOppLI.Retail_Price__c=400;
            //ObjOppLI.UnitPrice=2;
            //ObjOppLI.ItemPrice__c=3;
            //ObjOppLI.ServicesEndDate__c=date.today()+2;
            //ObjOppLI.ServicesStartDate__c=date.today();
            //ObjOppLI.AgreementItemStartDate__c=date.today();
            //ObjOppLI.AgreementItemEndDate__c=date.today()+2;
            insert ObjOppLI;

            ContractLine__c ObjContractLine = new ContractLine__c();
            
            ObjContractLine.ContractID__c=ObjContract.Id;
            ObjContractLine.Discount_Amount__c=10;
            ObjContractLine.Discount_Percent__c=10;
            //ObjContractLine.LOB__c='Software Maintenance';
            
            ObjContractLine.ProductId__c=ObjProduct2.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine.Quantity__c=1;
            ObjContractLine.TotalPrice__c=100;
            ObjContractLine.Total_Retail_Price__c=100;
            ObjContractLine.UnitPrice__c=1;
            ObjContractLine.ItemPrice__c=1;
            ObjContractLine.ServicesEndDate__c=date.today()+2;
            ObjContractLine.ServicesStartDate__c=date.today();
            ObjContractLine.AgreementItemStartDate__c=date.today();
            ObjContractLine.AgreementItemEndDate__c=date.today()+2;
            
            ObjContractLine.Product_Family__c='Services';
            ObjContractLine.UnitofMeasure__c='EACH';
            ObjContractLine.OpportunityLineItemId__c=ObjOppLI.Id;
            ObjContractLine.Item_Type__c='Fixed Fee';
            ObjContractLine.BillingTerms__c='On Execution';

            insert ObjContractLine;
            
            Test.StartTest();
            
            Contract_Billing__c ObjConBill= new Contract_Billing__c(ContractId__c=ObjContract.Id , Billing_Type__c = 'Services' , Item_Type__c='Fixed Fee',Billing_Terms__c='On Execution');
            insert ObjConBill;
            ApexPages.currentPage().getParameters().put('ContractId__c',ObjContract.Id);
            ApexPages.StandardController stc = new ApexPages.StandardController(ObjContract);
            
             Ellu_SFDC_SAP_ContractLineFilterClass2 TempObjFilterClassInst = new  Ellu_SFDC_SAP_ContractLineFilterClass2(stc);
            
             
             TempObjFilterClassInst.setVfObjContBilling(ObjConBill); 
             TempObjFilterClassInst.getVfObjContBilling();  
             //TempObjFilterClassInst.VfObjContBilling.Item_Type__c='Fixed Fee';
             //TempObjFilterClassInst.VfObjContBilling.Billing_Type__c='Services';
             
             
             //TempObjFilterClassInst.runAssignIType();
             //TempObjFilterClassInst.runAssignBillTerms();
             TempObjFilterClassInst.ContinueToCreateBillRecords ();
             TempObjFilterClassInst.runAssign();
             TempObjFilterClassInst.RollupDetails ();
             TempObjFilterClassInst.getAllAssignConLineRecords ();
             TempObjFilterClassInst.getPageSize();
             TempObjFilterClassInst.getPreviousButtonEnabled();
             TempObjFilterClassInst.getNextButtonDisabled();
             TempObjFilterClassInst.getTotalPageNumber();
             TempObjFilterClassInst.nextBtnClick();
             TempObjFilterClassInst.previousBtnClick();
             TempObjFilterClassInst.getSortDirection();
             TempObjFilterClassInst.GoToOpportunity ();
             TempObjFilterClassInst.setSortDirection('xyz');
             
             Contract_Billing__c ObjConBill01= new Contract_Billing__c(ContractId__c=ObjContract.Id , Billing_Type__c = 'Services');
             insert ObjConBill01;
             
             TempObjFilterClassInst.setVfObjContBilling(ObjConBill01); 
             TempObjFilterClassInst.getVfObjContBilling();  
             TempObjFilterClassInst.runAssign(); 
             
             Contract_Billing__c ObjConBill02= new Contract_Billing__c(ContractId__c=ObjContract.Id , Billing_Type__c = 'Services' , Item_Type__c='Fixed Fee');
             insert ObjConBill02;
             TempObjFilterClassInst.setVfObjContBilling(ObjConBill02); 
             TempObjFilterClassInst.getVfObjContBilling();  
             TempObjFilterClassInst.runAssign();
             
             Test.StopTest();
             
  }
 }