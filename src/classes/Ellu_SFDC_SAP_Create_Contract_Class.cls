//CHG34157 AMC 05/02/2012 Populate the business unit and the company code from the opportunity.
//CHG00032631 VJK 04/10/2013 Do not insert contract line item when the Opportunity Line Item's LOB is Third Party Margin Credit
//SalesCloud  AIM 05/3/2013 Replaced Discount Percentage from Opportunity.  Now using: Discount_Reports__c instead of Discount_Percent__c
//CHG00034524 AMC 05/17.2013 Populate the shipping person on the contract with the primary contact instead of the primary contact role.
public class Ellu_SFDC_SAP_Create_Contract_Class {
    
    Public ID OppId;
    Opportunity ObjOpp=new Opportunity();
    Contract ObjContract=new Contract();
    public class applicationException extends Exception {}
    List<OpportunityLineItem> LstObjOppLineItem=new List<OpportunityLineItem> ();
    
    List<ContractLine__c> LstObjContractLine=new List<ContractLine__c>();
    //ContractLine__c ObjContractLine=new ContractLine__c();
    Map<Id,OpportunityLineItem> MapContLineItemOppLineItem=new Map<Id,OpportunityLineItem>();
    
    Public Boolean VarBoolError=false;
    
    User ObjUser=new User();
    RecordType ObjRecordTypeLicense;
    RecordType ObjRecordTypeService;
    RecordType ObjRecordTypeMaintenace;
    RecordType ObjRecordTypeAnnLicense;
    String StrBillingStreet;
    String StrBillingStreetPart1;
    String StrBillingStreetPart2;
    Integer StrBillingStreetSize;
    
