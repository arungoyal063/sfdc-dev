trigger Ellu_SFDC_SAP_Int_Trigger_ContractToDefaultConBillRecAndContLineRevLineCreationAndSync on Contract (before update ,after Update) {
        
    Map<Id,Contract> MapIdContract=new Map<Id,Contract>();
    List<Contract_Revenue__c> LstObjContractRevenue = new List<Contract_Revenue__c>();
    
    //List<Contract_Billing__c> LstObjConBilling = new List<Contract_Billing__c>();
    List<Contract_Billing__c> LstObjConBill= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstObjConBill02= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstObjConBill03= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstObjConBill04= new  List<Contract_Billing__c>();
    
    public boolean VarCheckRevenueCreated=false;
    public boolean VarCheckSoftBill = false;
    public boolean VarCheckFixSerBill = false;
    public boolean VarCheckOthSerBill = false;
    public boolean VarCheckAnnLicBill = false;
    
    Public Date TempSignedDate=null;
    Public Decimal DecTotalAmount = 0; 
    
           
    system.debug('Printing Contract record02'+trigger.new);
    
    for(Contract TempObjContract : trigger.new){
    
        MapIdContract.Put(TempObjContract.Id,TempObjContract);
       // TempObjContract.ContractExecutionDate__c=TempObjContract.StartDate;
    
    }
    
    
    Map<ID,Decimal> MpSoftCon = new Map<ID,Decimal>();
    Map<ID,Decimal> MpFixedSerCon = new Map<ID,Decimal>();
    Map<ID,Decimal> MpOtherSerCon = new Map<ID,Decimal>();
    Map<ID,Decimal> MpAnnualLicCon = new Map<ID,Decimal>();
    List<ContractLine__c> LstContractLine=new List<ContractLine__c>();
    List<Contract_Revenue__c> LstConRev= new List<Contract_Revenue__c>();
    List<Contract_Billing__c> LstConLine=new List<Contract_Billing__c>();
    List<Contract_Billing__c> LstUbpObjConBill= new  List<Contract_Billing__c>();
    public Boolean VarBillingCheck=false;
    Map<String,ContractLine__c> MpValConLine = new Map<String,ContractLine__c>();
    Map<String,Contract_Billing__c> MpValConBill = new Map<String,Contract_Billing__c>();
    Map<Id,Set<Contract_Billing__c>> MpConIdConBill= new Map<Id,Set<Contract_Billing__c>>();
    //Set<Contract_Billing__c> SetObjConBill = new Set<Contract_Billing__c>();
    Decimal TotalPercentage=0;
    
   // if(!Ellu_SFDC_SAP_PreventInfiniteTrigLoop.getBoolVarPreventtrggFirLoopMethod() ){
    
    //    Ellu_SFDC_SAP_PreventInfiniteTrigLoop.setBoolVarPreventtrggFirLoopMethod() ;
    try{
    if(Trigger.IsAfter){
        LstConRev=[SELECT Id ,ContractLine__c,Startdate__c FROM Contract_Revenue__c WHERE ContractId__c IN :trigger.new ];
        LstConLine=[SELECT Id ,ContractId__c,BillingDate__c,Item_Type__c,Billing_Terms__c , Name,ContractId__r.Status,PaymentPercentage__c  FROM Contract_Billing__c WHERE ContractId__c IN : trigger.new ];
        
        for(Contract_Billing__c ObjConBill : LstConLine ){
        
            system.debug('Printing Contract record03'+ObjConBill+ObjConBill.ContractId__c+ObjConBill.ContractId__r.Status);
            
            if(ObjConBill.ContractId__r.Status =='Sent to SAP'){
            
                MpValConBill.put(ObjConBill.ContractId__c+ObjConBill.Item_Type__c+ObjConBill.Billing_Terms__c,ObjConBill); 
                //MpConIdConBill.put(ObjConBill.ContractId__c,);
                //SetObjConBill.clear();
                if(MpConIdConBill.get(ObjConBill.ContractId__c) <> null){
                    Set<Contract_Billing__c> SetObjConBill = new Set<Contract_Billing__c>();
                    SetObjConBill=MpConIdConBill.get(ObjConBill.ContractId__c);
                    system.debug('Total set'+MpConIdConBill.get(ObjConBill.ContractId__c));
                    SetObjConBill.add(ObjConBill);
                    MpConIdConBill.put(ObjConBill.ContractId__c ,SetObjConBill);
                    system.debug('total list'+MpConIdConBill.get(trigger.new[0].id));
                    
                } 
                else {
                    //SetObjConBill.clear();
                    Set<Contract_Billing__c> SetObjConBill = new Set<Contract_Billing__c>();
                    SetObjConBill.add(ObjConBill);
                    MpConIdConBill.put(ObjConBill.ContractId__c ,SetObjConBill); 
                    //SetObjConBill.clear();   
                }  
            }
        }
        system.debug('total list'+MpConIdConBill.get(trigger.new[0].id)); 
        for(ContractLine__c TempObjContractLine : [SELECT Id,Name,ContractID__c,Product_Family__c,Item_Type__c,PaymentTerms__c,BillingTerms__c,HasRevenueItemCreated__c,
                       ContractID__r.StartDate,ContractID__r.Status,ContractID__r.IsSoftwareBillRecCreated__c,ContractID__r.CompanyCode__c,TotalPrice__c
                       ,ProductId__r.ProductCode,ProductId__r.Description,ProductId__r.Name,ProductId__r.LOB__c
                       ,ServicesStartDate__c,ServicesEndDate__c,AgreementItemStartDate__c,AgreementItemEndDate__c FROM ContractLine__c WHERE ContractID__c IN:trigger.new]){
            try{
            
                if(TempObjContractLine.ContractID__r.Status =='Sent to SAP'){
                    
                    if(TempObjContractLine.Item_Type__c== null || TempObjContractLine.Item_Type__c =='' || TempObjContractLine.PaymentTerms__c ==null || TempObjContractLine.PaymentTerms__c =='' ){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because Item type OR Payment Terms field is blank for  '+TempObjContractLine.Name);    
                        
                    }
                    
                    if(TempObjContractLine.Product_Family__c=='Services' && (TempObjContractLine.ServicesStartDate__c==null || TempObjContractLine.ServicesEndDate__c==null )){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because Services Start Date OR Service End Date field is blank for  '+TempObjContractLine.Name);    
                        
                    }
                    
                    if(TempObjContractLine.Product_Family__c!='Services' && (TempObjContractLine.AgreementItemStartDate__c==null || TempObjContractLine.AgreementItemEndDate__c==null )){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because Item Start Date OR Item End Date field is blank for  '+TempObjContractLine.Name);    
                        
                    }
                    
                    /*
                    if( TempObjContractLine.PaymentTerms__c ==null || TempObjContractLine.PaymentTerms__c ==''){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because Payment Terms field is blank for  '+TempObjContractLine.Name);    
                        
                    }*/
                    if(TempObjContractLine.ProductId__r.ProductCode== null || TempObjContractLine.ProductId__r.ProductCode ==''){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because Product Code field is blank for Product related to '+TempObjContractLine.Name);    
                        
                    }
                    if(TempObjContractLine.ProductId__r.Description== null || TempObjContractLine.ProductId__r.Description ==''){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because Product Description field is blank for Product related to '+TempObjContractLine.Name);    
                        
                    }
                    if(TempObjContractLine.ProductId__r.Name== null || TempObjContractLine.ProductId__r.Name ==''){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because Product Name field is blank for Product related to '+TempObjContractLine.Name);    
                        
                    }

                    if(TempObjContractLine.ProductId__r.LOB__c== null || TempObjContractLine.ProductId__r.LOB__c ==''){
                        
                        trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because LOB field is blank for Product related to '+TempObjContractLine.Name);    
                        
                    }
                    
                    

                    MpValConLine.put(TempObjContractLine.ContractID__c+TempObjContractLine.Item_Type__c+TempObjContractLine.BillingTerms__c,TempObjContractLine); 
                    if(TempObjContractLine.Item_Type__c =='Fixed Fee' || TempObjContractLine.Item_Type__c == 'Software' || TempObjContractLine.Item_Type__c =='Others' ){
                        
                         
                        
                        if(MpValConBill.get(TempObjContractLine.ContractID__c+TempObjContractLine.Item_Type__c+TempObjContractLine.BillingTerms__c)==null){
                            
                            trigger.newMap.get(TempObjContractLine.ContractID__c).adderror('Status cannot be changed to "Sent to SAP" because no Contract Billing record is present corresponding to '+TempObjContractLine.Name );    
                        
                            
                        }   
                    }       
                }
                
                TempObjContractLine.AgreementItemStartDate__c=MapIdContract.get(TempObjContractLine.ContractID__c).StartDate;
                //TempObjContractLine.ServicesEndDate__c=MapIdContract.get(TempObjContractLine.ContractID__c).EndDate;
                
                //TempObjContractLine.ServicesStartDate__c=MapIdContract.get(TempObjContractLine.ContractID__c).StartDate;
                if(TempObjContractLine.Product_Family__c=='Services'){
                    TempObjContractLine.Ship_Date__c=MapIdContract.get(TempObjContractLine.ContractID__c).Ship_Date__c;
                    TempObjContractLine.Shipping_Comments__c=MapIdContract.get(TempObjContractLine.ContractID__c).Shipping_Comments__c;
                    //TempObjContractLine.Shipping_IDOC_Reference__c=MapIdContract.get(TempObjContractLine.ContractID__c).Shipping_IDoc_Reference__c;
                }
                if(TempObjContractLine.ContractID__r.StartDate<>null){
                   // TempObjContractLine.AgreementItemStartDate__c=TempObjContractLine.ContractID__r.StartDate;
                    //TempObjContractLine.ServicesStartDate__c=TempObjContractLine.ContractID__r.StartDate;    
                }
            LstContractLine.add(TempObjContractLine);
            
            //Logic for creating Revenue line items
            for(Contract_Revenue__c ObjContRevenue : LstConRev ){
                if(TempObjContractLine.HasRevenueItemCreated__c==true && TempObjContractLine.ContractID__r.StartDate<>null && ObjContRevenue.ContractLine__c==TempObjContractLine.Id && ObjContRevenue.Startdate__c== trigger.OldMap.get(TempObjContractLine.ContractID__r.Id).StartDate ){
                
                //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                                    
                
                    //Contract_Revenue__c ObjContRevenue = new Contract_Revenue__c();
                    //ObjContRevenue.ContractLine__c=TempObjContractLine.Id;
                    //try{
                    ObjContRevenue.Startdate__c=TempObjContractLine.ContractID__r.StartDate;
                    //}
                    //catch(System.NullPointerException e){
                
                    //    TempObjContractLine.adderror(e);
                    //}
                    //ObjContRevenue.ContractId__c=TempObjContractLine.ContractID__c;
                    //ObjContRevenue.RevenueEndDate__c=
                    //ObjContRevenue.Description__c=TempObjContractLine.Product_Family__c;
                    //ObjContRevenue.Billing_Term__c=TempObjContractLine.BillingTerms__c;
                    //ObjContRevenue.RevenueType__c=TempObjContractLine.Product_Family__c;
                    //ObjContRevenue.CompanyCode__c=TempObjContractLine.ContractID__r.CompanyCode__c;
                    //ObjContRevenue.RevenueAmount__c=TempObjContractLine.TotalPrice__c;
                    //TempObjContractLine.HasRevenueItemCreated__c=true;
                
                    VarCheckRevenueCreated=true;
                
                    LstObjContractRevenue.add(ObjContRevenue);
                }
            }
            
           
            }
            catch(exception e){
            
                MapIdContract.get(TempObjContractLine.ContractID__c).adderror('Something went wrong--'+e);
            }
        
        
        }
        for(Contract ObjCon : trigger.new){
             for(Contract_Billing__c ObjContBill :  LstConLine ){
             
                    system.debug('Printing Contract record03'+ObjContBill+ObjContBill.ContractId__c+ObjContBill.ContractId__r.Status);
                    
                    if(ObjContBill.ContractId__r.Status =='Sent to SAP' && ObjContBill.ContractId__c==ObjCon.Id){
                        system.debug('OK'+MpValConLine);
                        if(MpValConLine.get(ObjContBill.ContractId__c+ObjContBill.Item_Type__c+ObjContBill.Billing_Terms__c)==null){
                            
                            trigger.newMap.get(ObjContBill.ContractId__c).adderror('Status cannot be changed to "Sent to SAP" because no Contract line item is present corresponding to '+ObjContBill.Name +' record.' );    
                        }
                        
                        TotalPercentage=0;
                        
                        system.debug('Final'+MpConIdConBill);
                        
                        for(Contract_Billing__c ObjContBill01 : MpConIdConBill.get(ObjContBill.ContractId__c)){
                        
                            if(ObjContBill01.Item_Type__c ==ObjContBill.Item_Type__c && ObjContBill01.Billing_Terms__c ==ObjContBill.Billing_Terms__c ){
                                
                                TotalPercentage= TotalPercentage+ObjContBill01.PaymentPercentage__c ;   
                            }    
                            system.debug('Rahul'+TotalPercentage +'Miyan'+MpConIdConBill.get(ObjContBill.ContractId__c));
                        }
                        system.debug('Total Percentage'+ TotalPercentage);
                        if(TotalPercentage<>100){
                            
                            trigger.newMap.get(ObjContBill.ContractId__c).adderror('Status cannot be changed to "Sent to SAP" because the sum of percentage is not 100% on Billing record(s) for the combination of Item Type "'+ObjContBill.Item_Type__c +'" and Billing Terms "'+ObjContBill.Billing_Terms__c+'"');    
                        }   
                    }
                     
                     
                    if(ObjCon.StartDate<>null && ObjContBill.ContractId__c==ObjCon.Id && ObjContBill.BillingDate__c== trigger.OldMap.get(ObjCon.Id).StartDate){
                    
                  
                        ObjContBill.BillingDate__c=ObjCon.StartDate;
                                           
                        //VarCheckRevenueCreated=true;
                        VarBillingCheck=true;
                        LstUbpObjConBill.add(ObjContBill);
                    }
              }
         } 
           
        try{
        if(!Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.getBoolVarPreventtrggFirLoopMethodForSoftwareFam () ){ 
            Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.setBoolVarPreventtrggFirLoopMethodForSoftwareFam () ; 
            Update  LstContractLine;
           
            if(VarCheckRevenueCreated==true){
            
                update  LstObjContractRevenue;
                //VarCheckRevenueCreated=true;
            }
            if(VarBillingCheck==true){
            
                update LstUbpObjConBill;
            }
            
        }
        }
        catch(exception e){
            
        }
    }
    
    /*
    If(trigger.IsBefore){
    
        
        for(ContractLine__c TempObjContractLine : [SELECT Id,ContractID__c,Product_Family__c,BillingTerms__c,HasRevenueItemCreated__c,
                       ContractID__r.ContractExecutionDate__c,ContractID__r.IsSoftwareBillRecCreated__c,
                       ContractID__r.IsFixedServBillRecCreated__c ,ContractID__r.IsAnnLicBillRecCreated__c,ContractID__r.IsOtherServBillRecCreated__c,
                       ContractID__r.CompanyCode__c,Item_Type__c,TotalPrice__c FROM ContractLine__c WHERE ContractID__c IN:trigger.new]){
            try{
            if(TempObjContractLine.ContractID__r.IsSoftwareBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Software' && TempObjContractLine.BillingTerms__c=='On Execution'){
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
                //VarCheckSoftBill=true; 
            }
            }
            catch(exception e){
            
                //TempObjContractLine.adderror(e);
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);    
            }
            try{
            if(TempObjContractLine.ContractID__r.IsFixedServBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Fixed Fee' && TempObjContractLine.BillingTerms__c=='As Incurred'){
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
                //VarCheckSoftBill=true; 
            }
            }
            catch(exception e){
            
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);     
            }
            
            
            try{
            if(TempObjContractLine.ContractID__r.IsOtherServBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Others' && TempObjContractLine.BillingTerms__c=='As Incurred'){
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
                //VarCheckSoftBill=true; 
            }
            }
            catch(exception e){
            
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);     
            }
            
            try{
            if(TempObjContractLine.ContractID__r.IsAnnLicBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Annual License' && TempObjContractLine.Item_Type__c == 'Annual License' && TempObjContractLine.BillingTerms__c=='Annual License'){
                //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                if(MpAnnualLicCon.get(TempObjContractLine.ContractID__c)<> null){
                    DecTotalAmount=TempObjContractLine.TotalPrice__c+MpAnnualLicCon.get(TempObjContractLine.ContractID__c); 
                    MpAnnualLicCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                    DecTotalAmount=0;                                       
                }                    
                else{
                    MpAnnualLicCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                }
                //VarCheckSoftBill=true; 
            }
            }
            catch(exception e){
            
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);     
            } 
        }
        
        
        For(Contract ObjContract : trigger.New){
        
            If(ObjContract.IsSoftwareBillRecCreated__c == false && MpSoftCon.get(ObjContract.Id) <> null){
                    
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluSoftBill.Name 
                                                                           ,Total_Amount__c=MpSoftCon.get(ObjContract.Id), Item_Type__c=ObjElluSoftBill.Name
                                                                           ,Payment_Timing__c=ObjElluSoftBill.Payment_Timing__c,PaymentPercentage__c=ObjElluSoftBill.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluSoftBill.Number_Of_Payment__c,Payment_Amount__c=MpSoftCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluSoftBill.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluSoftBill.Billing_Terms__c);
        
                
                //LstObjConBill.add(ObjConBilling);
                ObjContract.IsSoftwareBillRecCreated__c = true;
            }
            
             If(ObjContract.IsFixedServBillRecCreated__c == false && MpFixedSerCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluSoftBill.Name 
                                                                           ,Total_Amount__c=MpSoftCon.get(ObjContract.Id), Item_Type__c=ObjElluSoftBill.Name
                                                                           ,Payment_Timing__c=ObjElluSoftBill.Payment_Timing__c,PaymentPercentage__c=ObjElluSoftBill.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluSoftBill.Number_Of_Payment__c,Payment_Amount__c=MpSoftCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluSoftBill.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluSoftBill.Billing_Terms__c);
                
                //LstObjConBill.add(ObjConBilling);
                ObjContract.IsFixedServBillRecCreated__c = true;
            }
            
            If(ObjContract.IsOtherServBillRecCreated__c == false && MpOtherSerCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluSoftBill.Name 
                                                                           ,Total_Amount__c=MpSoftCon.get(ObjContract.Id), Item_Type__c=ObjElluSoftBill.Name
                                                                           ,Payment_Timing__c=ObjElluSoftBill.Payment_Timing__c,PaymentPercentage__c=ObjElluSoftBill.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluSoftBill.Number_Of_Payment__c,Payment_Amount__c=MpSoftCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluSoftBill.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluSoftBill.Billing_Terms__c);
                
                //LstObjConBill.add(ObjConBilling);
                ObjContract.IsOtherServBillRecCreated__c = true;
            }
            
             If(ObjContract.IsAnnLicBillRecCreated__c == false && MpAnnualLicCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
               
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluSoftBill.Name 
                                                                           ,Total_Amount__c=MpSoftCon.get(ObjContract.Id), Item_Type__c=ObjElluSoftBill.Name
                                                                           ,Payment_Timing__c=ObjElluSoftBill.Payment_Timing__c,PaymentPercentage__c=ObjElluSoftBill.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluSoftBill.Number_Of_Payment__c,Payment_Amount__c=MpSoftCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluSoftBill.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluSoftBill.Billing_Terms__c);
                  
                //LstObjConBill.add(ObjConBilling);
                ObjContract.IsAnnLicBillRecCreated__c = true;
            }
        }
        
          
    }
    */
    /*
    if(trigger.IsAfter){
    
    
        
        for(ContractLine__c TempObjContractLine : [SELECT Id,ContractID__c,Product_Family__c,BillingTerms__c,HasRevenueItemCreated__c,
                       ContractID__r.ContractExecutionDate__c,ContractID__r.IsSoftwareBillRecCreated__c,ContractID__r.IsFixedServBillRecCreated__c
                       ,ContractID__r.IsAnnLicBillRecCreated__c,Item_Type__c,ContractID__r.IsOtherServBillRecCreated__c
                       ,ContractID__r.CompanyCode__c,TotalPrice__c FROM ContractLine__c WHERE ContractID__c IN:trigger.new]){
            try{
            if(TempObjContractLine.ContractID__r.IsSoftwareBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Software'  ){
            
            
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
                VarCheckSoftBill=true; 
            }
            }
            catch(exception e){
            
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);     
            }
            
            try{
            if(TempObjContractLine.ContractID__r.IsFixedServBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Fixed Fee' && TempObjContractLine.BillingTerms__c=='As Incurred'){
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
            
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);     
            }
            
            try{
            if(TempObjContractLine.ContractID__r.IsOtherServBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Others' && TempObjContractLine.BillingTerms__c=='As Incurred'){
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
            
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);     
            }
            
            
            try{
            if(TempObjContractLine.ContractID__r.IsAnnLicBillRecCreated__c==false && TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Annual License' && TempObjContractLine.Item_Type__c == 'Annual License' && TempObjContractLine.BillingTerms__c=='Annual License'){
                //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                if(MpAnnualLicCon.get(TempObjContractLine.ContractID__c)<> null){
                    DecTotalAmount=TempObjContractLine.TotalPrice__c+MpAnnualLicCon.get(TempObjContractLine.ContractID__c); 
                    MpAnnualLicCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                    DecTotalAmount=0;                                       
                }                    
                else{
                    MpAnnualLicCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                }
                VarCheckAnnLicBill=true; 
            }
            }
            catch(exception e){
            
                Trigger.newMap.Get(TempObjContractLine.ContractID__c).adderror(e);     
            }
        }
        
        //Ellu_Software_Billing__c ObjElluSoftBill = new Ellu_Software_Billing__c();
        //ObjElluSoftBill=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c,Billing_Terms__c FROM Ellu_Software_Billing__c WHERE NAME='Software' Limit 1 ];
        
        Ellu_Software_Billing__c ObjElluSoftBill = new Ellu_Software_Billing__c();
        //ObjElluSoftBill=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c FROM Ellu_Software_Billing__c WHERE NAME='Software' Limit 1 ];
        
        Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluFixedDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
        //ObjElluFixedDefBillRec=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c , Item_Type__c,Product_Family__c FROM Ellu_CustDefaultBillRecordsExcepSoftware__c WHERE Name='Fixed Services' Limit 1 ];
        
        //Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluOtherDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
        //ObjElluOtherDefBillRec=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c , Item_Type__c,Product_Family__c FROM Ellu_CustDefaultBillRecordsExcepSoftware__c WHERE Name='Other Services' Limit 1 ];
        
        //Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluAnnualLicDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
        //ObjElluAnnualLicDefBillRec=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c , Item_Type__c,Product_Family__c FROM Ellu_CustDefaultBillRecordsExcepSoftware__c WHERE Name='Annual License' Limit 1 ];
        
        ObjElluSoftBill=Ellu_Software_Billing__c.getvalues('Software');
        ObjElluFixedDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Fixed Services');
        //ObjElluOtherDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Other Services');
        //ObjElluAnnualLicDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Annual License');
            
            
        For(Contract ObjContract : trigger.New){
        
            If(ObjContract.IsSoftwareBillRecCreated__c == false && MpSoftCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluSoftBill.Name 
                                                                           ,Total_Amount__c=MpSoftCon.get(ObjContract.Id), Item_Type__c=ObjElluSoftBill.Name
                                                                           ,Payment_Timing__c=ObjElluSoftBill.Payment_Timing__c,PaymentPercentage__c=ObjElluSoftBill.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluSoftBill.Number_Of_Payment__c,Payment_Amount__c=MpSoftCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluSoftBill.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluSoftBill.Billing_Terms__c);
        
                LstObjConBill.add(ObjConBilling);
               // ObjContract.IsSoftwareBillRecCreated__c = true;
            }
             If(ObjContract.IsFixedServBillRecCreated__c == false && MpFixedSerCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluFixedDefBillRec.Product_Family__c
                                                                           ,Total_Amount__c=MpFixedSerCon.get(ObjContract.Id), Item_Type__c=ObjElluFixedDefBillRec.Item_Type__c
                                                                           ,Payment_Timing__c=ObjElluFixedDefBillRec.Payment_Timing__c,PaymentPercentage__c=ObjElluFixedDefBillRec.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluFixedDefBillRec.Number_Of_Payment__c,Payment_Amount__c=MpFixedSerCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluFixedDefBillRec.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluFixedDefBillRec.Billing_Terms__c);
        
                LstObjConBill02.add(ObjConBilling);
               // ObjContract.IsSoftwareBillRecCreated__c = true;
            }
            
             If(ObjContract.IsOtherServBillRecCreated__c == false && MpOtherSerCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluOtherDefBillRec.Product_Family__c
                                                                           ,Total_Amount__c=MpOtherSerCon.get(ObjContract.Id), Item_Type__c=ObjElluOtherDefBillRec.Item_Type__c
                                                                           ,Payment_Timing__c=ObjElluOtherDefBillRec.Payment_Timing__c,PaymentPercentage__c=ObjElluOtherDefBillRec.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluOtherDefBillRec.Number_Of_Payment__c,Payment_Amount__c=MpOtherSerCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluOtherDefBillRec.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluOtherDefBillRec.Billing_Terms__c);
        
                LstObjConBill04.add(ObjConBilling);
               // ObjContract.IsSoftwareBillRecCreated__c = true;
            }
            
             If(ObjContract.IsAnnLicBillRecCreated__c == false && MpAnnualLicCon.get(ObjContract.Id) <> null){
        
                //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluAnnualLicDefBillRec.Product_Family__c 
                                                                           ,Total_Amount__c=MpAnnualLicCon.get(ObjContract.Id), Item_Type__c=ObjElluAnnualLicDefBillRec.Item_Type__c
                                                                           ,Payment_Timing__c=ObjElluAnnualLicDefBillRec.Payment_Timing__c,PaymentPercentage__c=ObjElluAnnualLicDefBillRec.Payment_Percentage__c
                                                                           ,NumberofPayments__c=ObjElluAnnualLicDefBillRec.Number_Of_Payment__c,Payment_Amount__c=MpAnnualLicCon.get(ObjContract.Id)
                                                                           ,Percentage_OR_Amount__c=ObjElluAnnualLicDefBillRec.Percentage_OR_Amount__c,BillingDate__c=ObjContract.ContractExecutionDate__c
                                                                           ,Billing_Terms__c=ObjElluAnnualLicDefBillRec.Billing_Terms__c);
        
                LstObjConBill03.add(ObjConBilling);
               // ObjContract.IsSoftwareBillRecCreated__c = true;
            }
            
        }
    
     if(VarCheckSoftBill=true){
        system.debug('Last insertion' + LstObjConBill);
        insert LstObjConBill;
        } 
     if(VarCheckFixSerBill=true){
        system.debug('Last insertion' + LstObjConBill02);
        insert LstObjConBill02;
        } 
        
      if(VarCheckOthSerBill=true){
        system.debug('Last insertion' + LstObjConBill04);
        insert LstObjConBill04;
        }  
        
       
     if(VarCheckAnnLicBill=true){
        system.debug('Last insertion' + LstObjConBill03);
        insert LstObjConBill03;
        }    
     } */       
     }
     catch(exception e){
         //trigger.new[0].adderror('');
     }     
    // }   
 }