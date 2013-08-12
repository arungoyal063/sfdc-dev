/*********************************************************************************************************************
** Module Name   : InsertDispatchDetails
** Description   : Processes Dispatch Details to map Dispatch Records with correct Quota
** Throws        : N/A
** Calls         : N/A
** Test Class    : TestInsertDispatchDetails
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author      WO#         Description of Action
** 1.0      08/01/2013     KL        XXXX            Initial Version
*******************************************************************************************************************/
public with sharing class InsertDispatchDetails {
	
  
  
    /**
	*  Process Dispatch Records and map them to the correct Quota 
	*
	**/
    public static void process(List<Dispatch_Sale__c> dsList){
       
       	//Get the custom settings details from
       	Dispatch_Sale_Quota__c dsq = Dispatch_Sale_Quota__c.getValues('Dispatch Sales Quota');
       	Map<String,String> dsqMap = new Map<String,String>();
       	if (dsq != null) {
       		//Get Each value of the attribute and add it to the list
       		String[] cmc = dsq.Concrete_Mixes__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.PFR_Other_Aggregates__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.PFR_Stone__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Processed_Gravel__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Processed_Mixed_Products__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Processed_Sand__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Recycled_Concrete_Products__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Rowe_Gravel__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Rowe_Recycled_Concrete__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Semi_Processed_Mixed_Products__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Semi_Processed_Other__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Semi_Processed_Sand__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.TCS__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Unprocessed_Materials__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		cmc = dsq.Waste_Products__c.split(',');
       		dsqMap.put(cmc[0],cmc[1]);
       		
       		
       	} else {
       		//throw Exception('No Custom Settings found for Dispatch Sale Quota');
       	}
       	
         Map <String,Dispatch_Sale__c> accountNumberMap = new Map<String,Dispatch_Sale__c>();
         for (Dispatch_Sale__c ds : dsList){
            accountNumberMap.put(ds.Customer_Number__c,ds);
         }
         
         Product2 p;
         Map <Id, Account> accountMap = new Map<Id,Account>([SELECT a.id,a.accountnumber,a.Account_Num__c from Account a where a.Account_Num__c in :accountNumberMap.keySet()]);
         Map<String,Account> accountMapByCustomerNumber = new Map<String,Account>();
         
         
         for (Id id : accountMap.keySet()){
            accountMapByCustomerNumber.put(accountMap.get(id).Account_Num__c,accountMap.get(id));
            
         }
         
     
         
         Map<Id,Quota__c> quotaMap =  new Map<Id,Quota__c>([select id,Name,Quota_Family__c,plant__c,month__c,OwnerId from Quota__c order by month__c desc LIMIT 20000]);
         Map<String,Quota__c> quotaNameMap = new Map<String,Quota__c>();
       
       
         for (Id id: quotaMap.keySet()){
          
            System.debug(quotaMap.get(id).plant__c);
          
           
           String ownerid = quotaMap.get(id).OwnerId;
           
           String quotestr =   ownerid + '-' 
            						+ quotaMap.get(id).plant__c + '-' 
            						+ (quotaMap.get(id).month__c.year()) + ''
            						+ quotaMap.get(id).month__c.month() 
            						+ '01' + 
            						'-' + quotaMap.get(id).Quota_Family__c;  
            						
             System.debug('quotestr ---->' + quotestr);
            quotaNameMap.put(quotestr,quotaMap.get(id));
         }
         
         List<Id> productList = new List<Id>();
         for (Dispatch_Sale__c ds : dsList){
            productList.add(ds.Product__c);
         }
         
         Map<Id,Product2> productMap =  new Map<Id,Product2>([SELECT Id,Family,name,Product_Division__c from Product2 where id in :productList]);
         List<String> jobKeyDSList = new List<String>();
         for (Dispatch_Sale__c ds : dsList){
            Account a = accountMapByCustomerNumber.get(ds.Customer_Number__c);
            ds.Account__c = a.id; 
            jobKeyDSList.add(a.Account_Num__c + '-' + accountNumberMap.get(ds.Customer_Number__c).job__c);  
          }
          
         Map<ID,Opportunity>     OpprMap = new Map<Id,Opportunity>([SELECT o.id,o.Job_Key__c from Opportunity o where o.Job_Key__c in :jobKeyDSList]);
         Map<String,Opportunity>  opprJobKeyMap = new Map<String,Opportunity>();
         for (Id id: OpprMap.keySet()){
            opprJobKeyMap.put(OpprMap.get(id).Job_Key__c,OpprMap.get(id));
         }  
              
         Map<Id,User> userMap = new Map<Id,User>([Select u.Name, u.LastName, u.FirstName From User u]);
        
        List<Account> upsertAccountList = new List<Account>();
        for (Dispatch_Sale__c ds: dsList){
            System.debug('ds.source_system__c -->' + ds.source_system__c);
            System.debug('ds.Customer_Number__c --> ' + ds.Customer_Number__c);
            System.debug('ds.Customer_Number__c --> ' + ds.Account_Number__c);
            System.debug('ds.ds.Job__c --> ' + ds.Job__c);
            System.debug('ds.Delivery_Date__c ==>' + ds.Delivery_Date__c);
            System.debug('ds.Product__c ==>' + ds.Product__c);
            System.debug('ds.Product_Class__c ==>' + ds.Product_Class__c);
             System.debug('ds.Product_Name__c ==>' + ds.Product_Name__c);
            System.debug('ds.Plant__c ==>' + ds.Plant__c);
            System.debug('ds.Owner ==>' + ds.Dispatch_Owner__c);
            if ('Dispatch'.equals(ds.source_system__c)){
               
                Account a = accountMapByCustomerNumber.get(ds.Customer_Number__c);
                
                ds.Account__c = a.id;
                String jobKey = a.Account_Num__c + '-' + accountNumberMap.get(ds.Customer_Number__c).Job__c;
                try {
                    ds.Opportunity__c = opprJobKeyMap.get(jobKey).id;   
                }  catch (Nullpointerexception npe){
                    //Okay to get null pointer exception
                }
                
                    
                
            
                //When Dispatch Sale is inserted, evaluate whether it is a Concrete product or Aggregate product.  
                //If Concrete, update Dispatch_Sale.Last_Concrete_Sale_Date__c with value from DelivDate.  
                //If Aggregate, update Last_Aggregate_Sale_Date__c with value from DelivDate.
                boolean isAggregate = true; 
                String qf = '';
                
                p =  productMap.get(ds.Product__c);
                if ( p != null){
                    
                                   
                     if (p.Family.contains('Concrete')) {
                        ds.Last_Concrete_Sale_Date__c = ds.Delivery_Date__c;
                        isAggregate = false;
                     } else  {
                        ds.Last_Aggregate_Sale_Date__c = ds.Delivery_Date__c;
                        
                     }
                    a.Last_Concrete_Sale_Date__c = ds.Last_Concrete_Sale_Date__c;
                    a.Last_Aggregate_Sale_Date__c = ds.Last_Aggregate_Sale_Date__c;
                    upsertAccountList.add(a);
                
                 //a) Any Dispatch Sale with a DelivDate prior to 1/1/2012 should be associated with the Owner’s Quota 
                 //dated 12/31/2011, for the respective record type.  For instance, if the Dispatch Sale record is for 
                 //Concrete, and the date is 11/25/2010, and the owner is Sal Bianco, the Sale should be associated with 
                 //the Quota owned by Sal Bianco, where the record type name is “Concrete”, and the date is 12/31/2011. 
                 // We do not really care about Dispatch Sales prior to 2012, therefore, they can be attached to a single 
                 //“default” quota.
                 
                    //b) Aggregate Sales will need to be matched with the proper Quota based on Product.  
                //See Product lookup table below EXCEPT FOR DISPATCH SALES DATED PRIOR TO JAN 1, 2012, 
                //which can be associated with a single Quota “Aggregate Pre2012”.
                    User u = userMap.get(ds.Dispatch_Owner__c);
                    if (u != null) {
                        String Quotastring;
                        
                        String monthYear = '';
                        System.debug('ds.Delivery_Date__c.month() ----> ' + ds.Delivery_Date__c.month());
                        System.debug('ds.Delivery_Date__c.year() ----> ' + ds.Delivery_Date__c.year());
                        System.debug('ds.Product_Name__c ----> ' + ds.Product_Name__c);
                        monthYear = (ds.Delivery_Date__c.year()) + '' + ds.Delivery_Date__c.month() +  '01';
                        String productName = dsqMap.get(ds.Product_Name__c);
                        if (null == productName || ''.equals(productName)) {
                        	if (isAggregate){
                        		//Aggregate Quota
                        		productName = '	Concrete';
                        	} else {
                        		//Concrete Quota
                        		productName = '	Misc';
                        	}
                        }
                        
                        Quotastring = u.id + '-' + ds.Plant__c + '-' + monthYear + '-' + productName;
                       
                        System.debug('Quotastring ---> '  + Quotastring);
                        System.debug('p.name ---> ' + p.name);
                        Quota__c QuotaList = quotaNameMap.get(Quotastring);
                        
                        if (QuotaList != null) {
                            ds.Quota__c = QuotaList.id;
                        } else {
                            Quotastring = '005700000013suNAAQ' + '-' + ds.Plant__c + '-' + monthYear + '-' + productName;
                            System.debug('Quotastring ---> '  + Quotastring);    
                            QuotaList = quotaNameMap.get(Quotastring);
                            if (QuotaList != null) {
                                ds.Quota__c = QuotaList.id;
                            } 
                        } 
                        
                    }   
                 } else {
                    ds.addError('Product not found for ' + ds.Product__c  + ' Customer Number ' 
                    + ds.Customer_Number__c);
                }
            } 
        }
        
        update upsertAccountList;
        
    }
    
   
	

}