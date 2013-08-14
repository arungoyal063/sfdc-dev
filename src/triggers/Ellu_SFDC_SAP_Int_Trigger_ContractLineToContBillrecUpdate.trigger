trigger Ellu_SFDC_SAP_Int_Trigger_ContractLineToContBillrecUpdate on ContractLine__c (after Update) {

    Set<Id> VarSetId = new Set<Id>();
    //List<Contract__c> LstObjCon = new List<Contract__c>();
    Map<Contract,Contract_Billing__c> MpConConBilling = new Map<Contract,Contract_Billing__c>();
     Public Decimal DecTotalAmount = 0;
     Map<ID,Decimal> MpSoftCon = new Map<ID,Decimal>();
     Map<ID,Decimal> MpFixedSerCon = new Map<ID,Decimal>();
     Map<ID,Decimal> MpOtherSerCon = new Map<ID,Decimal>();
     Map<ID,Decimal> MpAnnualLicCon = new Map<ID,Decimal>();
     
    List<Contract_Billing__c> LstObjConBill= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstObjConBill02= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstObjConBill03= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstObjConBill04= new  List<Contract_Billing__c>();
    
    List<Contract_Billing__c> LstDelObjConBill= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstDelObjConBill02= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstDelObjConBill03= new  List<Contract_Billing__c>();
    List<Contract_Billing__c> LstDelObjConBill04= new  List<Contract_Billing__c>();
    
    Set<ID> VarSetId02 = new Set<ID>();
    Set<ID> VarSetId03 = new Set<ID>();
    Set<ID> VarSetId04 = new Set<ID>();
    Set<ID> VarSetId05 = new Set<ID>();
    
    if(!Ellu_SFDC_SAP_PrTrigLoopCreateContCls.getBoolVarPrTrigLoopForCreateContract ()){
       //Ellu_SFDC_SAP_PrTrigLoopCreateContCls.setBoolVarPrTrigLoopForCreateContract ();
    
    
     if(!Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.getBoolVarPreventtrggFirLoopMethodForSoftwareFam () ){ 
     Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam.setBoolVarPreventtrggFirLoopMethodForSoftwareFam () ; 
    For(ContractLine__c TempObjConLine : trigger.New){
    
        VarSetId.add(TempObjConLine.ContractID__c);    
    }
    
    for(ContractLine__c TempObjContractLine : [SELECT Id,ContractID__c,Product_Family__c,BillingTerms__c,HasRevenueItemCreated__c,
                                               UnitPrice__c,Quantity__c,ContractID__r.ContractExecutionDate__c,ContractID__r.CompanyCode__c
                                              ,ItemPrice__c,Discount_Percent__c, Item_Type__c ,TotalPrice__c FROM ContractLine__c WHERE ContractID__c IN:VarSetId]){
            try{
                if(TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Software' && TempObjContractLine.BillingTerms__c=='On Execution' ){
                    VarSetId02.add(TempObjContractLine.ContractID__c);
                    system.debug('FairFax'+TempObjContractLine.UnitPrice__c);
                    //VarSetId.add(TempObjContractLine.ContractID__c);
                    //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                    //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                    if(MpSoftCon.get(TempObjContractLine.ContractID__c)<> null){
                        if(TempObjContractLine.Discount_Percent__c==null){
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c+MpSoftCon.get(TempObjContractLine.ContractID__c); 
                        }
                        else{
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c+MpSoftCon.get(TempObjContractLine.ContractID__c);
                        }
                        MpSoftCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                        DecTotalAmount=0;
                        system.debug('MpSoftCon'+MpSoftCon);                                       
                    }                    
                    else{
                        if(TempObjContractLine.Discount_Percent__c==null){
                        MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c);
                        }
                        else {
                        MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c);
                        }
                       system.debug('MpSoftCon'+MpSoftCon);
                    }
                //VarCheckSoftBill=true; 
                }
            }
            catch(exception e){
               Trigger.newMap.Get(TempObjContractLine.Id).adderror(e);
            }
            
              try{
            if( TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Fixed Fee' && TempObjContractLine.BillingTerms__c=='On Execution'){
                //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                VarSetId03.add(TempObjContractLine.ContractID__c);
                if(MpFixedSerCon.get(TempObjContractLine.ContractID__c)<> null){
                    if(TempObjContractLine.Discount_Percent__c==null){
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c+MpFixedSerCon.get(TempObjContractLine.ContractID__c); 
                    }
                    else{
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c+MpFixedSerCon.get(TempObjContractLine.ContractID__c);
                    }
                    MpFixedSerCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                    DecTotalAmount=0;                                       
                }                    
                else{
                    if(TempObjContractLine.Discount_Percent__c==null){
                        MpFixedSerCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c);
                    }
                    else{
                        MpFixedSerCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c);
                    }
                }
                //VarCheckFixSerBill=true; 
            }
            }
            catch(exception e){
            
                 Trigger.newMap.Get(TempObjContractLine.Id).adderror(e);     
            }
            
            try{
            if( TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Services' && TempObjContractLine.Item_Type__c == 'Others' && TempObjContractLine.BillingTerms__c=='As Incurred'){
                //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                VarSetId04.add(TempObjContractLine.ContractID__c);
                if(MpOtherSerCon.get(TempObjContractLine.ContractID__c)<> null){
                    if(TempObjContractLine.Discount_Percent__c==null){
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c+MpOtherSerCon.get(TempObjContractLine.ContractID__c); 
                    }
                    else{
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c+MpOtherSerCon.get(TempObjContractLine.ContractID__c);
                    }
                    MpOtherSerCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                    DecTotalAmount=0;                                       
                }                    
                else{
                    if(TempObjContractLine.Discount_Percent__c==null){
                        MpOtherSerCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c);
                    }
                    else{
                        MpOtherSerCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c);
                    }
                }
                //VarCheckOthSerBill=true; 
            }
            }
            catch(exception e){
            
                 Trigger.newMap.Get(TempObjContractLine.Id).adderror(e);       
            }
            
            
            /*
            try{
            if(TempObjContractLine.ContractID__r.ContractExecutionDate__c<>null && TempObjContractLine.Product_Family__c=='Annual License' && TempObjContractLine.Item_Type__c == 'Annual License' && TempObjContractLine.BillingTerms__c=='Annual License'){
                //TempSignedDate=TempObjContractLine.ContractID__r.ContractExecutionDate__c;
                //MpSoftCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.TotalPrice__c);
                VarSetId05.add(TempObjContractLine.ContractID__c);
                if(MpAnnualLicCon.get(TempObjContractLine.ContractID__c)<> null){
                    if(TempObjContractLine.Discount_Percent__c==null){
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c+MpAnnualLicCon.get(TempObjContractLine.ContractID__c); 
                    }
                    else{
                        DecTotalAmount=TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c+MpAnnualLicCon.get(TempObjContractLine.ContractID__c);
                    }
                    MpAnnualLicCon.put(TempObjContractLine.ContractID__c,DecTotalAmount);
                    DecTotalAmount=0;                                       
                }                    
                else{
                    if(TempObjContractLine.Discount_Percent__c==null){
                        MpAnnualLicCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*TempObjContractLine.Quantity__c);
                    }
                    else{
                        MpAnnualLicCon.put(TempObjContractLine.ContractID__c,TempObjContractLine.ItemPrice__c*(1-TempObjContractLine.Discount_Percent__c/100)*TempObjContractLine.Quantity__c);
                    }
                }
                //VarCheckAnnLicBill=true; 
            }
            }
            catch(exception e){
            
                 Trigger.newMap.Get(TempObjContractLine.Id).adderror(e);      
            }*/
        }
        
        
        try{
            Ellu_Software_Billing__c ObjElluSoftBill = new Ellu_Software_Billing__c();
            //ObjElluSoftBill=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c,Billing_Terms__c FROM Ellu_Software_Billing__c WHERE NAME='Software' Limit 1 ];
            
            Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluFixedDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
            //ObjElluFixedDefBillRec=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c , Item_Type__c,Product_Family__c FROM Ellu_CustDefaultBillRecordsExcepSoftware__c WHERE Name='Fixed Services' Limit 1 ];
        
            Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluOtherDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
            //ObjElluOtherDefBillRec=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c , Item_Type__c,Product_Family__c FROM Ellu_CustDefaultBillRecordsExcepSoftware__c WHERE Name='Other Services' Limit 1 ];
        
            //Ellu_CustDefaultBillRecordsExcepSoftware__c ObjElluAnnualLicDefBillRec = new Ellu_CustDefaultBillRecordsExcepSoftware__c();
            //ObjElluAnnualLicDefBillRec=[SELECT Name,Percentage_OR_Amount__c,Payment_Timing__c,Number_Of_Payment__c,Payment_Percentage__c , Billing_Terms__c , Item_Type__c,Product_Family__c FROM Ellu_CustDefaultBillRecordsExcepSoftware__c WHERE Name='Annual License' Limit 1 ];
            
            
            ObjElluSoftBill=Ellu_Software_Billing__c.getvalues('Software');
            ObjElluFixedDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Fixed Services');
            ObjElluOtherDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Other Services');
            //ObjElluAnnualLicDefBillRec=Ellu_CustDefaultBillRecordsExcepSoftware__c.getvalues('Annual License');
            
            For(Contract ObjContract :[SELECT Id,ContractExecutionDate__c  FROM Contract WHERE Id IN: VarSetId]){
            
                If( MpSoftCon.get(ObjContract.Id) <> null){
                
                    //ObjElluSoftBill=[SELECT Name,Payment_Timing__c,Payment_Percentage__c FROM Ellu_Software_Billing__c WHERE NAME='Software' ];
                    Contract_Billing__c ObjConBilling = new Contract_Billing__c(ContractId__c=ObjContract.Id,Billing_Type__c =ObjElluSoftBill.Name 
                    ,Total_Amount__c=MpSoftCon.get(ObjContract.Id), Item_Type__c=ObjElluSoftBill.Name
                    ,Payment_Timing__c=ObjElluSoftBill.Payment_Timing__c,PaymentPercentage__c=ObjElluSoftBill.Payment_Percentage__c
                    ,NumberofPayments__c=ObjElluSoftBill.Number_Of_Payment__c,Payment_Amount__c=MpSoftCon.get(ObjContract.Id)
                    ,Percentage_OR_Amount__c=ObjElluSoftBill.Percentage_OR_Amount__c ,BillingDate__c=ObjContract.ContractExecutionDate__c 
                    , Billing_Terms__c=ObjElluSoftBill.Billing_Terms__c );
                    
                    LstObjConBill.add(ObjConBilling);
                    //ObjContract.IsSoftwareBillRecCreated__c = true;
                }
                
                
             If(MpFixedSerCon.get(ObjContract.Id) <> null){
        
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
            
             If(MpOtherSerCon.get(ObjContract.Id) <> null){
        
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
            /*
             If(MpAnnualLicCon.get(ObjContract.Id) <> null){
        
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
            */    
            }
            
            For(Contract_Billing__c ObjContractBill :[SELECT Id  FROM Contract_Billing__c WHERE Billing_Type__c = 'Software' AND Item_Type__c='Software' AND Billing_Terms__c='On Execution' AND ContractId__c IN: VarSetId02]){
            
                LstDelObjConBill.add(ObjContractBill);    
            }
            delete LstDelObjConBill;
            //if(VarCheckSoftBill=true){
            For(Contract_Billing__c ObjContractBill :[SELECT Id  FROM Contract_Billing__c WHERE Billing_Type__c = 'Services' AND Item_Type__c='Fixed Fee' AND Billing_Terms__c='On Execution' AND ContractId__c IN: VarSetId03]){
            
                LstDelObjConBill02.add(ObjContractBill);    
            }
            delete LstDelObjConBill02;
            
            For(Contract_Billing__c ObjContractBill :[SELECT Id  FROM Contract_Billing__c WHERE Billing_Type__c = 'Services' AND Item_Type__c='Others' AND Billing_Terms__c='As Incurred' AND ContractId__c IN: VarSetId04]){
            
                LstDelObjConBill03.add(ObjContractBill);    
            }
            delete LstDelObjConBill03;
            /*
            For(Contract_Billing__c ObjContractBill :[SELECT Id  FROM Contract_Billing__c WHERE Billing_Type__c = 'Annual License' AND Item_Type__c='Annual License' AND Billing_Terms__c='Annual License' AND ContractId__c IN: VarSetId05]){
            
                LstDelObjConBill04.add(ObjContractBill);    
            }
            delete LstDelObjConBill04;
            */
            
            
            system.debug('Ellucian' +LstObjConBill);
            insert LstObjConBill;
            insert LstObjConBill02;
            //insert LstObjConBill03;
            insert LstObjConBill04;
        }
        Catch(exception e){
        
            trigger.new[0].adderror(e);
        }
        //} 
   
    
    }
    }
}