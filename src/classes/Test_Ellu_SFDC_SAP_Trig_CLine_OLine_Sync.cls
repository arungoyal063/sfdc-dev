@isTest(seeAllData=true)
public class Test_Ellu_SFDC_SAP_Trig_CLine_OLine_Sync {


    static testMethod void myUnitTest() {
         //For testing the change to Ellu_SFDC_SAP_Int_Trigger_OppLineItem_to_ContractLineSync

         User ctrAdmin=[SELECT Id FROM user WHERE Id='005G0000001y0tpIAA'];  

    User TempObjUser=[SELECT Id,FirstName,LastName, EmployeeNumber FROM User WHERE Id=:UserInfo.getUserId() ];
                    
         //User TempObjUser=[SELECT Id,FirstName,LastName, EmployeeNumber FROM User WHERE Id=:UserInfo.getUserId() ];
         
         Address__c ObjAdd= new Address__c();
         ObjAdd.City__c='Malvern';
         //ObjAdd.AccountId__c=TempObjAccount.Id
         ObjAdd.Country__c='United States';
         ObjAdd.Postal_Code__c='12345';
         ObjAdd.State__c='Pennsylvania';
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
            system.runas(ctrAdmin){  //
            test.StartTest();
         
         Opportunity TempObjOpp=new Opportunity();
         TempObjOpp.Primary_Contact_2__c = con.Id;
         TempObjOpp.accountid = TempObjAccount.id;        
         TempObjOpp.name = 'partner test';        
         //TempObjOpp.amount = 100;        
         TempObjOpp.closedate = Date.today();        
         //TempObjOpp.recordtypeid = '012G0000000yBnDIAU';        
         TempObjOpp.stagename = 'Proposal';        
         TempObjOpp.LeadSource = 'Contract Vehicle';        
         TempObjOpp.Has_Primary_Contact__c = TRUE;        
         TempObjOpp.Type = 'CBR';        
         TempObjOpp.Category__c = 'Strategic Solutions';        
         TempObjOpp.Summary__c ='Recruiter';        
         TempObjOpp.Competitors__c='WorkDay';
         insert TempObjOpp;
         
         
         Contract ObjContract = new Contract();
            ObjContract.AccountID=TempObjOpp.AccountID;
            ObjContract.CompanyCode__c='SG51';
            ObjContract.Status='Draft';
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
            
            insert ObjContract;
            
            Pricebook2 ObjPricebook2 = new  Pricebook2(name = 'abc02');
            
            insert ObjPricebook2;  
            
            Contact ObjCon = new Contact( FirstName='ABC', LastName='XYZ');
            insert ObjCon;
            
            OpportunityContactRole ObjConRole = new OpportunityContactRole(OpportunityId=TempObjOpp.Id,ContactId=ObjCon.Id , IsPrimary=true );
            
            insert ObjConRole;
           
            product2 ObjProduct2 = new product2( Name='XYZ' , LOB__c='AL');
            
            insert ObjProduct2;
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

            PricebookEntry ObjPricebookEntry = new PricebookEntry(Pricebook2Id=standardPB.Id,Product2Id=ObjProduct2.Id , UnitPrice=3 ,UseStandardPrice = false,IsActive=true);
             
            insert ObjPricebookEntry;
            
            OpportunityLineItem ObjOppLI = new OpportunityLineItem();
            ObjOppLI.OpportunityID=TempObjOpp.Id;
            ObjOppLI.Discount_Percent__c=20;
            
            ObjOppLI.PricebookEntryId=ObjPricebookEntry.Id;
            ObjOppLI.Quantity=3;
            ObjOppLI.TotalPrice=300;
            ObjOppLI.Retail_Price__c=400;
            insert ObjOppLI;

            ContractLine__c ObjContractLine = new ContractLine__c();
            
            ObjContractLine.ContractID__c=ObjContract.Id;
            ObjContractLine.Discount_Amount__c=10;
            ObjContractLine.Discount_Percent__c=10;
            ObjContractLine.LOB__c='AL';
            
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
            ObjContractLine.OpportunityLineItemId__c=ObjOppLI.Id;
            
            insert ObjContractLine;
            //Ellu_SFDC_SAP_PreventInfiniteTrigLoop.setBoolVarPreventtrggFirLoopMethod(); 
            Ellu_SFDC_SAP_PreventInfiniteTrigLoop.setVarLoopMethod () ;
            //Ellu_SFDC_SAP_PreventInfiniteTrigLoop.getBoolVarPreventtrggFirLoopMethod() ;            
            update ObjContractLine;
            
            Ellu_SFDC_SAP_PreventInfiniteTrigLoop.setVarLoopMethod () ;
            update ObjOppLI;
            
            //Ellu_SFDC_SAP_PreventInfiniteTrigLoop.setVarLoopMethod () ;
            //delete ObjOppLI;
            
            Test.StopTest();
            }
           }
        
}