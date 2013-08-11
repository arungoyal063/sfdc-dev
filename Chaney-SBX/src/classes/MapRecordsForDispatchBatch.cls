public with sharing class MapRecordsForDispatchBatch {
    public static Map<Integer,String> monthMap = new Map<Integer,String>();
    public static Map<String, String> plantShortNames = new Map<String,String>();
    public static List <String> userOwnerForPlants = new List<String>();
    public static Map<String,String> quoteFamily = new Map<String,String>();
    static {
         monthMap.put(1,'Jan');
         monthMap.put(2,'Feb');
         monthMap.put(3,'Mar');
         monthMap.put(4,'Apr');
         monthMap.put(5,'May');
         monthMap.put(6,'Jun');
         monthMap.put(7,'Jul');
         monthMap.put(8,'Aug');
         monthMap.put(9,'Sep');
         monthMap.put(10,'Oct');
         monthMap.put(11,'Nov');
         monthMap.put(12,'Dec');
         
         
         plantShortNames.put('Annapolis','Annapolis');
         plantShortNames.put('Cambridge','Camb');
         plantShortNames.put('Queenstown','Qnstwn');
         plantShortNames.put('Bestgate Stone','Bestgate');
         plantShortNames.put('Bridgetown Plant','Brgtwn');
         plantShortNames.put('Hollywood','Hwood');
         plantShortNames.put('Hollywood Stone Depot','HwoodSt');
         plantShortNames.put('Riddle Plant','Riddle');
         plantShortNames.put('Sourthern Materials','SoMat');
         plantShortNames.put('Seat Pleasant','SP');
         plantShortNames.put('Upper Marlboro','UM');
         plantShortNames.put('Waldorf','Wal');
         plantShortNames.put('Waldorf SG Plant','Waldorf');
         plantShortNames.put('WaughChapel','WauCha');
         plantShortNames.put('King George Sand & Gravel','King George S & G');
         plantShortNames.put('Rowe Sand & Gravel','Rowe Sand & Gravel');
         plantShortNames.put('Stafford','Stafford');
         plantShortNames.put('Stafford Sand & Gravel','Stafford S & G');
         plantShortNames.put('DC Village','DC Village');
         plantShortNames.put('Spotsylvania','Spotsylvania');
         plantShortNames.put('Spotsylvania Sand & Gravel','Spottsylvania S & G');
         plantShortNames.put('Sandtown Pit','Sandtown Pit');
         plantShortNames.put('Salisbury','Salisbury');
         plantShortNames.put('Frederick Lafarge','Direct Ship Stone');
         plantShortNames.put('Cedar Mountain','Direct Ship Stone');
         plantShortNames.put('Agg Industries King George','Direct Ship Stone');
         plantShortNames.put('Agg Industries Farm Plant','Direct Ship Stone');
         plantShortNames.put('Luck Stone Spotsylvania','Direct Ship Stone');
         plantShortNames.put('Jessup','Jessup');
         plantShortNames.put('S.W. Barrick & Sons','Direct Ship Stone');
         plantShortNames.put('Agg Industries Hayfield','Direct Ship Stone');
         plantShortNames.put('Crofton','Crofton Recycled');
         plantShortNames.put('Rockville Crushed Stone','Direct Ship Stone');
         plantShortNames.put('Texas Lafarge','Direct Ship Stone');
         plantShortNames.put('Savage Stone','Savage Stone');
         
        
         
         userOwnerForPlants.add('King George Sand & Gravel');
         userOwnerForPlants.add('Rowe Sand & Gravel');
         userOwnerForPlants.add('Stafford');
         userOwnerForPlants.add('Stafford Sand & Gravel');
         userOwnerForPlants.add('DC Village');
         userOwnerForPlants.add('Spotsylvania');
         userOwnerForPlants.add('Spotsylvania Sand & Gravel');
         userOwnerForPlants.add('Sandtown Pit');
         userOwnerForPlants.add('Salisbury');
         userOwnerForPlants.add('Frederick Lafarge');
         userOwnerForPlants.add('Cedar Mountain');
         userOwnerForPlants.add('Agg Industries King George');
         userOwnerForPlants.add('Agg Industries Farm Plant');
         userOwnerForPlants.add('Luck Stone Spotsylvania');
         userOwnerForPlants.add('Jessup');
         userOwnerForPlants.add('S.W. Barrick & Sons');
         userOwnerForPlants.add('Agg Industries Hayfield');
         userOwnerForPlants.add('Crofton');
         userOwnerForPlants.add('Rockville Crushed Stone');
         userOwnerForPlants.add('Texas Lafarge');
         userOwnerForPlants.add('Savage Stone');
         userOwnerForPlants.add('Annapolis');
         userOwnerForPlants.add('Bestgate Stone');
         userOwnerForPlants.add('Bridgetown Plant');
         userOwnerForPlants.add('Hollywood');
         userOwnerForPlants.add('Hollywood Stone Depot');
         userOwnerForPlants.add('Riddle Plant');
         userOwnerForPlants.add('Sourthern Materials');
         userOwnerForPlants.add('Seat Pleasant');
         userOwnerForPlants.add('Upper Marlboro');
         userOwnerForPlants.add('Waldorf');
         userOwnerForPlants.add('Waldorf SG Plant');
         userOwnerForPlants.add('WaughChapel');
         
         
         quoteFamily.put('Concrete','Concrete');
         quoteFamily.put('Processed Sand','ProSand');
         quoteFamily.put('Stone','Stone');
         quoteFamily.put('Gravel','Gravel');
         quoteFamily.put('Unprocessed','UnpMat');
         quoteFamily.put('Recycle','Recycle');
         quoteFamily.put('Processed Mixed','ProcMix');
         quoteFamily.put('Semi-Processed','SemiProc');
    }
    
    
   /* public static void process(List<Dispatch_Sale__c> dsList){
        System.debug('Inside the trigger');
        
        
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
         
         //Get new accounts to create
        /* for (String custNum : accountNumberMap.keySet()){
            Account a;
            try {
                a = accountMapByCustomerNumber.get(custNum);
                if (a == null) {
                    a = new Account();
                    a.Account_Num__c = accountNumberMap.get(custNum).Customer_Number__c;
                }
            } catch (Nullpointerexception npe){
                a = new Account();
                a.Account_Num__c = accountNumberMap.get(custNum).Customer_Number__c;
            }
         }*/
         
         /*Map<Id,Quota__c> quotaMap =  new Map<Id,Quota__c>([select id,Name from Quota__c]);
         Map<String,Quota__c> quotaNameMap = new Map<String,Quota__c>();
         for (Id id: quotaMap.keySet()){
            quotaNameMap.put(quotaMap.get(id).name,quotaMap.get(id));
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
         //TODO:
        List<Account> upsertAccountList = new List<Account>();
        for (Dispatch_Sale__c ds: dsList){
            System.debug('ds.source_system__c -->' + ds.source_system__c);
            System.debug('ds.Customer_Number__c --> ' + ds.Customer_Number__c);
            System.debug('ds.Customer_Number__c --> ' + ds.Account_Number__c);
            System.debug('ds.ds.Job__c --> ' + ds.Job__c);
            System.debug('ds.Delivery_Date__c ==>' + ds.Delivery_Date__c);
            System.debug('ds.Product__c ==>' + ds.Product__c);
            System.debug('ds.Product_Class__c ==>' + ds.Product_Class__c);
            System.debug('ds.Plant__c ==>' + ds.Plant__c);
            System.debug('ds.Owner ==>' + ds.Dispatch_Owner__c);
            if ('Dispatch'.equals(ds.source_system__c)){
                //Map Quota
                //List <Account> aList = [SELECT a.id,a.accountnumber from Account a where a.Account_Num__c = :ds.Customer_Number__c LIMIT 1];
                Account a = accountMapByCustomerNumber.get(ds.Customer_Number__c);
                
                ds.Account__c = a.id;
                String jobKey = a.Account_Num__c + '-' + accountNumberMap.get(ds.Customer_Number__c).Job__c;
                try {
                    ds.Opportunity__c = opprJobKeyMap.get(jobKey).id;   
                }  catch (Nullpointerexception npe){
                    //Okay to get null pointer exception
                }
                
                    
                
                boolean isOwnerPlantAssignment = false;
                //Check to see if the plan belongs to the list that is not necessary to assign to concrete or aggregate qoutas
                 for (String s: MapRecordsForDispatchBatch.userOwnerForPlants){
                    if (s.equals(ds.Plant__c)) {
                        isOwnerPlantAssignment = true;
                        break;
                    }
                 }
            
                //When Dispatch Sale is inserted, evaluate whether it is a Concrete product or Aggregate product.  
                //If Concrete, update Dispatch_Sale.Last_Concrete_Sale_Date__c with value from DelivDate.  
                //If Aggregate, update Last_Aggregate_Sale_Date__c with value from DelivDate.
                boolean isAggregate = true; 
                String qf = '';
                
                p =  productMap.get(ds.Product__c);
                if ( p != null){
                    
                    Set <String> setQF = MapRecordsForDispatchBatch.quoteFamily.keySet();
                    if ('Rowe - Gravel'.equals(p.name)){
                        qf = 'Gravel';
                    } else if ('Rowe - Recycled Concrete'.equals(p.name)){
                        qf = 'Recycle';
                    } else if (true) {
                        for (String s:setQF) {
                            String v = MapRecordsForDispatchBatch.quoteFamily.get(s);
                            System.debug('v ---- > ' + v);
                            System.debug('v ---- > ' + p.name);
                            if (p.Name.contains('Unprocessed')) {
                                qf = 'UnpMat';
                            } else if (p.Name.contains('Processed')){
                                if (p.family.contains('Mixed')) {
                                    qf='ProcMix';
                                } else {
                                    qf = 'ProSand';
                                }
                            }
                            if (p.Name.contains('Recycle')){
                                qf = 'Recycle';
                            } 
                            if (p.Name.contains('Stone')){
                                qf = 'Stone';
                            }
                            if (p.Name.contains('Gravel')){
                                qf = 'Gravel';
                            }
                            if (p.Name.contains('Concrete')){
                                qf = 'Concrete';
                            }
                            
                            if (p.Name.contains('Semi')) {
                                    qf = 'SemiProc';
                            } 
                            
                            if (!''.equals(qf)){
                                break;
                            }
                        }
                    }
                                    
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
                    //List <User> userList = [Select u.Name, u.LastName, u.FirstName From User u where id=:ds.Dispatch_Owner__c];
                    if (u != null) {
                        String Quotastring = u.LastName;
                        
                        String monthYear = '';
                        if (ds.Delivery_Date__c.year() < 2012) {
                            if (isAggregate) {
                                Quotastring += '-Aggregate Pre2012';
                            } else {
                                Quotastring += '-Concrete Pre2012';
                            }
                            
                        } else {
                            monthYear += MapRecordsForDispatchBatch.monthMap.get(ds.Delivery_Date__c.month()) + ' ' + ds.Delivery_Date__c.year();
                            
                            if (isOwnerPlantAssignment || !isAggregate){
                                Quotastring += '-' + MapRecordsForDispatchBatch.plantShortNames.get(ds.Plant__c) + '-' + monthYear;
                            } else {
                                Quotastring += '-' + MapRecordsForDispatchBatch.plantShortNames.get(ds.Plant__c) + ' ' + qf +  ' ' + monthYear;
                            }
                            
                            
                        }
                        System.debug('Quotastring ---> '  + Quotastring);
                        System.debug('p.name ---> ' + p.name);
                        Quota__c QuotaList = quotaNameMap.get(Quotastring);
                        
                        if (QuotaList != null) {
                            ds.Quota__c = QuotaList.id;
                        } else {
                            Quotastring = u.LastName;
                            if (ds.Delivery_Date__c.year() < 2012) {
                                if (isOwnerPlantAssignment || !isAggregate){
                                    Quotastring = 'Holt-Concrete Pre2012';
                                } else {
                                    Quotastring = 'Holt-Aggregate Pre2012';
                                }
                            } else {
                                if (isAggregate) {
                                    Quotastring += '-Miscellaneous Aggregate-' + monthYear;
                                } else {
                                    Quotastring += '-Miscellaneous Concrete-' + monthYear;
                                }
                               
                            }
                            
                            
                            System.debug('Errror In Name ---> ' + Quotastring);
                            QuotaList = quotaNameMap.get(Quotastring);
                            if (QuotaList != null) {
                                ds.Quota__c = QuotaList.id;
                            }  else {
                                if (isOwnerPlantAssignment || !isAggregate){
                                    Quotastring = 'Holt-' + MapRecordsForDispatchBatch.plantShortNames.get(ds.Plant__c) + '-' + monthYear;
                                } else {
                                    Quotastring = 'Holt-' + MapRecordsForDispatchBatch.plantShortNames.get(ds.Plant__c) + ' ' + qf +  ' ' + monthYear;
                                }
                                    
                                QuotaList = quotaNameMap.get(Quotastring);
                                if (QuotaList != null) {
                                    ds.Quota__c = QuotaList.id;
                                } else {
                                    Quotastring = u.LastName;
                                    if (isOwnerPlantAssignment || !isAggregate){
                                        Quotastring = 'Holt-Concrete Pre2012';
                                    } else {
                                        Quotastring = 'Holt-Aggregate Pre2012';
                                    }
                                    QuotaList = quotaNameMap.get(Quotastring);
                                    if (QuotaList != null) {
                                        ds.Quota__c = QuotaList.id;
                                    } else {
                                        ds.Quota__c = 'a0WQ0000002j9uN';
                                    }
                                }
                                
                            } 
                        }
                    }   
                 } else {
                    ds.addError('Product not found for ' + ds.Product__c  + ' Customer Number ' + ds.Customer_Number__c);
                }
            } 
        }
        
        update upsertAccountList;
        
    }
    
    @isTest(SeeAllData=true)
    static void testMapRecords() {
        
        Account a = new Account();
        a.Name  = 'Test Account';
        a.Account_num__C = '12311';
        insert a;
        Dispatch_Sale__c ds = new Dispatch_Sale__c();
        ds.Customer_Number__c = a.Account_num__C;
        ds.Account_Number__c =  a.Account_num__C;
        ds.Units_Delivered__c = 12312;
        ds.Product__c = '01t700000025nUB';
        ds.Plant__c = 'Hollywood';
        
        ds.Account__c = a.id;
        ds.Job__c = '1231';
        ds.Full_Name__c = 'adfasdf';
        ds.Description__c = 'adfasdf';
        ds.Division__C = 'CE Concrete';
        ds.Delivery_Date__c = Date.newInstance(2012,12,1);
        ds.source_system__c = 'Dispatch';
        ds.Dispatch_Owner__c = '00570000001XsNf';
        insert ds;
        
        Dispatch_Sale__c ds3 = new Dispatch_Sale__c();
        ds3.Customer_Number__c = a.Account_num__C;
        ds3.Account_Number__C = a.Account_num__C;
        ds3.Units_Delivered__c = 12312;
        ds3.Product__c = '01t700000025nUB';
        ds3.Plant__c = 'Hollywood';
        
        ds3.Account__c = a.id;
        ds3.Job__c = '1231';
        ds3.Full_Name__c = 'adfasdf';
        ds3.Description__c = 'adfasdf';
        ds3.Division__C = 'CE Concrete';
        ds3.Delivery_Date__c = Date.newInstance(2011,12,1);
        ds3.source_system__c = 'Dispatch';
        ds3.Dispatch_Owner__c = '00570000001XsNf';
        insert ds3;
        
        
        Dispatch_Sale__c ds1 = new Dispatch_Sale__c();
        ds1.Customer_Number__c = a.Account_num__C;
        ds1.Account_Number__C = a.Account_num__C;
        
        ds1.Units_Delivered__c = 12312;
        ds1.Product__c = '01t70000003tlAi';
        ds1.Plant__c = 'Hollywood';
        
        ds1.Account__c = a.id;
        ds1.Job__c = '1231';
        ds1.Full_Name__c = 'adfasdf';
        ds1.Description__c = 'adfasdf';
        ds1.Division__C = 'CE Concrete';
        ds1.Delivery_Date__c = Date.newInstance(2012,12,1);
        ds1.source_system__c = 'Dispatch';
        ds1.Dispatch_Owner__c = '00570000001XsNf';
        insert ds1;
        
        Dispatch_Sale__c ds2 = new Dispatch_Sale__c();
        ds2.Customer_Number__c = a.Account_num__C;
        ds2.Account_Number__C = a.Account_num__C;
        ds2.Units_Delivered__c = 12312;
        ds2.Product__c = '01t70000003tlAi';
        ds2.Plant__c = 'Hollywood';
        ds2.Account__c = a.id;
        ds2.Job__c = '1231';
        ds2.Full_Name__c = 'adfasdf';
        ds2.Description__c = 'adfasdf';
        ds2.Division__C = 'CE Concrete';
        ds2.Delivery_Date__c = Date.newInstance(2011,12,1);
        ds2.source_system__c = 'Dispatch';
        ds2.Dispatch_Owner__c = '00570000001XsNf';
        insert ds2;
    }*/

}