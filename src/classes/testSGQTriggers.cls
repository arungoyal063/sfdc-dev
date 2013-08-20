@isTest(seeAllData=true)

public class testSGQTriggers{

    public static testMethod void unitTest1() 
    {
    	test.startTest();
        //Sales_Group_Quota__c sgq = new Sales_Group_Quota__c(Sales_Group_Id_New__c=243,)
        MACS_Data__c macs = new MACS_Data__c();
        macs.RetailerId__c = 1234;
        macs.Cal_Month__c=2;
        macs.Cal_Year__c='2012';
        macs.Carp_DM__c = '243';
        macs.Carp_Reg__c='1';
        macs.Dlrs__c = 200;
        insert macs;
        
        MACS_Data__c macs2 = new MACS_Data__c();
        macs2.RetailerId__c = 1234;
        macs2.Cal_Month__c=2;
        macs2.Cal_Year__c='2012';
        macs2.Carp_DM__c = '21111';
        macs2.Carp_Reg__c='1';
        macs2.Dlrs__c = 200;
        insert macs2;
        
        delete macs2;
        
        Order__c order = new Order__c();
        order.Account_Type__c = 'Test';
        order.Comment__c = 'test';
        insert order;
        
        orderline__c ol = new orderline__c();
        ol.Invoice_Line_Number__c = '123';
        ol.Item_Level__c = 'Test';
        ol.Net_Total_Value__c = 1000.00;
        ol.Order__c = order.Id;
        insert ol;
                
        Order_Shipment__c os = new Order_Shipment__c();
        os.Billing_Date__c = System.Today();
        os.Delivery_Create_Date__c = System.Today().addDays(3);
        os.Document_Number__c = '123';
        os.Net_Total_Value__c = 1000;
        os.Order_Line__c = ol.Id;
        insert os;
        test.stopTest();
    }
}