    String StrShippingStreet;
    String StrShippingStreetPart1;
    String StrShippingStreetPart2;
    Integer StrShippingStreetSize;
    List<Contract> LstObjCon = new List<Contract>();
    public Ellu_SFDC_SAP_Create_Contract_Class(ApexPages.StandardController controller) {
    
     //  try{
        
            OppId = ApexPages.currentPage().getParameters().get('Id');
            ObjOpp= [SELECT Id ,AccountID,OwnerID,Account.BillingStreet,/*Account.BillToStreetAddress2__c*/ 
                     Business_Unit__c,/*Company_Code__c*/
                     Account.BillingCity ,Account.BillingPostalCode,Account.BillingState,Account.BillingCountry
                     ,Account.City__c ,Account.ZipCode__c,Account.State__c,Account.Country__c,Account.Street__c
                     ,CloseDate,Has_Primary_Contact__c,Account.Billing_Address_Name__c/*,Account.Billing_Address_Name__r.ContactId__r.LastName
                     ,Account.Billing_Address_Name__r.ContactId__r.FirstName*/,Account.Billing_Address_Name__r.City__c
                     ,Account.Billing_Address_Name__r.Country__c,Account.Billing_Address_Name__r.Postal_Code__c
                     ,Account.Billing_Address_Name__r.State__c,Account.Billing_Address_Name__r.Street_Address1__c,Account.Billing_Address_Name__r.Billing_Contact__c
                     ,Account.Billing_Address_Name__r.Street_Address2__c, Primary_Contact_2__c FROM Opportunity WHERE ID =: OppId ];
            
               
            
            ObjUser = [SELECT Id , FirstName,LastName FROM User WHERE Id=:ObjOpp.OwnerID];
            
            
            //StrBillingStreet=ObjOpp.Account.BillingStreet;
            
            /*Field Population for Contract Record*/
            
            ObjContract.AccountID=ObjOpp.AccountID;
            ObjContract.BillToId__c=ObjOpp.Account.Billing_Address_Name__c;
            //ObjContract.ShipToId__c=ObjOpp.AccountID;
            //ObjContract.CompanyCode__c='SG51';
            ObjContract.Business_Unit__c=ObjOpp.Business_Unit__c;
            if (ObjOpp.Business_Unit__c != null)
                ObjContract.CompanyCode__c=ObjOpp.Business_Unit__c.substring(0,4);
            //else
                //throw new exception('Business Unit missing')
            ObjContract.Status='Draft';
            //ObjContract.CurrencyIsoCode='USD';
            ObjContract.StartDate=ObjOpp.CloseDate;
            ObjContract.ContractTerm=12;
            /*
            ObjContract.BillToFirstName__c=ObjUser.FirstName;
            ObjContract.BillToLastName__c=ObjUser.LastName;
            ObjContract.BillToStreetAddress1__c=ObjOpp.Account.BillingStreet;
            ObjContract.BillToStreetAddress2__c=ObjOpp.Account.BillToStreetAddress2__c;
            ObjContract.BillToCity__c=ObjOpp.Account.BillToCity__c;
            ObjContract.BillToPostalcode__c=ObjOpp.Account.BillToPostalcode__c;
            ObjContract.BillToState__c=ObjOpp.Account.BillToState__c;
            ObjContract.BillToCountry__c=ObjOpp.Account.BillToCountry__c;
            */
            ObjContract.BillToFirstName__c=ObjOpp.Account.Billing_Address_Name__r.Billing_Contact__c;
            //ObjContract.BillToLastName__c=ObjOpp.Account.Billing_Address_Name__r.ContactId__r.LastName;
            ObjContract.BillToStreetAddress1__c=ObjOpp.Account.Billing_Address_Name__r.Street_Address1__c;
            ObjContract.BillToStreetAddress2__c=ObjOpp.Account.Billing_Address_Name__r.Street_Address2__c;
            ObjContract.BillToCity__c=ObjOpp.Account.Billing_Address_Name__r.City__c;
            ObjContract.BillToPostalcode__c=ObjOpp.Account.Billing_Address_Name__r.Postal_Code__c;
            ObjContract.BillToState__c=ObjOpp.Account.Billing_Address_Name__r.State__c;
            ObjContract.BillToCountry__c=ObjOpp.Account.Billing_Address_Name__r.Country__c;
            
            
            ObjContract.OpportunityId__c=OppId;
            ObjContract.ContractExecutionDate__c=ObjContract.StartDate;
            
            
            ObjContract.ShipToStreetAddress1__c=ObjOpp.Account.BillingStreet;
            //ObjContract.ShipToStreetAddress2__c=ObjOpp.Account.BillToStreetAddress2__c;
            ObjContract.ShipToCity__c=ObjOpp.Account.BillingCity;
            ObjContract.ShipToPostalcode__c=ObjOpp.Account.BillingPostalcode;
            ObjContract.ShipToState__c=ObjOpp.Account.BillingState;
            ObjContract.ShipToCountry__c=ObjOpp.Account.BillingCountry;
            
            /*       
            ObjContract.ShipToStreetAddress1__c=ObjOpp.Account.Street__c;
            //ObjContract.ShipToStreetAddress2__c=ObjOpp.Account.BillToStreetAddress2__c;
            ObjContract.ShipToCity__c=ObjOpp.Account.City__c;
            ObjContract.ShipToPostalcode__c=ObjOpp.Account.ZipCode__c;
            ObjContract.ShipToState__c=ObjOpp.Account.State__c;
            ObjContract.ShipToCountry__c=ObjOpp.Account.Country__c;
            */     
/*             
            if(ObjOpp.Has_Primary_Contact__c==true){
                try{
                    OpportunityContactRole TempOppContRole = [SELECT Id,ContactId FROM OpportunityContactRole WHERE OpportunityId=:ObjOpp.Id AND  IsPrimary=true];
                    Contact TempObjContact=[SELECT Id,MailingStreet,MailingCity,MailingPostalCode,MailingCountry,MailingState ,FirstName,LastName FROM Contact WHERE Id=:TempOppContRole.ContactId ];
                    
                    //ObjContract.ShipToId__c=ObjOpp.AccountID;
                    ObjContract.ShipToId__c=TempObjContact.Id;
                    ObjContract.ShipToFirstName__c=TempObjContact.FirstName;
                    ObjContract.ShipToLastName__c=TempObjContact.LastName;

    
                
               }
               
                Catch( Exception e){
                    //VarBoolError=true;
                    ApexPages.addMessages(e);
                  
                    
                } 
            } 
*/          
    Contact TempObjContact=[SELECT Id,MailingStreet,MailingCity,MailingPostalCode,MailingCountry,MailingState ,FirstName,LastName FROM Contact WHERE Id=:ObjOpp.Primary_Contact_2__c ];
                    
                    //ObjContract.ShipToId__c=ObjOpp.AccountID;
                    ObjContract.ShipToId__c=ObjOpp.Primary_Contact_2__c;
                    ObjContract.ShipToFirstName__c=TempObjContact.FirstName;
                    ObjContract.ShipToLastName__c=TempObjContact.LastName;
    
    //CreateContract();
      /*  }
        Catch(exception e){
        
            ApexPages.addMessages(e);
        
        } 
    */
    }
    
