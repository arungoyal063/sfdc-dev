@isTest (seeAllData=true)


public class Test_Ell_SFDC_SAP_CreateContractClass {
    
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
         TempObjOpp.Business_Unit__c = 'SG11 - Ellucian Company, L.P.';
         TempObjOpp.Company_Code__c = 'SG11';  
         TempObjOpp.Primary_Contact_2__c = con.Id;
   
 
         insert TempObjOpp;
         
         List<Product2> LstObjProduct = new  List<Product2>();
         List<OpportunityLineItem> LstOppLiItem = new List<OpportunityLineItem>();
         List<PricebookEntry> LstPrBookEntry =new List<PricebookEntry>();
          //PriceBookEntry TempPriceBook=new PriceBookEntry(Name='XYZprice');
          //insert TempPriceBook;
          
          //Product2 TempProduct=new Product2(Name='XYZ',PriceBookEntryId=TempPriceBook.Id);
          //insert TempProduct;
            product2 ObjProduct2 = new product2( Name='XYZ',Family='Software',LOB__c='SW');
            
            insert ObjProduct2;
            //LstObjProduct.add(ObjProduct2);
            
            product2 ObjProduct3 = new product2(Name='XY',Family='Services' ,LOB__c='Services' );
            
            insert ObjProduct3;
            //LstObjProduct.add(ObjProduct3);
             
            product2 ObjProduct4 = new product2(Name='XY',Family='Maintenance' ,LOB__c='ESSA Maintenance' );
            
            insert ObjProduct4;
            // LstObjProduct.add(ObjProduct4);
            
            insert LstObjProduct;
             
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

            PricebookEntry ObjPricebookEntry = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct2.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            insert ObjPricebookEntry;
            
            LstPrBookEntry.add(ObjPricebookEntry);
            
            PricebookEntry ObjPricebookEntry02 = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct3.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            insert ObjPricebookEntry02;
            
            
            PricebookEntry ObjPricebookEntry03 = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct4.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            insert ObjPricebookEntry03;
            
            Contact ObjCon = new Contact( FirstName='ABC', LastName='XYZ');
            insert ObjCon;
            
            OpportunityContactRole ObjConRole = new OpportunityContactRole(OpportunityId=TempObjOpp.Id,ContactId=ObjCon.Id , IsPrimary=true );
            
            insert ObjConRole;

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
            //insert ObjOppLI;
            LstOppLiItem.add(ObjOppLI);
            
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
            //insert ObjOppLI;
            LstOppLiItem.add(ObjOppLI01);

            OpportunityLineItem ObjOppLI02 = new OpportunityLineItem();
            ObjOppLI02.OpportunityID=TempObjOpp.Id;
            //ObjOppLI.Discount_Amount__c=20;
            ObjOppLI02.Discount_Percent__c=20;
            //ObjContractLine.LOB__c=TempObjOppLineItem.LOB__c;
            ObjOppLI02.Unit_Of_Measure__c='Fixed Fee';
            ObjOppLI02.PricebookEntryId=ObjPricebookEntry02.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjOppLI02.Quantity=3;
            ObjOppLI02.TotalPrice=300;
            ObjOppLI02.Retail_Price__c=400;
            //ObjOppLI.UnitPrice=2;
            //ObjOppLI.ItemPrice__c=3;
            //ObjOppLI.ServicesEndDate__c=date.today()+2;
            //ObjOppLI.ServicesStartDate__c=date.today();
            //ObjOppLI.AgreementItemStartDate__c=date.today();
            //ObjOppLI.AgreementItemEndDate__c=date.today()+2;
            //insert ObjOppLI02;
            LstOppLiItem.add(ObjOppLI02);
            
