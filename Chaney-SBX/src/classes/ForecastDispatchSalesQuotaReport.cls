/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* Create associated graphs in order to compare Forecast units (Opportunity Product Schedules) with 
* Dispatch Sale Units and Quota.  Product Name will determine which Dispatch_Sales Record type against 
* which “Forecast Schedule” .  The forecast will be gathering information for the last 6 months
**/
public with sharing class ForecastDispatchSalesQuotaReport {
 
 
     List <Product2> productList = new List<Product2>();
     
     public Integer testIntMonth = 0;
     
     public ReportData ra = new ReportData();
     public List<ReportDataStruct> rds = new List<ReportDataStruct>();
     
     public List<ReportDataStruct> getRds() {
        return rds;
     }
     
     public String productNameList {get;set;}
     public List<selectOption> ProductNameOptions {get {
        List<selectOption> productNames = new List<selectOption>();
        //30 products currently
        for (Product2 p : [Select p.id, p.Name From Product2 p where p.isActive=true order by p.name])
            productNames.add(new selectOption(p.id, p.name));
                return productNames;
        }
        private set;
    }
    
    public Map<Id,String> getProductMap() {
        List<Product2> pList = [Select p.id, p.Name From Product2 p where p.isActive=true order by p.name];
        Map<ID,String> pMap = new Map<ID,String>();
        for (Product2 p: pList){ 
                pMap.put(p.id, p.Name);
        }
        
        return pMap;
    }
    
    public PageReference processReport(){
        
        List <Product2> prodIDList= [Select p.id, p.Name From Product2 p where p.isActive=true order by p.name];
        Date beginDate;
        Date endDate;
        integer intYear = Date.Today().year();
        Integer prevYear = intYear - 1;
        Integer firstMonth = 7;
        String firstMonthQuery = 'Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d ' +
                                                         ' WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = ' + firstMonth + ' and CALENDAR_YEAR(d.Delivery_Date__c)  = ' + intYear + ' GROUP BY d.Product__r.Family';
        Integer secondMonth = 8;
        String secondMonthQuery = 'Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d ' +
                                                         ' WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = ' + secondMonth + ' and CALENDAR_YEAR(d.Delivery_Date__c)  = ' + intYear + ' GROUP BY d.Product__r.Family';
        Integer thirdMonth = 9;
        String thirdMonthQuery = 'Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d ' +
                                                         ' WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = ' + thirdMonth + ' and CALENDAR_YEAR(d.Delivery_Date__c)  = ' + intYear + ' GROUP BY d.Product__r.Family';
        Integer fourthMonth = 10;
        String forthdMonthQuery = 'Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d ' +
                                                         ' WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = ' + fourthMonth + ' and CALENDAR_YEAR(d.Delivery_Date__c)  = ' + intYear + ' GROUP BY d.Product__r.Family';
        Integer fifthMonth = 11;
        String fifthdMonthQuery = 'Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d ' +
                                                         ' WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = ' + fifthMonth + ' and CALENDAR_YEAR(d.Delivery_Date__c)  = ' + intYear + ' GROUP BY d.Product__r.Family';
        Integer sixthMonth = 12;
        String sixthMonthQuery = 'Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d ' +
                                                         ' WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = ' + sixthMonth + ' and CALENDAR_YEAR(d.Delivery_Date__c)  = ' + intYear + ' GROUP BY d.Product__r.Family';
        
        
        integer intMonth = Date.Today().month();
        //SM changed to allow test coverage
        if(testIntMonth <> 0) intMonth = testIntMonth;
        
        List <AggregateResult> firstMonthResultSet;
        List <AggregateResult> secondMonthResultSet;
        List <AggregateResult> thirdMonthResultSet;
        List <AggregateResult> fourthMonthResultSet;
        List <AggregateResult> fifthMonthResultSet;
        List <AggregateResult> sixthMonthResultSet;
        List <AggregateResult> firstMonthResultSetf;
        List <AggregateResult> secondMonthResultSetf;
        List <AggregateResult> thirdMonthResultSetf;
        List <AggregateResult> fourthMonthResultSetf;
        List <AggregateResult> fifthMonthResultSetf;
        List <AggregateResult> sixthMonthResultSetf;
        List <AggregateResult> firstMonthResultSetq;
        List <AggregateResult> secondMonthResultSetq;
        List <AggregateResult> thirdMonthResultSetq;
        List <AggregateResult> fourthMonthResultSetq;
        List <AggregateResult> fifthMonthResultSetq;
        List <AggregateResult> sixthMonthResultSetq;
        List <String> monthYear = new List<String>();
        
        
        if (intMonth == 12) {
                beginDate = Date.newInstance(intYear, 6, 30);
                endDate = Date.newInstance(intYear+1, 1, 1);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
               
               
               firstMonthResultSetq =   [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];                                                         
                
                monthYear.add('"' + intYear + '/' + firstMonth+ '"');
                monthYear.add('"' + intYear + '/' + secondMonth+ '"');
                monthYear.add('"' + intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        
        
        } else if (intMonth == 11) {
                beginDate = Date.newInstance(intYear, 5, 31);
                endDate = Date.newInstance(intYear, 12, 1);
                firstMonth = firstMonth - (12 - intMonth);
                secondMonth = secondMonth - (12 - intMonth);
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
               
               firstMonthResultSetq =   [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                                        
                monthYear.add('"' + intYear + '/' + firstMonth+ '"');
                monthYear.add('"' + intYear + '/' + secondMonth+ '"');
                monthYear.add('"' + intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 10) {
                beginDate = Date.newInstance(intYear, 4, 30);
                endDate = Date.newInstance(intYear, 11, 1);
                firstMonth = firstMonth - (12 - intMonth);
                secondMonth = secondMonth - (12 - intMonth);
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
               firstMonthResultSetq =   [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
               
                monthYear.add('"' + intYear + '/' + firstMonth+ '"');
                monthYear.add('"' + intYear + '/' + secondMonth+ '"');
                monthYear.add('"' + intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 9) {
                beginDate = Date.newInstance(intYear, 3, 31);
                endDate = Date.newInstance(intYear, 10, 1);
                firstMonth = firstMonth - (12 - intMonth);
                secondMonth = secondMonth - (12 - intMonth);
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                
                firstMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                
                monthYear.add('"' + intYear + '/' + firstMonth+ '"');
                monthYear.add('"' + intYear + '/' + secondMonth+ '"');
                monthYear.add('"' + intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 8) {
                endDate = Date.newInstance(intYear, 9, 1);
                boolean isLeapYear = Date.isLeapYear(intYear);
                //Leap Year
                if (isLeapYear) {
                        beginDate = Date.newInstance(intYear, 2, 29);
                } else {
                        beginDate = Date.newInstance(intYear, 2, 28);
                }
                firstMonth = firstMonth - (12 - intMonth);
                secondMonth = secondMonth - (12 - intMonth);
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                
                firstMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                
                
                monthYear.add('"' + intYear + '/' + firstMonth+ '"');
                monthYear.add('"' + intYear + '/' + secondMonth+ '"');
                monthYear.add('"' + intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 7) {
                beginDate = Date.newInstance(intYear, 1, 31);
                endDate = Date.newInstance(intYear, 8, 1);
                firstMonth = firstMonth - (12 - intMonth);
                secondMonth = secondMonth - (12 - intMonth);
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                
                firstMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                
                monthYear.add('"' + intYear + '/' + firstMonth+ '"');
                monthYear.add('"' + intYear + '/' + secondMonth+ '"');
                monthYear.add('"' + intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 6) {
                beginDate = Date.newInstance(intYear-1, 12, 31);
                endDate = Date.newInstance(intYear, 7, 1);
                firstMonth = firstMonth - (12 - intMonth);
                secondMonth = secondMonth - (12 - intMonth);
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                
                
                firstMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                
                
                monthYear.add('"' + intYear + '/' + firstMonth+ '"');
                monthYear.add('"' + intYear + '/' + secondMonth+ '"');
                monthYear.add('"' + intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 5) {
                beginDate = Date.newInstance(intYear-1, 11, 30);
                endDate = Date.newInstance(intYear, 6, 1);
                firstMonth = firstMonth - (12 - intMonth)  + 12;
                secondMonth = secondMonth - (12 - intMonth);
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                firstMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                
                
                monthYear.add('"' + prevYear + '/' + firstMonth + '"');
                monthYear.add('"' +intYear + ' / ' + secondMonth + '"');
                monthYear.add('"' +intYear + ' / ' + thirdMonth + '"');
                monthYear.add('"' +intYear + ' / ' + fourthMonth + '"');
                monthYear.add('"' +intYear + ' / ' + fifthMonth + '"');
                monthYear.add('"' +intYear + ' / ' + sixthMonth + '"');
        } else if (intMonth == 4) {
                beginDate = Date.newInstance(intYear-1, 10, 31);
                endDate = Date.newInstance(intYear, 5, 1);
                firstMonth = firstMonth - (12 - intMonth)  + 12;
                secondMonth = secondMonth - (12 - intMonth) + 12;
                thirdMonth = thirdMonth - (12 - intMonth);
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
          firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                                                                        
                                                firstMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
            monthYear.add('"' +prevYear + '/' + firstMonth+ '"');
                monthYear.add('"' +prevYear + '/' + secondMonth+ '"');
                monthYear.add('"' +intYear + '/' + thirdMonth+ '"');
                monthYear.add('"' +intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' +intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' +intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 3) {
                beginDate = Date.newInstance(intYear-1, 09, 30);
                endDate = Date.newInstance(intYear, 4, 1);
                firstMonth = firstMonth - (12 - intMonth)  + 12;
                secondMonth = secondMonth - (12 - intMonth) + 12;
                thirdMonth = thirdMonth - (12 - intMonth) + 12;
                fourthMonth = fourthMonth - (12 - intMonth);
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
            firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                 firstMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                                                                                               
            monthYear.add('"' + prevYear + '/' + firstMonth+ '"');
                monthYear.add('"' + prevYear + '/' + secondMonth+ '"');
                monthYear.add('"' + prevYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + intYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        
        } else if (intMonth == 2) {
                beginDate = Date.newInstance(intYear-1, 08, 31);
                endDate = Date.newInstance(intYear, 3, 1);
                firstMonth = firstMonth - (12 - intMonth)  + 12;
                secondMonth = secondMonth - (12 - intMonth) + 12;
                thirdMonth = thirdMonth - (12 - intMonth) + 12;
                fourthMonth = fourthMonth - (12 - intMonth) + 12;
                fifthMonth = fifthMonth - (12 - intMonth);
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
            firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                        firstMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                                        
            monthYear.add('"' + prevYear + '/' + firstMonth+ '"');
                monthYear.add('"' + prevYear + '/' + secondMonth+ '"');
                monthYear.add('"' + prevYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + prevYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + intYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        } else if (intMonth == 1) {
                beginDate = Date.newInstance(intYear-1, 07, 31);
                endDate = Date.newInstance(intYear, 2, 1);
                firstMonth = firstMonth - (12 - intMonth)  + 12;
                secondMonth = secondMonth - (12 - intMonth) + 12;
                thirdMonth = thirdMonth - (12 - intMonth) + 12;
                fourthMonth = fourthMonth - (12 - intMonth) + 12;
                fifthMonth = fifthMonth - (12 - intMonth) + 12;
                sixthMonth = sixthMonth - (12 - intMonth);
                firstMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :firstMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                secondMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :secondMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                thirdMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :thirdMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                fourthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fourthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                fifthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :fifthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :prevYear  GROUP BY d.Product__r.Family];
                sixthMonthResultSet = [Select SUM(d.Units_Delivered__c) TOTALUNITS,d.Product__r.Family PRODID From Dispatch_Sale__c d 
                                                           WHERE d.IsDeleted=false and CALENDAR_MONTH(d.Delivery_Date__c)  = :sixthMonth  and CALENDAR_YEAR(d.Delivery_Date__c)  = :intYear  GROUP BY d.Product__r.Family];
            
            firstMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :firstMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        secondMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :secondMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        thirdMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :thirdMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        fourthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fourthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        
                        fifthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :fifthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :prevYear group by  o.OpportunityLineItem.Product_Family__c ];
                        sixthMonthResultSetf =[Select sum(o.Quantity) quantity, o.OpportunityLineItem.Product_Family__c prodclass From OpportunityLineItemSchedule o where
                                                                        CALENDAR_MONTH(o.ScheduleDate)  = :sixthMonth  and CALENDAR_YEAR(o.ScheduleDate)  = :intYear group by  o.OpportunityLineItem.Product_Family__c ];
                  
                  firstMonthResultSetq =        [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :firstMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                            secondMonthResultSetq =     [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :secondMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                thirdMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :thirdMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fourthMonthResultSetq = [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fourthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                fifthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :fifthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                sixthMonthResultSetq =  [Select sum(q.Units_Quota__c) TOTALQUOTA,  q.Quota_Family__c prodclass From Quota__c q 
                                                                        where CALENDAR_MONTH(q.Month__c) = :sixthMonth and CALENDAR_YEAR(q.Month__c) = :intYear group by  Quota_Family__c];
                                                                                                                              
            monthYear.add('"' + prevYear + '/' + firstMonth+ '"');
                monthYear.add('"' + prevYear + '/' + secondMonth+ '"');
                monthYear.add('"' + prevYear + '/' + thirdMonth+ '"');
                monthYear.add('"' + prevYear + '/' + fourthMonth+ '"');
                monthYear.add('"' + prevYear + '/' + fifthMonth+ '"');
                monthYear.add('"' + intYear + '/' + sixthMonth+ '"');
        }
        
        buildReportData(monthYear,firstMonthResultSet,secondMonthResultSet,thirdMonthResultSet,
                                fourthMonthResultSet,fifthMonthResultSet,sixthMonthResultSet,firstMonthResultSetf,secondMonthResultSetf,thirdMonthResultSetf,
                                fourthMonthResultSetf,fifthMonthResultSetf,sixthMonthResultSetf,firstMonthResultSetq,secondMonthResultSetq,thirdMonthResultSetq,
                                fourthMonthResultSetq,fifthMonthResultSetq,sixthMonthResultSetq);
     
      return null;
     
    }
    
    private void buildReportData(List<String> monthYear, List<AggregateResult> firstMonthResultSet,
                                                                List<AggregateResult> secondMonthResultSet,List<AggregateResult> thirdMonthResultSet,
                                                                List<AggregateResult> fourthMonthResultSet,List<AggregateResult> fifthMonthResultSet,
                                                                List<AggregateResult> sixthMonthResultSet,List<AggregateResult> firstMonthResultSetf,
                                                                List<AggregateResult> secondMonthResultSetf,List<AggregateResult> thirdMonthResultSetf,
                                                                List<AggregateResult> fourthMonthResultSetf,List<AggregateResult> fifthMonthResultSetf,
                                                                List<AggregateResult> sixthMonthResultSetf,List<AggregateResult> firstMonthResultSetq,
                                                                List<AggregateResult> secondMonthResultSetq,List<AggregateResult> thirdMonthResultSetq,
                                                                List<AggregateResult> fourthMonthResultSetq,List<AggregateResult> fifthMonthResultSetq,
                                                                List<AggregateResult> sixthMonthResultSetq){
        System.debug('Inside buildReportData -----');
        Set <String> productFamilyList = new Set<String>();
        ra.yearMonth = monthYear;
        
        Map <String,Decimal> firstMonthResultMap = new Map<String,Decimal> ();
        Map <String,Decimal> secondMonthResultMap = new Map<String,Decimal> ();
        Map <String,Decimal> thirdMonthResultMap  = new Map<String,Decimal> ();
        Map <String,Decimal> fourthMonthResultMap = new Map<String,Decimal> ();
        Map <String,Decimal> fifthMonthResultMap = new Map<String,Decimal> ();
        Map <String,Decimal> sixthMonthResultMap = new Map<String,Decimal> ();
        Map <String,Decimal> firstMonthResultMapf = new Map<String,Decimal> ();
        Map <String,Decimal> secondMonthResultMapf = new Map<String,Decimal> ();
        Map <String,Decimal> thirdMonthResultMapf  = new Map<String,Decimal> ();
        Map <String,Decimal> fourthMonthResultMapf = new Map<String,Decimal> ();
        Map <String,Decimal> fifthMonthResultMapf = new Map<String,Decimal> ();
        Map <String,Decimal> sixthMonthResultMapf = new Map<String,Decimal> ();
        Map <String,Decimal> firstMonthResultMapq = new Map<String,Decimal> ();
        Map <String,Decimal> secondMonthResultMapq = new Map<String,Decimal> ();
        Map <String,Decimal> thirdMonthResultMapq  = new Map<String,Decimal> ();
        Map <String,Decimal> fourthMonthResultMapq = new Map<String,Decimal> ();
        Map <String,Decimal> fifthMonthResultMapq = new Map<String,Decimal> ();
        Map <String,Decimal> sixthMonthResultMapq = new Map<String,Decimal> ();
        
        for (AggregateResult ja : firstMonthResultSet) {
                        
                            firstMonthResultMap.put((String) ja.get('PRODID'),(Decimal) ja.get('TOTALUNITS'));
        } 
        for (AggregateResult ja : secondMonthResultSet) {
                    secondMonthResultMap.put((String) ja.get('PRODID'),(Decimal) ja.get('TOTALUNITS'));
        } 
        for (AggregateResult ja : thirdMonthResultSet) {
                    thirdMonthResultMap.put((String) ja.get('PRODID'),(Decimal) ja.get('TOTALUNITS'));
        } 
        for (AggregateResult ja : fourthMonthResultSet) {
                    fourthMonthResultMap.put((String) ja.get('PRODID'),(Decimal) ja.get('TOTALUNITS'));
        } 
        for (AggregateResult ja : fifthMonthResultSet) {
                    fifthMonthResultMap.put((String) ja.get('PRODID'),(Decimal) ja.get('TOTALUNITS'));
        } 
        for (AggregateResult ja : sixthMonthResultSet) {
                    sixthMonthResultMap.put((String) ja.get('PRODID'),(Decimal) ja.get('TOTALUNITS'));
        } 
        
        for (AggregateResult ja : firstMonthResultSetf) {
                
                    firstMonthResultMapf.put((String) ja.get('prodclass'),(Decimal) ja.get('quantity'));
        } 
        for (AggregateResult ja : secondMonthResultSetf) {
                    secondMonthResultMapf.put((String) ja.get('prodclass'),(Decimal) ja.get('quantity'));
        } 
        for (AggregateResult ja : thirdMonthResultSetf) {
                    thirdMonthResultMapf.put((String) ja.get('prodclass'),(Decimal) ja.get('quantity'));
        } 
        for (AggregateResult ja : fourthMonthResultSetf) {
                    fourthMonthResultMapf.put((String) ja.get('prodclass'),(Decimal) ja.get('quantity'));
        } 
        for (AggregateResult ja : fifthMonthResultSetf) {
                    fifthMonthResultMapf.put((String) ja.get('prodclass'),(Decimal) ja.get('quantity'));
        } 
        for (AggregateResult ja : sixthMonthResultSetf) {
                    sixthMonthResultMapf.put((String) ja.get('prodclass'),(Decimal) ja.get('quantity'));
        } 
        for (AggregateResult ja : firstMonthResultSetq) {
            String s = (String) ja.get('prodclass');
             if ('Concrete'.equals(s)) {
                firstMonthResultMapq.put('Concrete Mixes',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Processed Sand'.equals(s) 
                                ||'Processed Mixed'.equals(s) 
                                ||'Processed Gravel'.equals(s) ) {
                Decimal d = firstMonthResultMapq.get('Processed Materials');
                if (d!=null) {
                        d+=(Decimal) ja.get('TOTALQUOTA');
                } else {
                        d = (Decimal) ja.get('TOTALQUOTA');
                }
                
                firstMonthResultMapq.put('Processed Materials',d);
              } else  if ('Recycled'.equals(s)) {
                firstMonthResultMapq.put('Recycled Products',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Semi-Processed'.equals(s)) {
                firstMonthResultMapq.put('Semi-Processed Materials',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Stone'.equals(s)) {
                firstMonthResultMapq.put('Stone Products (PFR)',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Unprocessed'.equals(s)) {
                firstMonthResultMapq.put('Unprocessed Materials',(Decimal) ja.get('TOTALQUOTA'));
              }
              
              
        } 
        for (AggregateResult ja : thirdMonthResultSetq) {
                    String s = (String) ja.get('prodclass');
             if ('Concrete'.equals(s)) {
                thirdMonthResultMapf.put('Concrete Mixes',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Processed Sand'.equals(s) 
                                ||'Processed Mixed'.equals(s) 
                                ||'Processed Gravel'.equals(s) ) {
                Decimal d = thirdMonthResultMapf.get('Processed Materials');
                if (d!=null) {
                        d+=(Decimal) ja.get('TOTALQUOTA');
                } else {
                        d = (Decimal) ja.get('TOTALQUOTA');
                }
                
                thirdMonthResultMapf.put('Processed Materials',d);
              } else  if ('Recycled'.equals(s)) {
                thirdMonthResultMapf.put('Recycled Products',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Semi-Processed'.equals(s)) {
                thirdMonthResultMapf.put('Semi-Processed Materials',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Stone'.equals(s)) {
                thirdMonthResultMapf.put('Stone Products (PFR)',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Unprocessed'.equals(s)) {
                thirdMonthResultMapf.put('Unprocessed Materials',(Decimal) ja.get('TOTALQUOTA'));
              }
        } 
        for (AggregateResult ja : secondMonthResultSetq) {
                    String s = (String) ja.get('prodclass');
             if ('Concrete'.equals(s)) {
                secondMonthResultMapq.put('Concrete Mixes',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Processed Sand'.equals(s) 
                                ||'Processed Mixed'.equals(s) 
                                ||'Processed Gravel'.equals(s) ) {
                Decimal d = secondMonthResultMapq.get('Processed Materials');
                if (d!=null) {
                        d+=(Decimal) ja.get('TOTALQUOTA');
                } else {
                        d = (Decimal) ja.get('TOTALQUOTA');
                }
                
                secondMonthResultMapq.put('Processed Materials',d);
              } else  if ('Recycled'.equals(s)) {
                secondMonthResultMapq.put('Recycled Products',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Semi-Processed'.equals(s)) {
                secondMonthResultMapq.put('Semi-Processed Materials',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Stone'.equals(s)) {
                secondMonthResultMapq.put('Stone Products (PFR)',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Unprocessed'.equals(s)) {
                secondMonthResultMapq.put('Unprocessed Materials',(Decimal) ja.get('TOTALQUOTA'));
              }
        } 
        for (AggregateResult ja : sixthMonthResultSetq) {
                    String s = (String) ja.get('prodclass');
             if ('Concrete'.equals(s)) {
                sixthMonthResultMapq.put('Concrete Mixes',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Processed Sand'.equals(s) 
                                ||'Processed Mixed'.equals(s) 
                                ||'Processed Gravel'.equals(s) ) {
                Decimal d = sixthMonthResultMapq.get('Processed Materials');
                if (d!=null) {
                        d+=(Decimal) ja.get('TOTALQUOTA');
                } else {
                        d = (Decimal) ja.get('TOTALQUOTA');
                }
                
                sixthMonthResultMapq.put('Processed Materials',d);
              } else  if ('Recycled'.equals(s)) {
                sixthMonthResultMapq.put('Recycled Products',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Semi-Processed'.equals(s)) {
                sixthMonthResultMapq.put('Semi-Processed Materials',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Stone'.equals(s)) {
                sixthMonthResultMapq.put('Stone Products (PFR)',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Unprocessed'.equals(s)) {
                sixthMonthResultMapq.put('Unprocessed Materials',(Decimal) ja.get('TOTALQUOTA'));
              }
        } 
        for (AggregateResult ja : fifthMonthResultSetq) {
                    String s = (String) ja.get('prodclass');
             if ('Concrete'.equals(s)) {
                fifthMonthResultMapq.put('Concrete Mixes',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Processed Sand'.equals(s) 
                                ||'Processed Mixed'.equals(s) 
                                ||'Processed Gravel'.equals(s) ) {
                Decimal d = fifthMonthResultMapq.get('Processed Materials');
                if (d!=null) {
                        d+=(Decimal) ja.get('TOTALQUOTA');
                } else {
                        d = (Decimal) ja.get('TOTALQUOTA');
                }
                
                fifthMonthResultMapq.put('Processed Materials',d);
              } else  if ('Recycled'.equals(s)) {
                fifthMonthResultMapq.put('Recycled Products',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Semi-Processed'.equals(s)) {
                fifthMonthResultMapq.put('Semi-Processed Materials',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Stone'.equals(s)) {
                fifthMonthResultMapq.put('Stone Products (PFR)',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Unprocessed'.equals(s)) {
                fifthMonthResultMapq.put('Unprocessed Materials',(Decimal) ja.get('TOTALQUOTA'));
              }
        } 
        for (AggregateResult ja : fourthMonthResultSetq) {
                    String s = (String) ja.get('prodclass');
             if ('Concrete'.equals(s)) {
                fourthMonthResultMapq.put('Concrete Mixes',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Processed Sand'.equals(s) 
                                ||'Processed Mixed'.equals(s) 
                                ||'Processed Gravel'.equals(s) ) {
                Decimal d = fourthMonthResultMapq.get('Processed Materials');
                if (d!=null) {
                        d+=(Decimal) ja.get('TOTALQUOTA');
                } else {
                        d = (Decimal) ja.get('TOTALQUOTA');
                }
                
                fourthMonthResultMapq.put('Processed Materials',d);
              } else  if ('Recycled'.equals(s)) {
                fourthMonthResultMapq.put('Recycled Products',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Semi-Processed'.equals(s)) {
                fourthMonthResultMapq.put('Semi-Processed Materials',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Stone'.equals(s)) {
                fourthMonthResultMapq.put('Stone Products (PFR)',(Decimal) ja.get('TOTALQUOTA'));
              } else  if ('Unprocessed'.equals(s)) {
                fourthMonthResultMapq.put('Unprocessed Materials',(Decimal) ja.get('TOTALQUOTA'));
              }
        } 
        System.debug('firstMonthResultMapq---->' + firstMonthResultMapq);
        System.debug('firstMonthResultMapq---->' + secondMonthResultMapq);
        System.debug('firstMonthResultMapq---->' + thirdMonthResultMapq);
        System.debug('firstMonthResultMapq---->' + fourthMonthResultMapq);
        System.debug('firstMonthResultMapq---->' + fifthMonthResultMapq);
        System.debug('firstMonthResultMapq---->' + sixthMonthResultMapq);
        
        productFamilyList.add('Concrete Mixes');
        productFamilyList.add('Processed Materials');
        productFamilyList.add('Recycled Products');
        productFamilyList.add('Rowe-Aggregates');
        productFamilyList.add('Semi-Processed Materials');
        productFamilyList.add('Stone Products (PFR)');
        productFamilyList.add('Unprocessed Materials');
        for (String s:productFamilyList){
                Decimal val = firstMonthResultMap.get(s);
                if (val == null){
                        firstMonthResultMap.put(s,0.0);
                } 
                val = secondMonthResultMap.get(s);
                if (val == null){
                        secondMonthResultMap.put(s,0.0);
                } 
                val = thirdMonthResultMap.get(s);
                if (val == null){
                        thirdMonthResultMap.put(s,0.0);
                } 
                val = fourthMonthResultMap.get(s);
                if (val == null){
                        fourthMonthResultMap.put(s,0.0);
                } 
                val = fifthMonthResultMap.get(s);
                if (val == null){
                        fifthMonthResultMap.put(s,0.0);
                } 
                val = sixthMonthResultMap.get(s);
                if (val == null){
                        sixthMonthResultMap.put(s,0.0);
                } 
                 val = firstMonthResultMapf.get(s);
                if (val == null){
                        firstMonthResultMapf.put(s,0.0);
                } 
                val = secondMonthResultMapf.get(s);
                if (val == null){
                        secondMonthResultMapf.put(s,0.0);
                } 
                val = thirdMonthResultMapf.get(s);
                if (val == null){
                        thirdMonthResultMapf.put(s,0.0);
                } 
                val = fourthMonthResultMapf.get(s);
                if (val == null){
                        fourthMonthResultMapf.put(s,0.0);
                } 
                val = fifthMonthResultMapf.get(s);
                if (val == null){
                        fifthMonthResultMapf.put(s,0.0);
                } 
                val = sixthMonthResultMapf.get(s);
                if (val == null){
                        sixthMonthResultMapf.put(s,0.0);
                } 
                
                val = firstMonthResultMapq.get(s);
                if (val == null){
                        firstMonthResultMapq.put(s,0.0);
                } 
                val = secondMonthResultMapq.get(s);
                if (val == null){
                        secondMonthResultMapq.put(s,0.0);
                } 
                val = thirdMonthResultMapq.get(s);
                if (val == null){
                        thirdMonthResultMapq.put(s,0.0);
                } 
                val = fourthMonthResultMapq.get(s);
                if (val == null){
                        fourthMonthResultMapq.put(s,0.0);
                } 
                val = fifthMonthResultMapq.get(s);
                if (val == null){
                        fifthMonthResultMapq.put(s,0.0);
                } 
                val = sixthMonthResultMapq.get(s);
                if (val == null){
                        sixthMonthResultMapq.put(s,0.0);
                } 
                
        }
        
        for (String s:productFamilyList){ 
                if ('Concrete Mixes'.equals(s)) {
                        ra.ConcreateMixes.add(firstMonthResultMap.get(s));
                        ra.ConcreateMixes.add(secondMonthResultMap.get(s));
                        ra.ConcreateMixes.add(thirdMonthResultMap.get(s));
                        ra.ConcreateMixes.add(fourthMonthResultMap.get(s));
                        ra.ConcreateMixes.add(fifthMonthResultMap.get(s));
                        ra.ConcreateMixes.add(sixthMonthResultMap.get(s));
                        
                        ra.ConcreateMixesf.add(firstMonthResultMapf.get(s));
                        ra.ConcreateMixesf.add(secondMonthResultMapf.get(s));
                        ra.ConcreateMixesf.add(thirdMonthResultMapf.get(s));
                        ra.ConcreateMixesf.add(fourthMonthResultMapf.get(s));
                        ra.ConcreateMixesf.add(fifthMonthResultMapf.get(s));
                        ra.ConcreateMixesf.add(sixthMonthResultMapf.get(s));
                        
                        ra.ConcreateMixesq.add(firstMonthResultMapq.get(s));
                        ra.ConcreateMixesq.add(secondMonthResultMapq.get(s));
                        ra.ConcreateMixesq.add(thirdMonthResultMapq.get(s));
                        ra.ConcreateMixesq.add(fourthMonthResultMapq.get(s));
                        ra.ConcreateMixesq.add(fifthMonthResultMapq.get(s));
                        ra.ConcreateMixesq.add(sixthMonthResultMapq.get(s));
                                
                } else if ('Processed Materials'.equals(s)) {
                        ra.ProcessedMaterials.add(firstMonthResultMap.get(s));
                        ra.ProcessedMaterials.add(secondMonthResultMap.get(s));
                        ra.ProcessedMaterials.add(thirdMonthResultMap.get(s));
                        ra.ProcessedMaterials.add(fourthMonthResultMap.get(s));
                        ra.ProcessedMaterials.add(fifthMonthResultMap.get(s));
                        ra.ProcessedMaterials.add(sixthMonthResultMap.get(s));
                        
                        ra.ProcessedMaterialsf.add(firstMonthResultMapf.get(s));
                        ra.ProcessedMaterialsf.add(secondMonthResultMapf.get(s));
                        ra.ProcessedMaterialsf.add(thirdMonthResultMapf.get(s));
                        ra.ProcessedMaterialsf.add(fourthMonthResultMapf.get(s));
                        ra.ProcessedMaterialsf.add(fifthMonthResultMapf.get(s));
                        ra.ProcessedMaterialsf.add(sixthMonthResultMapf.get(s));
                        
                        ra.ProcessedMaterialsq.add(firstMonthResultMapq.get(s));
                         ra.ProcessedMaterialsq.add(secondMonthResultMapq.get(s));
                        ra.ProcessedMaterialsq.add(thirdMonthResultMapq.get(s));
                        ra.ProcessedMaterialsq.add(fourthMonthResultMapq.get(s));
                        ra.ProcessedMaterialsq.add(fifthMonthResultMapq.get(s));
                        ra.ProcessedMaterialsq.add(sixthMonthResultMapq.get(s));
                        
                                
                } else if ('Recycled Products'.equals(s)) {
                        ra.RecycledProducts.add(firstMonthResultMap.get(s));
                        ra.RecycledProducts.add(secondMonthResultMap.get(s));
                        ra.RecycledProducts.add(thirdMonthResultMap.get(s));
                        ra.RecycledProducts.add(fourthMonthResultMap.get(s));
                        ra.RecycledProducts.add(fifthMonthResultMap.get(s));
                        ra.RecycledProducts.add(sixthMonthResultMap.get(s));
                        
                        ra.RecycledProductsf.add(firstMonthResultMapf.get(s));
                        ra.RecycledProductsf.add(secondMonthResultMapf.get(s));
                        ra.RecycledProductsf.add(thirdMonthResultMapf.get(s));
                        ra.RecycledProductsf.add(fourthMonthResultMapf.get(s));
                        ra.RecycledProductsf.add(fifthMonthResultMapf.get(s));
                        ra.RecycledProductsf.add(sixthMonthResultMapf.get(s));
                        
                        ra.RecycledProductsq.add(firstMonthResultMapq.get(s));
                        ra.RecycledProductsq.add(secondMonthResultMapq.get(s));
                        ra.RecycledProductsq.add(thirdMonthResultMapq.get(s));
                        ra.RecycledProductsq.add(fourthMonthResultMapq.get(s));
                        ra.RecycledProductsq.add(fifthMonthResultMapq.get(s));
                        ra.RecycledProductsq.add(sixthMonthResultMapq.get(s));
                        
                     
                                
                } else if ('Rowe-Aggregates'.equals(s)) {
                        ra.RoweAggregages.add(firstMonthResultMap.get(s));
                        ra.RoweAggregages.add(secondMonthResultMap.get(s));
                        ra.RoweAggregages.add(thirdMonthResultMap.get(s));
                        ra.RoweAggregages.add(fourthMonthResultMap.get(s));
                        ra.RoweAggregages.add(fifthMonthResultMap.get(s));
                        ra.RoweAggregages.add(sixthMonthResultMap.get(s));
                        
                        ra.RoweAggregagesf.add(firstMonthResultMapf.get(s));
                        ra.RoweAggregagesf.add(secondMonthResultMapf.get(s));
                        ra.RoweAggregagesf.add(thirdMonthResultMapf.get(s));
                        ra.RoweAggregagesf.add(fourthMonthResultMapf.get(s));
                        ra.RoweAggregagesf.add(fifthMonthResultMapf.get(s));
                        ra.RoweAggregagesf.add(sixthMonthResultMapf.get(s));
                        
                       
                                
                } else if ('Semi-Processed Materials'.equals(s)) {
                        ra.SemiProcessedMaterials.add(firstMonthResultMap.get(s));
                        ra.SemiProcessedMaterials.add(secondMonthResultMap.get(s));
                        ra.SemiProcessedMaterials.add(thirdMonthResultMap.get(s));
                        ra.SemiProcessedMaterials.add(fourthMonthResultMap.get(s));
                        ra.SemiProcessedMaterials.add(fifthMonthResultMap.get(s));
                        ra.SemiProcessedMaterials.add(sixthMonthResultMap.get(s));
                        
                        ra.SemiProcessedMaterialsf.add(firstMonthResultMapf.get(s));
                        ra.SemiProcessedMaterialsf.add(secondMonthResultMapf.get(s));
                        ra.SemiProcessedMaterialsf.add(thirdMonthResultMapf.get(s));
                        ra.SemiProcessedMaterialsf.add(fourthMonthResultMapf.get(s));
                        ra.SemiProcessedMaterialsf.add(fifthMonthResultMapf.get(s));
                        ra.SemiProcessedMaterialsf.add(sixthMonthResultMapf.get(s));
                        
                        ra.SemiProcessedMaterialsq.add(firstMonthResultMapq.get(s));
                        ra.SemiProcessedMaterialsq.add(secondMonthResultMapq.get(s));
                        ra.SemiProcessedMaterialsq.add(thirdMonthResultMapq.get(s));
                        ra.SemiProcessedMaterialsq.add(fourthMonthResultMapq.get(s));
                        ra.SemiProcessedMaterialsq.add(fifthMonthResultMapq.get(s));
                        ra.SemiProcessedMaterialsq.add(sixthMonthResultMapq.get(s));
                                
                } else if ('Stone Products (PFR)'.equals(s)) {
                        ra.StoneProducts.add(firstMonthResultMap.get(s));
                        ra.StoneProducts.add(secondMonthResultMap.get(s));
                        ra.StoneProducts.add(thirdMonthResultMap.get(s));
                        ra.StoneProducts.add(fourthMonthResultMap.get(s));
                        ra.StoneProducts.add(fifthMonthResultMap.get(s));
                        ra.StoneProducts.add(sixthMonthResultMap.get(s));
                        
                        ra.StoneProductsf.add(firstMonthResultMapf.get(s));
                        ra.StoneProductsf.add(secondMonthResultMapf.get(s));
                        ra.StoneProductsf.add(thirdMonthResultMapf.get(s));
                        ra.StoneProductsf.add(fourthMonthResultMapf.get(s));
                        ra.StoneProductsf.add(fifthMonthResultMapf.get(s));
                        ra.StoneProductsf.add(sixthMonthResultMapf.get(s));
                        
                        ra.StoneProductsq.add(firstMonthResultMapq.get(s));
                        ra.StoneProductsq.add(secondMonthResultMapq.get(s));
                        ra.StoneProductsq.add(thirdMonthResultMapq.get(s));
                        ra.StoneProductsq.add(fourthMonthResultMapq.get(s));
                        ra.StoneProductsq.add(fifthMonthResultMapq.get(s));
                        ra.StoneProductsq.add(sixthMonthResultMapq.get(s));
                                
                } else if ('Unprocessed Materials'.equals(s)) {
                        ra.UnprocessedMaterials.add(firstMonthResultMap.get(s));
                        ra.UnprocessedMaterials.add(secondMonthResultMap.get(s));
                        ra.UnprocessedMaterials.add(thirdMonthResultMap.get(s));
                        ra.UnprocessedMaterials.add(fourthMonthResultMap.get(s));
                        ra.UnprocessedMaterials.add(fifthMonthResultMap.get(s));
                        ra.UnprocessedMaterials.add(sixthMonthResultMap.get(s));
                        
                        ra.UnprocessedMaterialsf.add(firstMonthResultMapf.get(s));
                        ra.UnprocessedMaterialsf.add(secondMonthResultMapf.get(s));
                        ra.UnprocessedMaterialsf.add(thirdMonthResultMapf.get(s));
                        ra.UnprocessedMaterialsf.add(fourthMonthResultMapf.get(s));
                        ra.UnprocessedMaterialsf.add(fifthMonthResultMapf.get(s));
                        ra.UnprocessedMaterialsf.add(sixthMonthResultMapf.get(s));
                        
                        ra.UnprocessedMaterialsq.add(firstMonthResultMapq.get(s));
                        ra.UnprocessedMaterialsq.add(secondMonthResultMapq.get(s));
                        ra.UnprocessedMaterialsq.add(thirdMonthResultMapq.get(s));
                        ra.UnprocessedMaterialsq.add(fourthMonthResultMapq.get(s));
                        ra.UnprocessedMaterialsq.add(fifthMonthResultMapq.get(s));
                        ra.UnprocessedMaterialsq.add(sixthMonthResultMapq.get(s));
                                
                }
        }
        
        for (integer i=0;i<6;i++) {
                ReportDataStruct r = new ReportDataStruct();
                r.yearMonth = monthYear.get(i);
                r.ConcreateMixes = ra.ConcreateMixes.get(i);
                r.ProcessedMaterials = ra.ProcessedMaterials.get(i);
                r.RecycledProducts = ra.RecycledProducts.get(i);
                r.RoweAggregages = ra.RoweAggregages.get(i);
                r.SemiProcessedMaterials = ra.SemiProcessedMaterials.get(i);
                r.StoneProducts = ra.StoneProducts.get(i);
                r.UnprocessedMaterials = ra.UnprocessedMaterials.get(i);
                
                r.ConcreateMixesf = ra.ConcreateMixesf.get(i);
                r.ProcessedMaterialsf = ra.ProcessedMaterialsf.get(i);
                r.RecycledProductsf = ra.RecycledProductsf.get(i);
                r.RoweAggregagesf = ra.RoweAggregagesf.get(i);
                r.SemiProcessedMaterialsf = ra.SemiProcessedMaterialsf.get(i);
                r.StoneProductsf = ra.StoneProductsf.get(i);
                r.UnprocessedMaterialsf = ra.UnprocessedMaterialsf.get(i);
                
                r.ConcreateMixesq = ra.ConcreateMixesq.get(i);
                r.ProcessedMaterialsq = ra.ProcessedMaterialsq.get(i);
                r.RecycledProductsq = ra.RecycledProductsq.get(i);
                //r.RoweAggregagesq = ra.RoweAggregagesq.get(i);
                r.SemiProcessedMaterialsq = ra.SemiProcessedMaterialsq.get(i);
                r.StoneProductsq = ra.StoneProductsq.get(i);
                r.UnprocessedMaterialsq = ra.UnprocessedMaterialsq.get(i);
               
                
                rds.add(r);
                System.debug('r.yearMonth --->' + r.yearMonth);
                System.debug('r.ConcreateMixes --->' + r.ConcreateMixes);
                System.debug('r.RecycledProducts --->' + r.RecycledProducts);
                System.debug('r.RoweAggregages --->' + r.RoweAggregages);
                System.debug('r.SemiProcessedMaterials --->' + r.SemiProcessedMaterials);
                System.debug('r.StoneProducts --->' + r.StoneProducts);
                System.debug('r.UnprocessedMaterials --->' + r.UnprocessedMaterials);
                
                System.debug('r.ConcreateMixesf --->' + r.ConcreateMixesf);
                System.debug('r.RecycledProductsf --->' + r.RecycledProductsf);
                System.debug('r.RoweAggregagesf --->' + r.RoweAggregagesf);
                System.debug('r.SemiProcessedMaterialsf --->' + r.SemiProcessedMaterialsf);
                System.debug('r.StoneProductsf --->' + r.StoneProductsf);
                System.debug('r.UnprocessedMaterialsf --->' + r.UnprocessedMaterialsf);
                
                System.debug('r.ConcreateMixesq --->' + r.ConcreateMixesq);
                System.debug('r.RecycledProductsq --->' + r.RecycledProductsq);
                System.debug('r.RoweAggregagesq --->' + r.RoweAggregagesq);
                System.debug('r.SemiProcessedMaterialsq --->' + r.SemiProcessedMaterialsq);
                System.debug('r.StoneProductsq --->' + r.StoneProductsq);
                System.debug('r.UnprocessedMaterialsq --->' + r.UnprocessedMaterialsq);
        }
        
        
    }
    
    public List<Product2> getProductList(){
       return this.productList;
    }
    
    
    
    public PageReference showProductChart() {
        System.debug('Show Chart');
        String productName = Apexpages.currentPage().getParameters().get('firstParam');
        System.debug('Show Product Chart ' + productName);
        return null; 
    }
    
    
    @isTest (SeeAllData=true)
    static void testReport() {
        ForecastDispatchSalesQuotaReport fr = new ForecastDispatchSalesQuotaReport();
        fr.processReport();
        fr.showProductChart();
        fr.getProductList();
        fr.getRds();
        fr.getProductMap();
        fr.getProductList();
        List<selectOption>  pnp = fr.ProductNameOptions;
        
        
        
        
    }
}