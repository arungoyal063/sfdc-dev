//CHG00033305 VJK 03/25/2013 Included the change to skip validation if the User profile is system administrator
//CHG00032631 VJK 04/10/2013 Do not insert or update contract line item when the Opportunity Line Item's LOB is Third Party Margin Credit
//SalesCloud  AIM 05/3/2013 Replaced Discount Percentage from Opportunity.  Now calculating discount instead of Discount_Percent__c and    Only Sync Changes for Fixed Fee and T&M
trigger Ellu_SFDC_SAP_Int_Trigger_OppLineItem_to_ContractLineSync on OpportunityLineItem (after update , after insert , before delete) {

    //Public Static Boolean BoolVarPreventtrggFirLoop =false;
    
        
        Public List<Contract> LstObjContract = new List<Contract>();
        Public List<Contract> TempObjContract = new List<Contract>();
        Public List<ContractLine__c> LstObjContractLine= new List<ContractLine__c>();
        Public List<ContractLine__c> LstTempObjContractLine2= new List<ContractLine__c>();
        Public Set<String> StrVard= new Set<String>();
        Public Set<Id>  SetVarId = new Set<Id>();
        Public Map<Id,List<Contract>> MapOppIdToSetContract=new Map<Id,List<Contract>> ();
        Public Map<Id,OpportunityLineItem> MapIdtoOppLinItem = new Map<Id,OpportunityLineItem> ();
        Public RecordType ObjRecordTypeLicense;
        Public RecordType ObjRecordTypeService;
        Public RecordType ObjRecordTypeMaintenace;
        Public RecordType ObjRecordTypeAnnLicense;


//If the user profile is sys admin then skip the validation        
   if(UserInfo.getProfileId() <> '00eA00000012ALOIA2')
  {
    try{        
    if(!Ellu_SFDC_SAP_PreventInfiniteTrigLoop.getBoolVarPreventtrggFirLoopMethod() ){
        
        Ellu_SFDC_SAP_PreventInfiniteTrigLoop.setBoolVarPreventtrggFirLoopMethod();
        ObjRecordTypeLicense=[SELECT Id , Name FROM RecordType WHERE Name='LicenseFee-Product'];        
        ObjRecordTypeService=[SELECT Id , Name FROM RecordType WHERE Name='Services-Product'];        
        ObjRecordTypeMaintenace=[SELECT Id , Name FROM RecordType WHERE Name='Maintenance-Product'];
        ObjRecordTypeAnnLicense=[SELECT Id , Name FROM RecordType WHERE Name='Annual License-Product'];

        if(Trigger.IsInsert)
            {

                    For(OpportunityLineItem ObjOppLineItem : [SELECT Id, Discount_Amount__c,Discount_Reports__c,LOB__c,PricebookEntry.Product2Id,Quantity,TotalPrice,Unit_Of_Measure__c,
                                                  Description,OpportunityId,Total_Retail_Price__c,UnitPrice,Retail_Price__c,Services_Planned_End_Date__c,Services_Planned_Start_Date__c FROM OpportunityLineItem
                                                  
                                                  WHERE 
                                                  Id IN: trigger.new]){
            
            StrVard.add(string.valueof(ObjOppLineItem.Id));
            system.debug('OPPLISTID'+StrVard);
            SetVarId.add(ObjOppLineItem.OpportunityId);
            //MapOppLinItemIdToCotract.put(ObjOppLineItem.OpporunityId);
            MapIdtoOppLinItem.put(ObjOppLineItem.Id,ObjOppLineItem);            
        }
        
        LstObjContract=[SELECT Id,OpportunityId__c,EndDate,StartDate,Account.Payment_Terms__c FROM Contract WHERE OpportunityId__c IN: SetVarId];
        //for()
        
        For(Contract ObjContract : LstObjContract){
            if(MapOppIdToSetContract.get(ObjContract.OpportunityId__c)==null){
                TempObjContract.clear();
                TempObjContract.add(ObjContract);
                MapOppIdToSetContract.put(ObjContract.OpportunityId__c,TempObjContract);
            }
            else{
                TempObjContract.clear();
                TempObjContract.addall(MapOppIdToSetContract.get(ObjContract.OpportunityId__c));
                TempObjContract.add(ObjContract);
                MapOppIdToSetContract.put(ObjContract.OpportunityId__c,TempObjContract);
    
            }
            //MapIdToSetId.put();    
        }            

            For(OpportunityLineItem TempObjOppLineItem : [SELECT Id, Discount_Amount__c,Discount_Reports__c, Discount_Unit_Price__c , Discount_Percent__c,LOB__c,PricebookEntry.Product2Id,Quantity,TotalPrice,PricebookEntry.Product2.Family
                                                          ,PricebookEntry.Product2.LOB__c,Services_Planned_End_Date__c,Services_Planned_Start_Date__c,Unit_Of_Measure__c
                                                          ,Description,OpportunityId,Total_Retail_Price__c,UnitPrice,Retail_Price__c FROM OpportunityLineItem
                                                          WHERE 
                                                          Id IN: trigger.new]){

                if(MapOppIdToSetContract.get(TempObjOppLineItem.OpportunityId)<>null){
                 
                For(Contract ObjContract : MapOppIdToSetContract.get(TempObjOppLineItem.OpportunityId)){    
                    ContractLine__c ObjContractLine=new ContractLine__c();
                
                    //ObjContractLine.Name=TempObjOppLineItem
                
                    //ObjContractLine.CompanyCode__c=
                    ObjContractLine.ContractID__c=ObjContract.Id;
                    ObjContractLine.Discount_Amount__c=TempObjOppLineItem.Discount_Amount__c;
                    
                    //If Discount_Unit_Price__c is set then calculate discount else use the discount %
                    if (TempObjOppLineItem.Discount_Percent__c !=null && TempObjOppLineItem.Retail_Price__c != null && TempObjOppLineItem.Discount_Unit_Price__c <> 0)
                    {
                        ObjContractLine.Discount_Percent__c = (TempObjOppLineItem.Discount_Unit_Price__c / TempObjOppLineItem.Retail_Price__c) * 100;
                    }
                    else 
                    {
                        ObjContractLine.Discount_Percent__c = TempObjOppLineItem.Discount_Percent__c;
                    }   
                    ObjContractLine.LOB__c=TempObjOppLineItem.PricebookEntry.Product2.LOB__c;
                
                    ObjContractLine.ProductId__c=TempObjOppLineItem.PricebookEntry.Product2Id;
                    // Decimal TemQuantity;
                    //TemQuantity=OpportunityLineItem.Quantity;
                    ObjContractLine.Quantity__c=TempObjOppLineItem.Quantity;
                    ObjContractLine.TotalPrice__c=TempObjOppLineItem.TotalPrice;
                    ObjContractLine.Total_Retail_Price__c=TempObjOppLineItem.Total_Retail_Price__c;
                    ObjContractLine.UnitPrice__c=TempObjOppLineItem.UnitPrice;
                    ObjContractLine.ItemPrice__c=TempObjOppLineItem.Retail_Price__c;
                    //ObjContractLine.ServicesEndDate__c=ObjContract.EndDate;
                    //ObjContractLine.ServicesStartDate__c=ObjContract.StartDate;
                    ObjContractLine.ServicesEndDate__c=TempObjOppLineItem.Services_Planned_End_Date__c;
                    ObjContractLine.ServicesStartDate__c=TempObjOppLineItem.Services_Planned_Start_Date__c;
                    
                    ObjContractLine.AgreementItemStartDate__c=ObjContract.StartDate;
                    ObjContractLine.AgreementItemEndDate__c=ObjContract.EndDate;
                    ObjContractLine.OpportunityLineItemId__c=TempObjOppLineItem.Id;
                    ObjContractLine.Product_Family__c=TempObjOppLineItem.PricebookEntry.Product2.Family;
                    ObjContractLine.PaymentTerms__c=ObjContract.Account.Payment_Terms__c;
                    ObjContractLine.Line_Description__c=TempObjOppLineItem.Description;
                    //ObjContractLine.UnitofMeasure__c=TempObjOppLineItem.PricebookEntry.Product2.UnitofMeasure__c;
                    //TempObjContractLine01.ContractID__r.StartDate
                    
                    if(TempObjOppLineItem.PricebookEntry.Product2.Family=='Software'){
            
                        ObjContractLine.RecordTypeId=ObjRecordTypeLicense.Id;       
                    }
                    if(TempObjOppLineItem.PricebookEntry.Product2.Family=='Services'){
           
                        //ObjContractLine.Ship_Date__c=TempObjContract.EndDate;

                        ObjContractLine.RecordTypeId=ObjRecordTypeService.Id; 
                        //ObjContractLine.Item_Type__c=TempObjOppLineItem.PricebookEntry.Product2.Item_Type__c;
                        ObjContractLine.Item_Type__c=TempObjOppLineItem.Unit_Of_Measure__c;      
                    }
                    if(TempObjOppLineItem.PricebookEntry.Product2.Family=='Maintenance'){
            
                        ObjContractLine.RecordTypeId=ObjRecordTypeMaintenace.Id;
                        //ObjContractLine.Product_Family__c=PricebookEntry.Product2.Family; 
                   
                    }
                    if(TempObjOppLineItem.PricebookEntry.Product2.Family=='Annual License'){
            
                        ObjContractLine.RecordTypeId=ObjRecordTypeAnnLicense.Id;
                        //ObjContractLine.Product_Family__c=PricebookEntry.Product2.Family; 
                   
                    }
                            /*This section for populating the Record type is requested by Renee . 
                    if LOB contains 'AL' then Recordtype is change to Annual license*/
                    
                    String Str1 =TempObjOppLineItem.PricebookEntry.Product2.LOB__c ;
                    
                    if(Str1.containsIgnoreCase('AL')){
                    
                        ObjContractLine.RecordTypeId=ObjRecordTypeAnnLicense.Id; 
                        ObjContractLine.Product_Family__c='Annual License';
                    
                    }
            
                        if (TempObjOppLineItem.PricebookEntry.Product2.LOB__c<>'Third Party Margin C')//CHG00032631 if product is a third margin product then do not insert the contract line item
                        {
                    LstObjContractLine.add(ObjContractLine);
                        }

                    system.debug('Debugging Product'+ObjContractLine.ProductId__c);
                                    }
                    }

                }
                insert LstObjContractLine;
                
                
                
        List<ContractLine__c> ListConLineUpdt = new List<ContractLine__c>();        
        List<Contract_Revenue__c> LstObjContractRevenue = new List<Contract_Revenue__c>(); 
        boolean VarCheckRevenueCreated=false;   
        List<ContractLine__c> LstContractLine=new List<ContractLine__c>();
        
        //for(Contract TempObjContract02 : ObjContract){
        
        //MapIdContract.Put(ObjContract.Id,ObjContract);
        
        //List<RecordType> LstObjRecType =new <RecordType>();
        Map<String,RecordType> MpRecType=new Map<String,RecordType>();
        
        for(RecordType TempObjRecType : [SELECT Id , Name FROM RecordType]){
            
            MpRecType.put(TempObjRecType.Name,TempObjRecType);    
        }
                
        //ObjRecordTypeService=[SELECT Id , Name FROM RecordType WHERE Name='Services-Product']; 
        // }
        
        for(ContractLine__c TempObjContractLine01 : LstObjContractLine){
            

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
                ObjContRevenue.StartDate__c = TempObjContractLine01.AgreementItemStartDate__c;
                
                //ObjContRevenue.RevenueAmount__c=TempObjContractLine.TotalPrice__c;
                TempObjContractLine01.HasRevenueItemCreated__c=true;
                
                VarCheckRevenueCreated=true;
                ListConLineUpdt.add(TempObjContractLine01);
                LstObjContractRevenue.add(ObjContRevenue);
                //}
            }
            }    
             if(VarCheckRevenueCreated==true){
            system.debug('RevItem');
            insert  LstObjContractRevenue;
            update  ListConLineUpdt;
            //VarCheckRevenueCreated=true;
            }   
                }


        
           if(Trigger.IsUpdate){

                       For(OpportunityLineItem ObjOppLineItem : [SELECT Id, Discount_Amount__c,Discount_Reports__c, Discount_Unit_Price__c , Discount_Percent__c,LOB__c,PricebookEntry.Product2Id,Quantity,TotalPrice,Unit_Of_Measure__c,
                                                  Description,OpportunityId,Total_Retail_Price__c,UnitPrice,Retail_Price__c,Services_Planned_End_Date__c,Services_Planned_Start_Date__c FROM OpportunityLineItem
                                                  WHERE 
                                                  Id IN: trigger.new]){
            
            StrVard.add(string.valueof(ObjOppLineItem.Id));
            system.debug('OPPLISTID'+StrVard);
            SetVarId.add(ObjOppLineItem.OpportunityId);
            //MapOppLinItemIdToCotract.put(ObjOppLineItem.OpporunityId);
            MapIdtoOppLinItem.put(ObjOppLineItem.Id,ObjOppLineItem);            
        }
        
        LstObjContract=[SELECT Id,OpportunityId__c,EndDate,StartDate FROM Contract WHERE OpportunityId__c IN: SetVarId];
        //for()
        
        For(Contract ObjContract : LstObjContract){

            if(MapOppIdToSetContract.get(ObjContract.OpportunityId__c)==null){
                TempObjContract.clear();
                TempObjContract.add(ObjContract);
                MapOppIdToSetContract.put(ObjContract.OpportunityId__c,TempObjContract);
            }
            else{

                TempObjContract.clear();
                TempObjContract.addall(MapOppIdToSetContract.get(ObjContract.OpportunityId__c));
                TempObjContract.add(ObjContract);
                MapOppIdToSetContract.put(ObjContract.OpportunityId__c,TempObjContract);
    
            }
            //MapIdToSetId.put();    
        }    
               LstTempObjContractLine2=[SELECT Id,OpportunityLineItemId__c FROM ContractLine__c 
                                        WHERE OpportunityLineItemId__c IN: StrVard];
               System.debug('ContractLineItemList'+LstTempObjContractLine2);
                   for(ContractLine__c ObjContractLine : LstTempObjContractLine2){
                   
                        ObjContractLine.Discount_Amount__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Discount_Amount__c;
                        ObjContractLine.LOB__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).LOB__c;
                    
                        ObjContractLine.ProductId__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).PricebookEntry.Product2Id;
                        // Decimal TemQuantity;
                        //TemQuantity=OpportunityLineItem.Quantity;
                        ObjContractLine.Quantity__c= MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Quantity;
                        ObjContractLine.TotalPrice__c= MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).TotalPrice;
                        ObjContractLine.Total_Retail_Price__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Total_Retail_Price__c;
                        if (MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Retail_Price__c != null & MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Discount_Unit_Price__c != null && MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Discount_Unit_Price__c <> 0)
                        {
                            ObjContractLine.Discount_Percent__c = (MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Discount_Unit_Price__c / MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Retail_Price__c) *100;
                        }
                        else 
                        {
                            ObjContractLine.Discount_Percent__c =  MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Discount_Percent__c;  
                        }
                        ObjContractLine.UnitPrice__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).UnitPrice;
                        
                        ObjContractLine.ItemPrice__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Retail_Price__c;
                        //ObjContractLine.UnitofMeasure__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).PricebookEntry.Product2.UnitofMeasure__c;
                        ObjContractLine.ServicesEndDate__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Services_Planned_End_Date__c;
                        ObjContractLine.ServicesStartDate__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Services_Planned_Start_Date__c;
                        //AIM; Sales Cloud ; Only Sync Changes for Fixed Fee and T&M
                        if (MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Unit_Of_Measure__c  != null && (MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Unit_Of_Measure__c == 'Time & Materials' || MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Unit_Of_Measure__c == 'Fixed Fee' ) )
                        {
                            ObjContractLine.Item_Type__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Unit_Of_Measure__c;
                        }
                        ObjContractLine.Line_Description__c=MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).Description;
                        if (MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).LOB__c<>'Third Party Margin C')//CHG00032631 if product is a third margin product then do not update the contract line item
                        {
                            LstObjContractLine.add(ObjContractLine);
                        }
                        system.debug('Debugging Product'+ObjContractLine.ProductId__c+MapIdtoOppLinItem.get(ObjContractLine.OpportunityLineItemId__c).PricebookEntry.Product2Id);
                         
                    }
                    
                    try{ 
                        update LstObjContractLine;
                        
                    }


                    catch(dmlexception e){
                        
                        String errorMessage = e.getMessage();
                           if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                           //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
                               //String s2 = errorMessage.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                               trigger.new[0].adderror('The Opportunity line item cannot be updated. Possible reason : contract corresponding to the opportunity is already sent to SAP ');
                           }
                        //trigger.new[0].adderror('The Opportunity line item cannot be updated due to certain reasons e.g. The contract associated with the opportunity is already sent to SAP');
                    }   
                          }

                          
                          
                   if(trigger.IsDelete){
                   
                       for(OpportunityLineItem ObjOppLinItem : [SELECT Id FROM OpportunityLineItem WHERE Id IN : trigger.Old]){
                       
                           StrVard.add(string.valueof(ObjOppLinItem.Id));    
                       }
                       LIST <ContractLine__c> LstConLineDel = new LIST <ContractLine__c>();
                       
                       for(ContractLine__c TempObjConLine : [SELECT Id FROM ContractLine__c WHERE OpportunityLineItemId__c IN : StrVard]){
                       
                           LstConLineDel.add(TempObjConLine);
                       }
                       Delete LstConLineDel;
                   }
        
    }
    }
    
    catch (exception e){
        
        
   }    
   }

}