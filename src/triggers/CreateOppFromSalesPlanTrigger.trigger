/*********************************************************************************
** Class Name : CreateOppFromSalesPlanTrigger
** Description : 1- Trigger to Create New Opportunity on Sales Plan Insert
                   
** Throws : NA
** Calls : NA
** Test Class : CreateOppFromSalesPlanTriggerTest   
** 
** Organization : Rainmaker Associates LLC
**
** Revision History:-
** Version Date             Author  WO#         Description of Action
** 1.0     2013-01-17       Algo    Weloclaize  Initial Version
*********************************************************************************/
trigger CreateOppFromSalesPlanTrigger on Sales_Plan__c (after insert, after update) {
    
    Set<String> accountIds = new Set<String>();
    List<Opportunity> oppList = new List<Opportunity>();
         
    for(Sales_Plan__c sp :Trigger.New) {
        if(sp.Account__c == null) {
            sp.addError('Account does not exist for the SalesPlan!');   
        } else if(sp.Year_Ending__c == null) {
            sp.addError('Year Ending Date does not Exist on Sales Plan, Please fill an Year Ending Date then try again!');
        } else {
            accountIds.add(sp.Account__c);    
        }
    }
    
    Map<String,Account> accountMap = new Map<String,Account>([SELECT 
                                            New_Business_Account__c, 
                                            Vertical_speciality__c,
                                            Type, 
                                            Systems_Tools__c, 
                                            Project_Type__c, 
                                            GRM__c, EPD__c, 
                                            Description, 
                                            Content_Types__c, 
                                            Client_Division__c, 
                                            Name,
                                            Technical_Services__c,
                                            South_East_Asian__c,
                                            Other_Nordic__c,
                                            Other_Europe__c,
                                            Other_Asia__c,
                                            Middle_Eastern__c,
                                            Latin_American_Caribbean__c,
                                            Indian_Subcontinent__c,
                                            FIGS__c,
                                            English_variants__c,
                                            Eastern_European__c, 
                                            Australasia_Pacific_Islands__c,
                                            African_Language__c,
                                            DDNFS__c,
                                            Central_Asian__c,
                                            Canadian__c,
                                            CCJK_4__c,
                                            Industry__c  
                                    FROM 
                                            Account 
                                    WHERE 
                                            Id IN :accountIds]);
                                            
   if(Trigger.isUpdate) { 
    list<Opportunity> oppListtoUpdate = new list<Opportunity>();                                       
       for(Sales_Plan__c sp :Trigger.New) {
           Account accountTobeCopy;
           
           if(sp.Account__c != null && sp.Year_Ending__c != null && (sp.Status__c != 'Submitted to Manager' && sp.Status__c != 'Approved')) {
               accountTobeCopy = accountMap.get(sp.Account__c);
               
               if(!accountTobeCopy.New_Business_Account__c) { 
                    if(Trigger.oldMap.get(sp.Id).January__c != sp.January__c){
                        Opportunity getOpportunity = getOpportunities.get('Jan');
                        if(getOpportunity != null){
	                        getOpportunity.Amount = sp.January__c;
	                        oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.January__c != null && String.valueOf(sp.January__c) != ''  && sp.January__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).January__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).January__c) == '') ) {           
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Jan',sp.January__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }          
							}
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).February__c != sp.February__c){
                        Opportunity getOpportunity = getOpportunities.get('Feb');
                        if(getOpportunity != null){
	                        getOpportunity.Amount = sp.February__c;
	                        oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.February__c != null && String.valueOf(sp.February__c) != ''  && sp.February__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).February__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).February__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Feb',sp.February__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }         
							}
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).March__c != sp.March__c ){
                        Opportunity getOpportunity = getOpportunities.get('Mar');
                        if(getOpportunity != null){
                    		getOpportunity.Amount = sp.March__c ;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.March__c != null && String.valueOf(sp.March__c) != ''  && sp.March__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).March__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).March__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Mar',sp.March__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }        
							}
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).April__c != sp.April__c ){
                        Opportunity getOpportunity = getOpportunities.get('Apr');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.April__c ;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.April__c != null && String.valueOf(sp.April__c) != ''  && sp.April__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).April__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).April__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Apr',sp.April__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							}
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).May__c != sp.May__c){
                        Opportunity getOpportunity = getOpportunities.get('May');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.May__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.May__c != null && String.valueOf(sp.May__c) != ''  && sp.May__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).May__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).May__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'May',sp.May__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							} 
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).June__c != sp.June__c){
                        Opportunity getOpportunity = getOpportunities.get('Jun');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.June__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.June__c != null && String.valueOf(sp.June__c) != ''  && sp.June__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).June__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).June__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Jun',sp.June__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							} 
                        }
                        
                    }
                    if(Trigger.oldMap.get(sp.Id).July__c != sp.July__c){
                        Opportunity getOpportunity = getOpportunities.get('Jul');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.July__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.July__c != null && String.valueOf(sp.July__c) != ''  && sp.July__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).July__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).July__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Jul',sp.July__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							} 
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).August__c != sp.August__c){
                        Opportunity getOpportunity = getOpportunities.get('Aug');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.August__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.August__c != null && String.valueOf(sp.August__c) != ''  && sp.August__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).August__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).August__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Aug',sp.August__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							} 
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).September__c != sp.September__c){
                        Opportunity getOpportunity = getOpportunities.get('Sep');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.September__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.September__c != null && String.valueOf(sp.September__c) != ''  && sp.September__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).September__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).September__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Sep',sp.September__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							}
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).October__c != sp.October__c){
                        Opportunity getOpportunity = getOpportunities.get('Oct');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.October__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.October__c != null && String.valueOf(sp.October__c) != ''  && sp.October__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).October__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).October__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Oct',sp.October__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							} 
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).November__c != sp.November__c){
                        Opportunity getOpportunity = getOpportunities.get('Nov');
                        if(getOpportunity != null){
                        	getOpportunity.Amount = sp.November__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.November__c != null && String.valueOf(sp.November__c) != ''  && sp.November__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).November__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).November__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Nov',sp.November__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							}
                        }
                    }
                    if(Trigger.oldMap.get(sp.Id).December__c != sp.December__c){
                        Opportunity getOpportunity = getOpportunities.get('Dec');
                        if(getOpportunity != null){
                    		getOpportunity.Amount = sp.December__c;
                        	oppListtoUpdate.add(getOpportunity);
                        }else{
                        	if(sp.December__c != null && String.valueOf(sp.December__c) != ''  && sp.December__c > 0 && (String.valueOf(Trigger.oldMap.get(sp.Id).December__c) == null || String.valueOf(Trigger.oldMap.get(sp.Id).December__c) == '')) {
							   Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Dec',sp.December__c);
							   if(spOpportunity != null) {
								   oppList.add(spOpportunity); 
							   }             
							}
                        }
                    }          
               }
           } 
       }
       if(!oppListtoUpdate.isEmpty()) {
           try{
                update oppListtoUpdate;
           }catch(DMLException e){
           		Trigger.New[0].addError(e.getDMLmessage(0));   
           }catch(Exception e) {
               System.debug('Error ::' + e);
               Trigger.new[0].addError(e.getMessage());
           }
       }    
   }
   //On insert
   if(Trigger.isInsert){
        for(Sales_Plan__c sp :Trigger.New) {
           Account accountTobeCopy;
           
           if(sp.Account__c != null && sp.Year_Ending__c != null) {
               accountTobeCopy = accountMap.get(sp.Account__c);
               // if Account is not New_Business_Account__c  create Opportunity List
               if(!accountTobeCopy.New_Business_Account__c) {           
                   if(sp.January__c != null && String.valueOf(sp.January__c) != ''  && sp.January__c > 0) {           
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Jan',sp.January__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }          
                   }   
                   if(sp.February__c != null && String.valueOf(sp.February__c) != ''  && sp.February__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Feb',sp.February__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }         
                   }    
                   if(sp.March__c != null && String.valueOf(sp.March__c) != ''  && sp.March__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Mar',sp.March__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }        
                   }    
                   if(sp.April__c != null && String.valueOf(sp.April__c) != ''  && sp.April__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Apr',sp.April__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   } 
                   if(sp.May__c != null && String.valueOf(sp.May__c) != ''  && sp.May__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'May',sp.May__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }   
                   if(sp.June__c != null && String.valueOf(sp.June__c) != ''  && sp.June__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Jun',sp.June__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }   
                   if(sp.July__c != null && String.valueOf(sp.July__c) != ''  && sp.July__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Jul',sp.July__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }   
                   if(sp.August__c != null && String.valueOf(sp.August__c) != ''  && sp.August__c > 0 ){
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Aug',sp.August__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }   
                   if(sp.September__c != null && String.valueOf(sp.September__c) != ''  && sp.September__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Sep',sp.September__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }   
                   if(sp.October__c != null && String.valueOf(sp.October__c) != ''  && sp.October__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Oct',sp.October__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }   
                   if(sp.November__c != null && String.valueOf(sp.November__c) != ''  && sp.November__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Nov',sp.November__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }   
                   if(sp.December__c != null && String.valueOf(sp.December__c) != ''  && sp.December__c > 0 ) {
                       Opportunity spOpportunity =  SalesPlanUtil.createOpportunity(sp, accountTobeCopy,'Dec',sp.December__c);
                       if(spOpportunity != null) {
                           oppList.add(spOpportunity); 
                       }             
                   }
               }           
           } 
       } 
   }
   
   if(!oppList.isEmpty()) {
       try{
           insert oppList;
       } catch(Exception e) {
           System.debug('Error ::' + e);
           Trigger.new[0].addError(e);
       }
   }     
      
   private map<String,Opportunity> getOpportunities{   
    get{
        if(getOpportunities == null){
            System.debug([SELECT Name, Amount FROM Opportunity WHERE Id IN:Trigger.newMap.keyset()]+'=============='+Trigger.newMap.keyset());
            getOpportunities = new map<String,Opportunity>();
            for(Opportunity opp:[SELECT Name, Amount FROM Opportunity WHERE sales_plan__c IN:Trigger.newMap.keyset()]){
                System.debug(getmonthName(opp.Name)+'---------------'+opp);
                String monthName = getmonthName(opp.Name);
                if(monthName != null){
                    getOpportunities.put(monthName,opp);
                }
            }   
        }
        return getOpportunities;
    }private set;
   }
   private String getmonthName(String oppName){
       if(oppName.contains('Jan')){
           return 'Jan';
       }
       if(oppName.contains('Feb')){
           return 'Feb';
       }
       if(oppName.contains('Mar')){
           return 'Mar';
       }
       if(oppName.contains('Apr')){
           return 'Apr';
       }
       if(oppName.contains('May')){
           return 'May';
       }
       if(oppName.contains('Jun')){
           return 'Jun';
       }
       if(oppName.contains('Jul')){
           return 'Jul';
       }
       if(oppName.contains('Aug')){
           return 'Aug';
       }
       if(oppName.contains('Sep')){
           return 'Sep';
       }
       if(oppName.contains('Oct')){
           return 'Oct';
       }
       if(oppName.contains('Nov')){
           return 'Nov';
       }
       if(oppName.contains('Dec')){
           return 'Dec';
       }       
       return null;
   }                                       

}