            OpportunityLineItem ObjOppLI04 = new OpportunityLineItem();
            ObjOppLI04.OpportunityID=TempObjOpp.Id;
            //ObjOppLI.Discount_Amount__c=20;
            ObjOppLI04.Discount_Percent__c=20;
            //ObjContractLine.LOB__c=TempObjOppLineItem.LOB__c;
            ObjOppLI04.Unit_Of_Measure__c='Fixed Fee';
            ObjOppLI04.PricebookEntryId=ObjPricebookEntry02.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjOppLI04.Quantity=3;
            ObjOppLI04.TotalPrice=300;
            ObjOppLI04.Retail_Price__c=400;
            //ObjOppLI.UnitPrice=2;
            //ObjOppLI.ItemPrice__c=3;
            //ObjOppLI.ServicesEndDate__c=date.today()+2;
            //ObjOppLI.ServicesStartDate__c=date.today();
            //ObjOppLI.AgreementItemStartDate__c=date.today();
            //ObjOppLI.AgreementItemEndDate__c=date.today()+2;
            //insert ObjOppLI02;
            LstOppLiItem.add(ObjOppLI04);
            
            OpportunityLineItem ObjOppLI03 = new OpportunityLineItem();
            ObjOppLI03.OpportunityID=TempObjOpp.Id;
            //ObjOppLI.Discount_Amount__c=20;
            ObjOppLI03.Discount_Percent__c=20;
            //ObjContractLine.LOB__c=TempObjOppLineItem.LOB__c;
            
            ObjOppLI03.PricebookEntryId=ObjPricebookEntry03.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjOppLI02.Unit_Of_Measure__c='Others';
            ObjOppLI03.Quantity=3;
            ObjOppLI03.TotalPrice=300;
            ObjOppLI03.Retail_Price__c=400;
            //ObjOppLI.UnitPrice=2;
            //ObjOppLI.ItemPrice__c=3;
            //ObjOppLI.ServicesEndDate__c=date.today()+2;
            //ObjOppLI.ServicesStartDate__c=date.today();
            //ObjOppLI.AgreementItemStartDate__c=date.today();
            //ObjOppLI.AgreementItemEndDate__c=date.today()+2;
            //insert ObjOppLI03;
            LstOppLiItem.add(ObjOppLI03);
            
            OpportunityLineItem ObjOppLI05 = new OpportunityLineItem();
            ObjOppLI05.OpportunityID=TempObjOpp.Id;
            //ObjOppLI.Discount_Amount__c=20;
            ObjOppLI05.Discount_Percent__c=20;
            //ObjContractLine.LOB__c=TempObjOppLineItem.LOB__c;
            
            ObjOppLI05.PricebookEntryId=ObjPricebookEntry02.Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjOppLI05.Unit_Of_Measure__c='Others';
            ObjOppLI05.Quantity=3;
            ObjOppLI05.TotalPrice=300;
            ObjOppLI05.Retail_Price__c=400;
            //ObjOppLI.UnitPrice=2;
            //ObjOppLI.ItemPrice__c=3;
            //ObjOppLI.ServicesEndDate__c=date.today()+2;
            //ObjOppLI.ServicesStartDate__c=date.today();
            //ObjOppLI.AgreementItemStartDate__c=date.today();
            //ObjOppLI.AgreementItemEndDate__c=date.today()+2;
            //insert ObjOppLI03;
            LstOppLiItem.add(ObjOppLI05);
            
            insert LstOppLiItem;
          //OpportunityLineItem TemObjOppLineItem=new  OpportunityLineItem();
          //TemObjOppLineItem.PriceBookEntry.Product2Id=TempProduct.Id;
                   
          ApexPages.currentPage().getParameters().put('Id',TempObjOpp.Id);
          ApexPages.StandardController stc = new ApexPages.StandardController(TempObjOpp);
          Ellu_SFDC_SAP_Create_Contract_Class TempObjCrContractClass= new Ellu_SFDC_SAP_Create_Contract_Class(stc);
          
          Test.StartTest();
          
          TempObjCrContractClass.CreateContract();
          TempObjCrContractClass.Cancel ();
          TempObjCrContractClass.CreateContract();
          
          Test.StopTest();
          //TempObjCrContractClass.CreateContract();
         
     }
        
}