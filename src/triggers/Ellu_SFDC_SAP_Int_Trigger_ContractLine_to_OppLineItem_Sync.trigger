trigger Ellu_SFDC_SAP_Int_Trigger_ContractLine_to_OppLineItem_Sync on ContractLine__c (after update) {
// AIM; 5/8/2013; Sales Cloud- Updated to prevent updating of Item Type where item type <> T&M or Fixed Fee
    Public Set<Id> SetVarOppLineIds = new Set<Id>();
    Public Map<Id,ContractLine__c> MapContLineItem= new Map<Id,ContractLine__c>();
    Public List<OpportunityLineItem> LstOppLineItem=new List<OpportunityLineItem>();
    Public List<OpportunityLineItem> LstOppLineItemForUpdate2 = new List<OpportunityLineItem>();
    
    if(!Ellu_SFDC_SAP_PrTrigLoopCreateContCls.getBoolVarPrTrigLoopForCreateContract ()){
    
    if(!Ellu_SFDC_SAP_PreventInfiniteTrigLoop.getBoolVarPreventtrggFirLoopMethod() ){
    
        Ellu_SFDC_SAP_PreventInfiniteTrigLoop.setBoolVarPreventtrggFirLoopMethod() ; 
        try{   
        for(ContractLine__c ObjContractLine : [SELECT Id,Discount_Percent__c,LOB__c,ProductId__c,Quantity__c,TotalPrice__c,
                                               UnitPrice__c,UnitofMeasure__c , ItemPrice__c ,OpportunityLineItemId__c 
                                               ,Line_Description__c,ServicesEndDate__c,ServicesStartDate__c , Item_Type__c FROM ContractLine__c WHERE Id IN : trigger.new]){
    
            SetVarOppLineIds.add(Id.valueOf(ObjContractLine.OpportunityLineItemId__c));
            //LstContLineItem.add(ObjContractLine); 
            MapContLineItem.put(Id.valueOf(ObjContractLine.OpportunityLineItemId__c),ObjContractLine);       
        } 
        
        LstOppLineItem=[SELECT Id,Product_Type__c FROM OpportunityLineItem WHERE Id IN: SetVarOppLineIds]; 
        
        for( OpportunityLineItem ObjOppLineItem : LstOppLineItem){
        
            //ObjOppLineItem.Discount_Amount__c=MapContLineItem.get(ObjOppLineItem.Id).Discount_Amount__c;
            ObjOppLineItem.Discount_Percent__c=MapContLineItem.get(ObjOppLineItem.Id).Discount_Percent__c;    
            ObjOppLineItem.LOB__c=MapContLineItem.get(ObjOppLineItem.Id).LOB__c;
            //ObjOppLineItem.PricebookEntry.Product2Id=MapContLineItem.get(ObjOppLineItem.Id).ProductId__c;
            ObjOppLineItem.Quantity=MapContLineItem.get(ObjOppLineItem.Id).Quantity__c;
            //ObjOppLineItem.TotalPrice=MapContLineItem.get(ObjOppLineItem.Id).TotalPrice__c;
            //ObjOppLineItem.Total_Retail_Price__c=MapContLineItem.get(ObjOppLineItem.Id).Total_Retail_Price__c;
            ObjOppLineItem.UnitPrice=MapContLineItem.get(ObjOppLineItem.Id).UnitPrice__c;
            ObjOppLineItem.Retail_Price__c=MapContLineItem.get(ObjOppLineItem.Id).ItemPrice__c;
            
            //ObjOppLineItem.PricebookEntry.Product2.UnitofMeasure__c=MapContLineItem.get(ObjOppLineItem.Id).UnitofMeasure__c;
            ObjOppLineItem.Services_Planned_End_Date__c=MapContLineItem.get(ObjOppLineItem.Id).ServicesEndDate__c;
            
            ObjOppLineItem.Services_Planned_Start_Date__c=MapContLineItem.get(ObjOppLineItem.Id).ServicesStartDate__c;
            // AIM; 5/8/2013; Sales Cloud- Updated to prevent updating of Item Type to Opportunity if not services
             if (MapContLineItem.get(ObjOppLineItem.Id).Item_Type__c  != null && (MapContLineItem.get(ObjOppLineItem.Id).Item_Type__c == 'Time & Materials' || MapContLineItem.get(ObjOppLineItem.Id).Item_Type__c == 'Fixed Fee' ) )
            {
            	if ((ObjOppLineItem.Product_Type__c != null && ObjOppLineItem.Product_Type__c != 'Managed Services') || ObjOppLineItem.Product_Type__c == null)
            		ObjOppLineItem.Unit_Of_Measure__c=MapContLineItem.get(ObjOppLineItem.Id).Item_Type__c;
            }
            ObjOppLineItem.Description=MapContLineItem.get(ObjOppLineItem.Id).Line_Description__c;
            LstOppLineItemForUpdate2.add(ObjOppLineItem);
        }
        
        update  LstOppLineItemForUpdate2;   
        }
        catch(exception e){
        }
    
    }
    }
}