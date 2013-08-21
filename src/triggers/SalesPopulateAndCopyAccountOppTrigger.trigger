/*********************************************************************************
** Class Name : SalesPopulateAndCopyAccountOppTrigger
** Description : 1- Trigger to populate sales plan into Opportunity.
                 2- Trigger to copy the fields from Account to Opportunity level>>    
** Throws : NA
** Calls : NA
** Test Class : SPAndCopyAccountOppTriggerTest
** 
** Organization : Rainmaker Associates LLC
**
** Revision History:-
** Version Date             Author  WO#   Description of Action
** 1.0         2012-12-21   Algo    Weloclaize Initial Version
*********************************************************************************/

trigger SalesPopulateAndCopyAccountOppTrigger on Opportunity (after insert,after update,after delete) {
    // calling runOnce function to update only one time
     if(TriggerRunOnce.runOnce()){
        final list<Integer> YEAR_MONTHS = new list<Integer>{1,2,3,4,5,6,7,8,9,10,11,12};
         map<ID,map<Integer,decimal>> getOpportunity = new map<ID,map<Integer,decimal>>();
         list<Opportunity> listOfOpp = new list<Opportunity>();
         set<Id> salesPlanIds = new set<Id>();
         if(Trigger.isUpdate || Trigger.isDelete){        
             for(Opportunity opp :Trigger.old){
                salesPlanIds.add(opp.sales_plan__c);
             } 
         }
         if(Trigger.isUpdate || Trigger.isInsert){       
             for(Opportunity opp :Trigger.new){
                salesPlanIds.add(opp.sales_plan__c);
             }
         }
         
         
         for(AggregateResult ar:[Select sales_plan__c,Sum(Amount) amount,CALENDAR_MONTH(CloseDate) month From Opportunity where CALENDAR_MONTH(CloseDate) IN:YEAR_MONTHS AND sales_plan__c IN:salesPlanIds group by sales_plan__c ,CALENDAR_MONTH(CloseDate)]){
             map<Integer,decimal> monthAmountMap;
             if(getOpportunity.containsKey((ID)ar.get('sales_plan__c'))) {
                 monthAmountMap = getOpportunity.get((ID)ar.get('sales_plan__c'));          
             } else {
                 monthAmountMap = new map<Integer,decimal>();   
             }
             monthAmountMap.put(Integer.valueOf(ar.get('month')),double.valueOf(ar.get('amount')));
             getOpportunity.put((ID)ar.get('sales_plan__c'),monthAmountMap);            
         }
        
         
         map<Id,sales_plan__c> objSalesPlans = new map<Id,sales_plan__c>([SELECT September__c, October__c, November__c, May__c, March__c, 
                                                                          June__c, July__c, January__c, February__c, December__c, 
                                                                          August__c, April__c,Status__c From Sales_Plan__c WHERE Id IN:salesPlanIds]);
         double amountToBeUpdate; 
         list<Sales_Plan__c> toUpdateSalesPlan = new list<Sales_Plan__c>();
         
         for(ID spId :salesPlanIds) { 
            if(getOpportunity.containsKey(spId)) {  
                map<Integer,decimal> monthAmountMap =  getOpportunity.get(spId);
                Sales_Plan__c objSalesPlan = objSalesPlans.get(spId);
                amountToBeUpdate = 0.0;
                if(objSalesPlan != null) {
                    if( /*TriggerRunOnce.runOnce() && */objSalesPlan.Status__c != 'Approved' && objSalesPlan.Status__c != 'Submitted to Manager'){//Rejected - Updates Required'){
                        if(monthAmountMap.containsKey(1)){      
                            objSalesPlan.January__c = monthAmountMap.get(1);
                        } 
                        if(monthAmountMap.containsKey(2)){      
                            objSalesPlan.February__c = monthAmountMap.get(2);
                        } 
                        if(monthAmountMap.containsKey(3)){      
                            objSalesPlan.March__c = monthAmountMap.get(3);
                            system.debug('objSalesPlan.March__c'+objSalesPlan.March__c);
                        } 
                        if(monthAmountMap.containsKey(4)){      
                            objSalesPlan.April__c = monthAmountMap.get(4);
                        } 
                        if(monthAmountMap.containsKey(5)){      
                            objSalesPlan.May__c = monthAmountMap.get(5);
                        } 
                        if(monthAmountMap.containsKey(6)){      
                            objSalesPlan.June__c = monthAmountMap.get(6);
                        } 
                        if(monthAmountMap.containsKey(7)){      
                            objSalesPlan.July__c = monthAmountMap.get(7);
                        } 
                        if(monthAmountMap.containsKey(8)){      
                            objSalesPlan.August__c = monthAmountMap.get(8);
                        } 
                         if(monthAmountMap.containsKey(9)){      
                            objSalesPlan.September__c = monthAmountMap.get(9);
                        } 
                        if(monthAmountMap.containsKey(10)){      
                            objSalesPlan.October__c = monthAmountMap.get(10);
                        } 
                        if(monthAmountMap.containsKey(11)){      
                            objSalesPlan.November__c = monthAmountMap.get(11);
                        } 
                        if(monthAmountMap.containsKey(12)){      
                            objSalesPlan.December__c = monthAmountMap.get(12);
                        } 
                    }
                }
                if(objSalesPlan != null) {
                 system.debug('objSalesPlan'+objSalesPlan);
                    toUpdateSalesPlan.add(objSalesPlan); 
                }
            }           
         }
         if(toUpdateSalesPlan != null && !toUpdateSalesPlan.isEmpty() ) {
            update toUpdateSalesPlan;
            system.debug('toUpdateSalesPlan'+toUpdateSalesPlan);
         }
        /*if(Trigger.isBefore && Trigger.isInsert){
            set<Id> accountIds = new set<Id>(); 
            set<Id> salesPlanIds = new set<Id>();
            for(Opportunity opp:Trigger.new){
                //accountIds.add(opp.AccountId);
                salesPlanIds.add(opp.Sales_Plan__c);
            }
            //To get associated Sales plan
            map<Id,Sales_Plan__c> salesPlanFieldsToPopulate = new map<Id,Sales_Plan__c>([SELECT Account__c,Year_Ending__c,Type__c, Sales_Plan_Total__c, CreatedById 
                                                                         FROM Sales_Plan__c WHERE Id IN:salesPlanIds]);
            for(Sales_Plan__c sp:salesPlanFieldsToPopulate.values()){
                accountIds.add(sp.Account__c);
            }
            //To get associated Account with Opp        
            map<Id,Account> accountFieldsToBeCopy = new map<Id,Account>([SELECT Vertical_speciality__c,Type, Systems_Tools__c, Project_Type__c, GRM__c, EPD__c, Description, Content_Types__c, Client_Division__c, African_Language__c 
                                                                         FROM Account WHERE Id IN:accountIds]);
            //Trigger to copy the fields from Account to Opportunity level
            for(Opportunity opp:Trigger.new){
                Account accFieldsForCopy = accountFieldsToBeCopy.get(salesPlanFieldsToPopulate.get(opp.Sales_Plan__c).Account__c);//accountFieldsToBeCopy.get(opp.AccountId);
                System.debug('>>>>>>>>>>>>>'+accFieldsForCopy);
                if(accFieldsForCopy != null){
                    opp.AccountId = accFieldsForCopy.Id;
                                    
                    opp.Description = accFieldsForCopy.Description;
                    opp.GRM__c = accFieldsForCopy.GRM__c;
                    opp.EPD__c = accFieldsForCopy.EPD__c;
                    opp.Project_Type__c = accFieldsForCopy.Project_Type__c;
                    opp.Systems_Tools__c = accFieldsForCopy.Systems_Tools__c;
                    opp.Content_Types__c = accFieldsForCopy.Content_Types__c;
                    opp.Client_Division__c = accFieldsForCopy.Client_Division__c;
                    opp.Vertical_speciality__c = accFieldsForCopy.Vertical_speciality__c;
                    //opp.Language_List__c = accFieldsForCopy.Language_List__c;
                }
                Sales_Plan__c objSalesPlanFieldsToPopulate = salesPlanFieldsToPopulate.get(opp.Sales_Plan__c);
                if(objSalesPlanFieldsToPopulate != null){
                    opp.CloseDate = objSalesPlanFieldsToPopulate.Year_Ending__c;
                    opp.OwnerId = objSalesPlanFieldsToPopulate.CreatedById;
                    opp.Type = objSalesPlanFieldsToPopulate.Type__c; 
                }
            }
        }*/    
    }     
}