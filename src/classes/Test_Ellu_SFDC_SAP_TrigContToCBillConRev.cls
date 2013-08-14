@isTest 
Public Class Test_Ellu_SFDC_SAP_TrigContToCBillConRev {

     static testMethod void myUnitTest() {
     
         User TempObjUser = new User();
         TempObjUser=[SELECT Id,FirstName,LastName, EmployeeNumber FROM User WHERE Id=:UserInfo.getUserId()]; 
         //TemObjUser.EmployeeNumber='1234';
         //Insert TempObjUser;
         
         Address__c ObjAdd= new Address__c();
         ObjAdd.City__c='Malvern';
         //ObjAdd.AccountId__c=TempObjAccount.Id
         ObjAdd.Country__c='United States';
         ObjAdd.Postal_Code__c='12345';
         ObjAdd.State__c='Pensylvenia';
         ObjAdd.Street_Address1__c='XYZ1';
         ObjAdd.Street_Address2__c='XYZ2';
        ObjAdd.Billing_Contact__c='Mr. Anderson';
          
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
         TempObjAccount.Short_Name__c='xyz';
         TempObjAccount.Total_Enrollment__c=123;
         TempObjAccount.Solutions_Sales_Region__c='xyz';
         TempObjAccount.Solutions_Service_Region__c='abc';
         //TempObjAccount.BillToCountry__c='USA';
         //TempObjAccount.BillToPostalCode__c='1234';
         //TempObjAccount.BillToState__c='CA';
         TempObjAccount.Payment_Terms__c='NET 30';
         TempObjAccount.Epicor_GM__c=TempObjUser.Id;
         TempObjAccount.VP_Services__c=TempObjUser.Id;       
         TempObjAccount.TM_Territory__c=TempObjUser.Id;
         TempObjAccount.Country__c='USA';
         TempObjAccount.City__c='Malvern';
         TempObjAccount.ZipCode__c='12345';
         TempObjAccount.State__c='Pensylvenia';

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
         //TempObjOpp.Epicor_GM__c
         //TempObjOpp.VP_Services__c
         
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
            ObjContract.BillToStreetAddress1__c=ObjAdd.Street_Address1__c;
            ObjContract.BillToStreetAddress2__c=ObjAdd.Street_Address2__c;
            ObjContract.BillToCity__c=ObjAdd.City__c;
            ObjContract.BillToPostalcode__c=ObjAdd.Postal_Code__c;
            ObjContract.BillToState__c=ObjAdd.State__c;
            ObjContract.BillToCountry__c=ObjAdd.Country__c;
            ObjContract.BillToId__c=ObjAdd.Id;
            ObjContract.ShipToFirstName__c=TempObjUser.FirstName;
            ObjContract.ShipToLastName__c=TempObjUser.LastName;
            ObjContract.ShipToStreetAddress1__c=ObjAdd.Street_Address1__c;
            ObjContract.ShipToPostalCode__c=ObjAdd.Postal_Code__c;
            ObjContract.ShipToCity__c=ObjAdd.City__c;
            ObjContract.ShipToState__c=ObjAdd.State__c;
            ObjContract.ShipToCountry__c=ObjAdd.Country__c;
            
            ObjContract.OpportunityId__c=TempObjOpp.Id;
         
            insert ObjContract;
            system.debug('Rahul'+ObjContract);
            //Pricebook2 ObjPricebook2 = new  Pricebook2(name = 'abc02');
            
            //insert ObjPricebook2;  
            
            Contact ObjCon = new Contact( FirstName='ABC', LastName='XYZ');
            insert ObjCon;
            
            OpportunityContactRole ObjConRole = new OpportunityContactRole(OpportunityId=TempObjOpp.Id,ContactId=ObjCon.Id , IsPrimary=true );
            
            insert ObjConRole;
           
            product2 ObjProduct2 = new product2( Name='XYZ' , Family='Software' , LOB__c='SW',Description='SW',Product_Category__c='SEM',ProductCode='234');
            
            insert ObjProduct2;
            
            product2 ObjProduct2Ser = new product2( Name='XYZSer' , Family = 'Services' , LOB__C='Services',Description='Services',Product_Category__c='SEM',ProductCode='235');
            insert ObjProduct2Ser;
            
            //PricebookEntry ObjPricebookEntry01 = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct2Ser.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            //insert ObjPricebookEntry01;
            
            product2 ObjProduct2AL = new product2( Name='XYZAnn' , Family = 'Annual License' , LOB__c='AL',Description='AL',ProductCode='236',Product_Category__c='SEM');
            
            insert ObjProduct2AL;
            
            
            Ellu_Software_Billing__c ObjElluSoftBill= new  Ellu_Software_Billing__c();
            ObjElluSoftBill = new Ellu_Software_Billing__c(Name='Software',Item_Type__c='Software',Billing_Terms__c='On Execution',Percentage_OR_Amount__c='Payment Percentage',Payment_Timing__c = 'On Execution',Number_Of_Payment__c=1,Payment_Percentage__c=100);
            insert ObjElluSoftBill;
            
            Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluDefBillRecExceSoftware01= new Ellu_CustDefaultBillRecordsExcepSoftware__c();
            ObjElluDefBillRecExceSoftware01 = new  Ellu_CustDefaultBillRecordsExcepSoftware__c(Name='Annual License',Product_Family__c='Annual License',Item_Type__c='Annual License',Billing_Terms__c='Annual License',Percentage_OR_Amount__c='Payment Percentage',Payment_Timing__c = 'On Execution',Number_Of_Payment__c=1,Payment_Percentage__c=100);
            insert ObjElluDefBillRecExceSoftware01;
            
            Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluDefBillRecExceSoftware02= new Ellu_CustDefaultBillRecordsExcepSoftware__c();
            ObjElluDefBillRecExceSoftware02 = new  Ellu_CustDefaultBillRecordsExcepSoftware__c(Name='Fixed Services',Product_Family__c='Services',Item_Type__c='Fixed Fee',Billing_Terms__c='On Execution',Percentage_OR_Amount__c='Payment Percentage',Payment_Timing__c = 'Other',Number_Of_Payment__c=1,Payment_Percentage__c=100);
            insert ObjElluDefBillRecExceSoftware02;
            
            Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluDefBillRecExceSoftware03 = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
            ObjElluDefBillRecExceSoftware03 = new Ellu_CustDefaultBillRecordsExcepSoftware__c(Name='Other Services',Product_Family__c='Services',Item_Type__c='Others',Billing_Terms__c='As Incurred',Percentage_OR_Amount__c='Payment Percentage',Payment_Timing__c = 'On Execution',Number_Of_Payment__c=1,Payment_Percentage__c=100);
            insert ObjElluDefBillRecExceSoftware03;
            
            //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

            //PricebookEntry ObjPricebookEntry = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct2.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            //insert ObjPricebookEntry;

            //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

            //PricebookEntry ObjPricebookEntry = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct2.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            //insert ObjPricebookEntry;
         
          /*
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
            */
     
            List<ContractLine__c> LstObjConLine= new List<ContractLine__c>();
            
            ContractLine__c ObjContractLine = new ContractLine__c();
            
            ObjContractLine.ContractID__c=ObjContract.Id;
            ObjContractLine.Discount_Amount__c=10;
            ObjContractLine.Discount_Percent__c=10;
            ObjContractLine.LOB__c='Software Maintenance';
            
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
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine.UnitofMeasure__c='EACH';
            //ObjContractLine.OpportunityLineItemId__c=ObjOppLI.Id;
            ObjContractLine.Item_Type__c='Software';
            //insert ObjContractLine;
            LstObjConLine.add(ObjContractLine);
            
            ContractLine__c ObjContractLine05 = new ContractLine__c();
            
            ObjContractLine05.ContractID__c=ObjContract.Id;
            ObjContractLine05.Discount_Amount__c=10;
            ObjContractLine05.Discount_Percent__c=10;
            ObjContractLine05.LOB__c='Software Maintenance';
            
            ObjContractLine05.ProductId__c=ObjProduct2.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine05.Quantity__c=1;
            ObjContractLine05.TotalPrice__c=100;
            ObjContractLine05.Total_Retail_Price__c=100;
            ObjContractLine05.UnitPrice__c=1;
            ObjContractLine05.ItemPrice__c=1;
            ObjContractLine05.ServicesEndDate__c=date.today()+2;
            ObjContractLine05.ServicesStartDate__c=date.today();
            ObjContractLine05.AgreementItemStartDate__c=date.today();
            ObjContractLine05.AgreementItemEndDate__c=date.today()+2;
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine05.UnitofMeasure__c='EACH';
            //ObjContractLine.OpportunityLineItemId__c=ObjOppLI.Id;
            ObjContractLine05.Item_Type__c='Software';
            //insert ObjContractLine05;
            LstObjConLine.add(ObjContractLine05);
            /*
            Ellu_Software_Billing__c ObjElluSoftBill= new  Ellu_Software_Billing__c();
            ObjElluSoftBill = new Ellu_Software_Billing__c(Name='Software',Percentage_OR_Amount__c='Payment Percentage',Payment_Timing__c = 'On Execution',Number_Of_Payment__c=1,Payment_Percentage__c=100);
            insert ObjElluSoftBill;
            */
            
            

            /*
            OpportunityLineItem ObjOppLI01 = new OpportunityLineItem();
            ObjOppLI01.OpportunityID=TempObjOpp.Id;
            //ObjOppLI.Discount_Amount__c=20;
            ObjOppLI01.Discount_Percent__c=20;
            //ObjContractLine.LOB__c=TempObjOppLineItem.LOB__c;
            
            ObjOppLI01.PricebookEntryId=ObjPricebookEntry.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjOppLI01.Quantity=3;
            ObjOppLI01.TotalPrice=300;
            ObjOppLI01.Retail_Price__c=400;
            //ObjOppLI.UnitPrice=2;
            //ObjOppLI.ItemPrice__c=3;
            //ObjOppLI.ServicesEndDate__c=date.today()+2;
            //ObjOppLI.ServicesStartDate__c=date.today();
            //ObjOppLI.AgreementItemStartDate__c=date.today();
            //ObjOppLI.AgreementItemEndDate__c=date.today()+2;
            insert ObjOppLI01;*/

            ContractLine__c ObjContractLine01 = new ContractLine__c();
            
            ObjContractLine01.ContractID__c=ObjContract.Id;
            ObjContractLine01.Discount_Amount__c=10;
            ObjContractLine01.Discount_Percent__c=10;
            //ObjContractLine.LOB__c='Software Maintenance';
            
            ObjContractLine01.ProductId__c=ObjProduct2Ser.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine01.Quantity__c=1;
            ObjContractLine01.TotalPrice__c=100;
            ObjContractLine01.Total_Retail_Price__c=100;
            ObjContractLine01.UnitPrice__c=1;
            ObjContractLine01.ItemPrice__c=1;
            ObjContractLine01.ServicesEndDate__c=date.today()+2;
            ObjContractLine01.ServicesStartDate__c=date.today();
            ObjContractLine01.AgreementItemStartDate__c=date.today();
            ObjContractLine01.AgreementItemEndDate__c=date.today()+2;
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine01.UnitofMeasure__c='EACH';
            //ObjContractLine01.OpportunityLineItemId__c=ObjOppLI01.Id;
            ObjContractLine01.Item_Type__c='Fixed Fee';
            ObjContractLine01.BillingTerms__c='On Execution';

            //insert ObjContractLine01;
            LstObjConLine.add(ObjContractLine01);
            
             ContractLine__c ObjContractLine04 = new ContractLine__c();
            
            ObjContractLine04.ContractID__c=ObjContract.Id;
            ObjContractLine04.Discount_Amount__c=10;
            ObjContractLine04.Discount_Percent__c=10;
            //ObjContractLine.LOB__c='Software Maintenance';
            
            ObjContractLine04.ProductId__c=ObjProduct2Ser.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine04.Quantity__c=1;
            ObjContractLine04.TotalPrice__c=100;
            ObjContractLine04.Total_Retail_Price__c=100;
            ObjContractLine04.UnitPrice__c=1;
            ObjContractLine04.ItemPrice__c=1;
            ObjContractLine04.ServicesEndDate__c=date.today()+2;
            ObjContractLine04.ServicesStartDate__c=date.today();
            ObjContractLine04.AgreementItemStartDate__c=date.today();
            ObjContractLine04.AgreementItemEndDate__c=date.today()+2;
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine04.UnitofMeasure__c='EACH';
            //ObjContractLine01.OpportunityLineItemId__c=ObjOppLI01.Id;
            ObjContractLine04.Item_Type__c='Fixed Fee';
            ObjContractLine04.BillingTerms__c='On Execution';

            //insert ObjContractLine04;
            LstObjConLine.add(ObjContractLine04);
            //Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.SetVarLoopMethodSoftFam ();
            //update ObjContractLine01; 
            //insert ObjContractLine01;
            
            ContractLine__c ObjContractLine03 = new ContractLine__c();
            
            ObjContractLine03.ContractID__c=ObjContract.Id;
            ObjContractLine03.Discount_Amount__c=10;
            ObjContractLine03.Discount_Percent__c=10;
            //ObjContractLine.LOB__c='Software Maintenance';
            
            ObjContractLine03.ProductId__c=ObjProduct2Ser.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine03.Quantity__c=1;
            ObjContractLine03.TotalPrice__c=100;
            ObjContractLine03.Total_Retail_Price__c=100;
            ObjContractLine03.UnitPrice__c=1;
            ObjContractLine03.ItemPrice__c=1;
            ObjContractLine03.ServicesEndDate__c=date.today()+2;
            ObjContractLine03.ServicesStartDate__c=date.today();
            ObjContractLine03.AgreementItemStartDate__c=date.today();
            ObjContractLine03.AgreementItemEndDate__c=date.today()+2;
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine03.UnitofMeasure__c='EACH';
            //ObjContractLine01.OpportunityLineItemId__c=ObjOppLI01.Id;
            ObjContractLine03.Item_Type__c='Others';
            ObjContractLine03.BillingTerms__c='As Incurred';

            //insert ObjContractLine03;
            //insert ObjContractLine03;
            LstObjConLine.add(ObjContractLine03);
            
             ContractLine__c ObjContractLine02 = new ContractLine__c();
            
            ObjContractLine02.ContractID__c=ObjContract.Id;
            ObjContractLine02.Discount_Amount__c=10;
            ObjContractLine02.Discount_Percent__c=10;
            //ObjContractLine.LOB__c='Software Maintenance';
            
            ObjContractLine02.ProductId__c=ObjProduct2Ser.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine02.Quantity__c=1;
            ObjContractLine02.TotalPrice__c=100;
            ObjContractLine02.Total_Retail_Price__c=100;
            ObjContractLine02.UnitPrice__c=1;
            ObjContractLine02.ItemPrice__c=1;
            ObjContractLine02.ServicesEndDate__c=date.today()+2;
            ObjContractLine02.ServicesStartDate__c=date.today();
            ObjContractLine02.AgreementItemStartDate__c=date.today();
            ObjContractLine02.AgreementItemEndDate__c=date.today()+2;
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine02.UnitofMeasure__c='EACH';
            //ObjContractLine01.OpportunityLineItemId__c=ObjOppLI01.Id;
            ObjContractLine02.Item_Type__c='Others';
            ObjContractLine02.BillingTerms__c='As Incurred';

            //insert ObjContractLine02;
            LstObjConLine.add(ObjContractLine02);
            
            
            ContractLine__c ObjContractLine06 = new ContractLine__c();
            
            ObjContractLine06.ContractID__c=ObjContract.Id;
            ObjContractLine06.Discount_Amount__c=10;
            ObjContractLine06.Discount_Percent__c=10;
            //ObjContractLine.LOB__c='Software Maintenance';
            
            ObjContractLine06.ProductId__c=ObjProduct2AL.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine06.Quantity__c=1;
            ObjContractLine06.TotalPrice__c=100;
            ObjContractLine06.Total_Retail_Price__c=100;
            ObjContractLine06.UnitPrice__c=1;
            ObjContractLine06.ItemPrice__c=1;
            ObjContractLine06.ServicesEndDate__c=date.today()+2;
            ObjContractLine06.ServicesStartDate__c=date.today();
            ObjContractLine06.AgreementItemStartDate__c=date.today();
            ObjContractLine06.AgreementItemEndDate__c=date.today()+2;
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine06.UnitofMeasure__c='EACH';
            //ObjContractLine01.OpportunityLineItemId__c=ObjOppLI01.Id;
            ObjContractLine06.Item_Type__c='Annual License';
            ObjContractLine06.BillingTerms__c='Annual License';

            //insert ObjContractLine06;
           LstObjConLine.add(ObjContractLine06);
                        
                        
            Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.SetVarLoopMethodSoftFam ();
            
            
              ContractLine__c ObjContractLine07 = new ContractLine__c();
            
            ObjContractLine07.ContractID__c=ObjContract.Id;
            ObjContractLine07.Discount_Amount__c=10;
            ObjContractLine07.Discount_Percent__c=10;
            //ObjContractLine.LOB__c='Software Maintenance';
            
            ObjContractLine07.ProductId__c=ObjProduct2AL.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine07.Quantity__c=1;
            ObjContractLine07.TotalPrice__c=100;
            ObjContractLine07.Total_Retail_Price__c=100;
            ObjContractLine07.UnitPrice__c=1;
            ObjContractLine07.ItemPrice__c=1;
            ObjContractLine07.ServicesEndDate__c=date.today()+2;
            ObjContractLine07.ServicesStartDate__c=date.today();
            ObjContractLine07.AgreementItemStartDate__c=date.today();
            ObjContractLine07.AgreementItemEndDate__c=date.today()+2;
            
            //ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            ObjContractLine07.UnitofMeasure__c='EACH';
            //ObjContractLine01.OpportunityLineItemId__c=ObjOppLI01.Id;
            ObjContractLine07.Item_Type__c='Annual License';
            ObjContractLine07.BillingTerms__c='Annual License';
            ObjContractLine07.HasRevenueItemCreated__c=true;
            LstObjConLine.add(ObjContractLine07);
            
            //try {
            insert  LstObjConLine;
           // }
          /*  catch (exception e){
            
            }*/
            /*
            Contract_Billing__c ObjCon02= new Contract_Billing__c(ContractId__c=ObjContract.Id,Comments__c='XYZ',NumberofPayments__c=2,Percentage_OR_Amount__c='Payment Amount',
                                                                           Payment_Timing__c='On Delivery',Total_Amount__c=3456,Billing_Type__c='On Execution',BillingDate__c= ObjContract.StartDate,Payment_Amount__c=100 );
            
            insert ObjCon02; 
            */
            Contract_Revenue__c ObjConRev = new Contract_Revenue__c(StartDate__c = system.today() , ContractId__c=ObjContract.Id , ContractLine__c = ObjContractLine07.Id );
            insert ObjConRev;
            
            Contract TempObjContract = new Contract();
            TempObjContract =[SELECT Id , ContractExecutionDate__c FROM Contract WHERE Id=:ObjContract.Id];
            TempObjContract.ContractExecutionDate__c = date.today();
            TempObjContract.Status = 'Sent to SAP';
            Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.setVarLoopMethodSoftFam (); 
            
            
            /*
            try{
            update  TempObjContract;           
            }
            catch(exception e){
            }
            */
            system.debug('Printing Contract record01'+TempObjContract);
            
            Contract_Billing__c ObjCon03= new Contract_Billing__c(ContractId__c=TempObjContract.Id,Comments__c='XYZ',NumberofPayments__c=1,Percentage_OR_Amount__c='Payment Amount',
                                                                           Payment_Timing__c='On Delivery',Total_Amount__c=3456,Billing_Type__c='On Execution',BillingDate__c= ObjContract.StartDate,Payment_Amount__c=100 );
            
            insert ObjCon03; 
            
            Contract_Revenue__c ObjConRev01 = new Contract_Revenue__c(StartDate__c = system.today() , ContractId__c=ObjContract.Id , ContractLine__c = ObjContractLine07.Id );
            insert ObjConRev01;
            
            system.debug('XCD'+ ObjCon03 + 'DVD'+ [SELECT ContractId__r.Status FROM Contract_Billing__c WHERE Id =: ObjCon03.Id ].ContractId__r.Status);
            /*
            TempObjContract.ContractExecutionDate__c = date.today();
            TempObjContract.Status = 'Sent to SAP';
            Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.setVarLoopMethodSoftFam ();
            */
            Test.StartTest();
            try{
            
            
            update  TempObjContract;
                       
            }
            catch(exception e){
            //Ellu_SFDC_SAP_SVarInfLoopDurTest.setToTrue_Trigger3ContToCBillCRev ();
            }
            Test.StopTest();
            
            
            
            try{
            delete ObjConRev01;
            }
            catch(exception e ) {
            }
            
            try{
            delete ObjCon03;
            }
            catch(exception e ) {
            }
            
            try{
            delete TempObjContract;
            }
            catch(exception e ) {
            }
     }
}