    public pageReference Cancel (){
    
       PageReference DetailedPage = new PageReference('/'+OppId);   
       return DetailedPage ; 
    }
    
    Public PageReference CreateContract(){
        //Opportunity ObjOpp= [SELECT Id ,AccountID FROM Opportunity WHERE ID =: OppId ];
        //Contract ObjContract = new Contract(AccountID=ObjOpp.AccountID,Status='Draft',CurrencyIsoCode='USD',StartDate=Date.Today(),ContractTerm=12);
        if(!Ellu_SFDC_SAP_PrTrigLoopCreateContCls.getBoolVarPrTrigLoopForCreateContract ()){
        Ellu_SFDC_SAP_PrTrigLoopCreateContCls.setBoolVarPrTrigLoopForCreateContract ();
        }
        try{
            try{
                LstObjCon = [SELECT Id , Send_to_SAP__c FROM Contract WHERE OpportunityId__c =:OppId];
            
            }
            catch(exception e){
            }
            
        if(LstObjCon.isEmpty()==false){
            for(Contract Temp1ObjCon : LstObjCon ){
                if(Temp1ObjCon.Send_to_SAP__c==true){
                    throw new applicationException('The existing Contract record cannot be overrided because it is already sent to SAP');    
                }
            }
        }
        


        try{
            delete LstObjCon;
        }
        catch(exception e){
        }
        
        insert ObjContract;

        Contract TempObjContract=[SELECT Id,EndDate,Ship_Date__c,Shipping_Comments__c,/*Shipping_IDoc_Reference__c
                                  ,*/Account.Payment_Terms__c FROM Contract WHERE Id=:ObjContract.Id];

        LstObjOppLineItem = [SELECT Id,Discount_Amount__c,LOB__c,Discount_Reports__c,Total_Cost__c,Total_Retail_Price__c,
                             Description,PricebookEntry.Product2Id,Product_Family__c,Quantity,UnitPrice 
                            ,Unit_Of_Measure__c,Retail_Price__c , TotalPrice , Services_Planned_Start_Date__c, Services_Planned_End_Date__c FROM OpportunityLineItem WHERE OpportunityId =:OppId]; 





        ObjRecordTypeLicense=[SELECT Id , Name FROM RecordType WHERE Name='LicenseFee-Product'];        
        ObjRecordTypeService=[SELECT Id , Name FROM RecordType WHERE Name='Services-Product'];        
        ObjRecordTypeMaintenace=[SELECT Id , Name FROM RecordType WHERE Name='Maintenance-Product'];
        ObjRecordTypeAnnLicense=[SELECT Id , Name FROM RecordType WHERE Name='Annual License-Product'];

        /*Field Population for Contract Line Item */
        for(OpportunityLineItem TempObjOppLineItem : LstObjOppLineItem){
            
            ContractLine__c ObjContractLine=new ContractLine__c();
            
            //ObjContractLine.Name=TempObjOppLineItem
            
            //ObjContractLine.CompanyCode__c=
            ObjContractLine.ContractID__c=ObjContract.Id;
            ObjContractLine.Discount_Amount__c=TempObjOppLineItem.Discount_Amount__c;
            if (TempObjOppLineItem.Discount_Reports__c !=null)
                ObjContractLine.Discount_Percent__c=TempObjOppLineItem.Discount_Reports__c;
            ObjContractLine.LOB__c=TempObjOppLineItem.LOB__c;
            
            ObjContractLine.ProductId__c=TempObjOppLineItem.PricebookEntry.Product2Id;
            // Decimal TemQuantity;
            //TemQuantity=OpportunityLineItem.Quantity;
            ObjContractLine.Quantity__c=TempObjOppLineItem.Quantity;
            ObjContractLine.TotalPrice__c=TempObjOppLineItem.TotalPrice;
            ObjContractLine.Total_Retail_Price__c=TempObjOppLineItem.Total_Retail_Price__c;
            ObjContractLine.UnitPrice__c=TempObjOppLineItem.UnitPrice;
            ObjContractLine.ItemPrice__c=TempObjOppLineItem.Retail_Price__c;
            //ObjContractLine.ServicesEndDate__c=TempObjContract.EndDate;
            //ObjContractLine.ServicesStartDate__c=ObjContract.StartDate;
            ObjContractLine.ServicesEndDate__c=TempObjOppLineItem.Services_Planned_End_Date__c;
            ObjContractLine.ServicesStartDate__c=TempObjOppLineItem.Services_Planned_Start_Date__c;
            
            ObjContractLine.AgreementItemStartDate__c=ObjContract.StartDate;
            ObjContractLine.AgreementItemEndDate__c=TempObjContract.EndDate;
            ObjContractLine.Invoice_Timing__c='Payment Date';
            ObjContractLine.Product_Family__c=TempObjOppLineItem.Product_Family__c;
            //ObjContractLine.UnitofMeasure__c=TempObjOppLineItem.PricebookEntry.Product2.UnitofMeasure__c;
            ObjContractLine.PaymentTerms__c=TempObjContract.Account.Payment_Terms__c;
            //ObjContractLine.Shipping_Comments__c=ObjContract.Shipping_Comments__c;
            //ObjContractLine.Shipping_IDOC_Reference__c=ObjContract.Shipping_IDoc_Reference__c;
            ObjContractLine.Line_Description__c=TempObjOppLineItem.Description;
            if(TempObjOppLineItem.Product_Family__c=='Software'){
            
                ObjContractLine.RecordTypeId=ObjRecordTypeLicense.Id;       
            }
            if(TempObjOppLineItem.Product_Family__c=='Services'){
            
                //ObjContractLine.Ship_Date__c=TempObjContract.EndDate;
            
                ObjContractLine.RecordTypeId=ObjRecordTypeService.Id; 
                //ObjContractLine.Item_Type__c=TempObjOppLineItem.PricebookEntry.Product2.Item_Type__c;   
                ObjContractLine.Item_Type__c=TempObjOppLineItem.Unit_Of_Measure__c;
                   
            }
            if(TempObjOppLineItem.Product_Family__c=='Maintenance'){
            
                ObjContractLine.RecordTypeId=ObjRecordTypeMaintenace.Id; 
            
            }
            if(TempObjOppLineItem.Product_Family__c=='Annual License'){
            
                ObjContractLine.RecordTypeId=ObjRecordTypeAnnLicense.Id;
                 
            
            }
            /*This section for populating the Record type is requested by Renee . 
            if LOB contains 'AL' then Recordtype is change to Annual license*/
            
            String Str1 =TempObjOppLineItem.LOB__c ;
            
            if(Str1.containsIgnoreCase('AL')){
            
                ObjContractLine.RecordTypeId=ObjRecordTypeAnnLicense.Id; 
                ObjContractLine.Product_Family__c='Annual License';
            
            }
            //Linking a Opportunity line item with the Contract Line Item for Sync
            
            ObjContractLine.OpportunityLineItemId__c=TempObjOppLineItem.Id;
            if(TempObjOppLineItem.LOB__c<>'Third Party Margin C')//CHG00032631 if the LOB is not third party margin then insert the contract line item
            {
            LstObjContractLine.add(ObjContractLine);
            }
            //TempObjOppLineItem.ContractLineID__c= 
            //TempObjOppLineItem 
        
        }
        Insert LstObjContractLine; 
        //For(ContractLine__c ObjContLine : LstObjContractLine){
        
        
        Map<Id,Contract> MapIdContract=new Map<Id,Contract>();
        
        
        //List<Contract_Billing__c> LstObjConBilling = new List<Contract_Billing__c>();
        List<Contract_Billing__c> LstObjConBill= new  List<Contract_Billing__c>();
        List<Contract_Billing__c> LstObjConBill02= new  List<Contract_Billing__c>();
         List<Contract_Billing__c> LstObjConBill03= new  List<Contract_Billing__c>();
        
        
        boolean VarCheckSoftBill = false;
        boolean VarCheckFixSerBill = false;
        boolean VarCheckOthSerBill = false;
        boolean VarCheckAnnLicBill = false;
        
        Date TempSignedDate=null;
        Decimal DecTotalAmount = 0; 
        

        Map<ID,Decimal> MpSoftCon = new Map<ID,Decimal>();
        Map<ID,Decimal> MpFixedSerCon = new Map<ID,Decimal>();
        Map<ID,Decimal> MpOtherSerCon = new Map<ID,Decimal>();




        for(ContractLine__c TempObjContractLine : [SELECT Id,ContractID__c,Product_Family__c,BillingTerms__c,HasRevenueItemCreated__c,
                                                   ContractID__r.ContractExecutionDate__c,ContractID__r.IsSoftwareBillRecCreated__c,ContractID__r.IsFixedServBillRecCreated__c
                                                  ,ContractID__r.IsAnnLicBillRecCreated__c,Item_Type__c,ContractID__r.IsOtherServBillRecCreated__c
                                                  ,ContractID__r.CompanyCode__c,TotalPrice__c FROM ContractLine__c WHERE ContractID__c =: ObjContract.Id]){
            try{
                if(TempObjContractLine.Product_Family__c=='Software' && TempObjContractLine.Item_Type__c == 'Software' && TempObjContractLine.BillingTerms__c=='On Execution'  ){
                
                
                    //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                    //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                    if(MpSoftCon.get(TempObjContractLine.ContractID__c)<> null){
                        DecTotalAmount=TempObjContractLine.TotalPrice__c+MpSoftCon.get(TempObjContractLine.ContractID__c); 
                        MpSoftCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                        DecTotalAmount=0;                                       
                    }                    
                    else{
                        MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                    }
                    if (TempObjContractLine.LOB__c<>'Third Party Margin C')//CHG00032631
                    {//CHG00032631
                    VarCheckSoftBill=true;
                    } //CHG00032631
                }
            }
            catch(exception e){
            
                ObjContract.adderror(e);     
            }
        
            try{
                if(TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Fixed Fee' && TempObjContractLine.BillingTerms__c=='On Execution'){
                    //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                    //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                    if(MpFixedSerCon.get(TempObjContractLine.ContractID__c)<> null){
                    DecTotalAmount=TempObjContractLine.TotalPrice__c+MpFixedSerCon.get(TempObjContractLine.ContractID__c); 
                    MpFixedSerCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                    DecTotalAmount=0;                                       
                }                    
                else{
                    MpFixedSerCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                }
                VarCheckFixSerBill=true; 
                }
            }
            catch(exception e){
            
                ObjContract.adderror(e);     
            }
            
            try{
                if(TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Others' && TempObjContractLine.BillingTerms__c=='As Incurred'){
                    //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                    //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                    if(MpOtherSerCon.get(TempObjContractLine.ContractID__c)<> null){
                    DecTotalAmount=TempObjContractLine.TotalPrice__c+MpOtherSerCon.get(TempObjContractLine.ContractID__c); 
                    MpOtherSerCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                    DecTotalAmount=0;                                       
                }                    
                else{
                    MpOtherSerCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                }
                VarCheckOthSerBill=true; 
                }
            }
            catch(exception e){
            
                ObjContract.adderror(e);     
            }
        }
        Ellu_Software_Billing__c ObjElluSoftBill = new Ellu_Software_Billing__c();
        //ObjElluSoftBill=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c FROM Ellu_Software_Billing__c WHERE NAME='Software' Limit 1 ];
        
        Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluFixedDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
        Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluOtherDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
        
        ObjElluSoftBill=Ellu_Software_Billing__c.getvalues('Software');
        ObjElluFixedDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Fixed Services');
        ObjElluOtherDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Other Services');




        If( MpSoftCon.get(ObjContract.Id) <> null){
        
            //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
            Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluSoftBill.Name 
               ,Total_Amount__c=MpSoftCon.get(ObjContract.Id), Item_Type__c=ObjElluSoftBill.Name
               ,Payment_Timing__c=ObjElluSoftBill.Payment_Timing__c,PaymentPercentage__c=ObjElluSoftBill.Payment_Percentage__c
               ,NumberofPayments__c=ObjElluSoftBill.Number_Of_Payment__c,Payment_Amount__c=MpSoftCon.get(ObjContract.Id)
               ,Percentage_OR_Amount__c=ObjElluSoftBill.Percentage_OR_Amount__c,BillingDate__c=ObjContract.StartDate
               ,Billing_Terms__c=ObjElluSoftBill.Billing_Terms__c);
            
            LstObjConBill.add(ObjConBilling);
            // ObjContract.IsSoftwareBillRecCreated__c = true;
        }
        If(MpFixedSerCon.get(ObjContract.Id) <> null){
        
            //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
            Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluFixedDefBillRec.Product_Family__c
               ,Total_Amount__c=MpFixedSerCon.get(ObjContract.Id), Item_Type__c=ObjElluFixedDefBillRec.Item_Type__c
               ,Payment_Timing__c=ObjElluFixedDefBillRec.Payment_Timing__c,PaymentPercentage__c=ObjElluFixedDefBillRec.Payment_Percentage__c
               ,NumberofPayments__c=ObjElluFixedDefBillRec.Number_Of_Payment__c,Payment_Amount__c=MpFixedSerCon.get(ObjContract.Id)
               ,Percentage_OR_Amount__c=ObjElluFixedDefBillRec.Percentage_OR_Amount__c,BillingDate__c=ObjContract.StartDate
               ,Billing_Terms__c=ObjElluFixedDefBillRec.Billing_Terms__c);
            
            LstObjConBill02.add(ObjConBilling);
            // ObjContract.IsSoftwareBillRecCreated__c = true;
        }

        If(MpOtherSerCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluOtherDefBillRec.Product_Family__c
                                                                           ,Total_Amount__c=MpOtherSerCon.get(ObjContract.Id), Item_Type__c=ObjElluOtherDefBillRec.Item_Type__c
                                                                           ,Payment_Timing__c=ObjElluOtherDefBillRec.Payment_Timing__c,PaymentPercentage__c=ObjElluOtherDefBillRec.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluOtherDefBillRec.Number_Of_Payment__c,Payment_Amount__c=MpOtherSerCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluOtherDefBillRec.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluOtherDefBillRec.Billing_Terms__c);
        
                LstObjConBill03.add(ObjConBilling);
               // ObjContract.IsSoftwareBillRecCreated__c = true;
        }


        if(VarCheckSoftBill=true){
            system.debug('Last insertion' + LstObjConBill);
            ObjContract.IsSoftwareBillRecCreated__c = true;
            insert LstObjConBill;
        } 
        if(VarCheckFixSerBill=true){
            system.debug('Last insertion' + LstObjConBill02);
            ObjContract.IsFixedServBillRecCreated__c = true;
            insert LstObjConBill02;
        }
        if(VarCheckOthSerBill=true){
            system.debug('Last insertion' + LstObjConBill02);
            ObjContract.IsOtherServBillRecCreated__c = true;
            insert LstObjConBill03;
        }
        if(VarCheckSoftBill==true || VarCheckFixSerBill==true || VarCheckOthSerBill==true ){   
        
            update  ObjContract;
        }   



        //Map<Id,Contract> MapIdContract=new Map<Id,Contract>();
        List<Contract_Revenue__c> LstObjContractRevenue = new List<Contract_Revenue__c>(); 
        boolean VarCheckRevenueCreated=false;   
        List<ContractLine__c> LstContractLine=new List<ContractLine__c>();
        
        //for(Contract TempObjContract02 : ObjContract){
        
        MapIdContract.Put(ObjContract.Id,ObjContract);
        
        //List<RecordType> LstObjRecType =new <RecordType>();
        Map<String,RecordType> MpRecType=new Map<String,RecordType>();
        
        for(RecordType TempObjRecType : [SELECT Id , Name FROM RecordType]){
            
            MpRecType.put(TempObjRecType.Name,TempObjRecType);    
        }
                
        //ObjRecordTypeService=[SELECT Id , Name FROM RecordType WHERE Name='Services-Product']; 
        // }
        
        for(ContractLine__c TempObjContractLine01 : [SELECT Id,ContractID__c,Product_Family__c,BillingTerms__c,HasRevenueItemCreated__c,
                                                     ContractID__r.StartDate,ContractID__r.IsSoftwareBillRecCreated__c,ContractID__r.CompanyCode__c,TotalPrice__c FROM ContractLine__c WHERE ContractID__c =:ObjContract.Id]){
            try{

                LstContractLine.add(TempObjContractLine01);
                   
                
                if(TempObjContractLine01.Product_Family__c=='Maintenance' || TempObjContractLine01.Product_Family__c=='Annual License' ){
                Contract_Revenue__c ObjContRevenue = new Contract_Revenue__c();
                
                
                if(TempObjContractLine01.Product_Family__c=='Maintenance'){
                    
                    ObjContRevenue.RecordTypeId=MpRecType.get('Maintenance').Id;        
                } 
                if(TempObjContractLine01.Product_Family__c=='Annual License'){
                    
                    ObjContRevenue.RecordTypeId=MpRecType.get('Annual License').Id;    
                } 
                ObjContRevenue.ContractLine__c=TempObjContractLine01.Id;
                //try{
                ObjContRevenue.Startdate__c=TempObjContractLine01.ContractID__r.StartDate;
                //}
                //catch(System.NullPointerException e){
                
                //    TempObjContractLine.adderror(e);
                //}
                ObjContRevenue.ContractId__c=TempObjContractLine01.ContractID__c;
                //ObjContRevenue.RevenueEndDate__c=
                ObjContRevenue.Description__c=TempObjContractLine01.Product_Family__c;
                ObjContRevenue.Billing_Term__c=TempObjContractLine01.BillingTerms__c;
                ObjContRevenue.RevenueType__c=TempObjContractLine01.Product_Family__c;
                ObjContRevenue.CompanyCode__c=TempObjContractLine01.ContractID__r.CompanyCode__c;
                //ObjContRevenue.RevenueAmount__c=TempObjContractLine.TotalPrice__c;
                TempObjContractLine01.HasRevenueItemCreated__c=true;
                
                VarCheckRevenueCreated=true;
                
                LstObjContractRevenue.add(ObjContRevenue);
                //}
            }
            
            /*
               if(TempObjContractLine01.Product_Family__c=='Annual License'){
                Contract_Revenue__c ObjContRevenue = new Contract_Revenue__c();
                ObjContRevenue.ContractLine__c=TempObjContractLine01.Id;
                //try{
                ObjContRevenue.Startdate__c=TempObjContractLine01.ContractID__r.StartDate;
                //}
                //catch(System.NullPointerException e){
                
                //    TempObjContractLine.adderror(e);
                //}
                ObjContRevenue.ContractId__c=TempObjContractLine01.ContractID__c;
                //ObjContRevenue.RevenueEndDate__c=
                ObjContRevenue.Description__c=TempObjContractLine01.Product_Family__c;
                ObjContRevenue.Billing_Term__c=TempObjContractLine01.BillingTerms__c;
                ObjContRevenue.RevenueType__c=TempObjContractLine01.Product_Family__c;
                ObjContRevenue.CompanyCode__c=TempObjContractLine01.ContractID__r.CompanyCode__c;
                //ObjContRevenue.RevenueAmount__c=TempObjContractLine.TotalPrice__c;
                TempObjContractLine01.Amount__c=TempObjContractLine01.TotalPrice__c;
                TempObjContractLine01.HasRevenueItemCreated__c=true;
                
                VarCheckRevenueCreated=true;
                
                LstObjContractRevenue.add(ObjContRevenue);
                //}
            }
            */
            }
            catch(exception e){
            
                ObjContract.adderror('Something went wrong--'+e);
            }
        
        
        }

        //try{
        //if(!Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.getBoolVarPreventtrggFirLoopMethodForSoftwareFam () ){ 
        Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.setBoolVarPreventtrggFirLoopMethodForSoftwareFam () ; 
        Update  LstContractLine;

        if(VarCheckRevenueCreated==true){
            system.debug('RevItem');
            insert  LstObjContractRevenue;
            //VarCheckRevenueCreated=true;
        }
//}




    //}
        }
       Catch(exception e){
        VarBoolError=true;
        ApexPages.addMessages(e);
        //return null;
        
        } 

        if(VarBoolError==false){            
            PageReference DetailedPage = new PageReference('/'+ObjContract.id);   
            return DetailedPage ;   
        }
        else{
            return null;
        }
    }
}