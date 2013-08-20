trigger UpdateTheNetValueToSGQ on Order_Shipment__c (after insert, after update) {

    List<Order_Shipment__c> oList;
    List<Sales_Group_Quota__c> sgqList = new List<Sales_Group_Quota__c>();
    List<Sales_Group_Quota__c> finalList = new List<Sales_Group_Quota__c>();
    List<Sales_Group_Quota__c> sgqToDelete = new List<Sales_Group_Quota__c>();
    //Check if the value of Net_Total_Value__c is changed
    
    Set<String> SGList = new Set<String>();
    Set<String> YrList = new Set<String>();
    
    Map<String, Sales_Group_Quota__c> quotaMap = new Map<String, Sales_Group_Quota__c>();
    
    String mode;
    
    if(Trigger.isUpdate)
        mode = 'Update';
    else
        mode = 'Insert';
    Decimal oldValue;
    Decimal newValue;
    
    //Get List of Sales Group Id and Yr from Order Shipments
    for(Order_Shipment__c o: Trigger.new)
    {
        System.debug('In the first loop');
        if(mode=='Update')
            oldValue = Trigger.oldmap.get(o.id).Net_Total_Value__c;
        else
            oldValue = 0;
        newValue = (o.Net_Total_Value__c == null ? 0 : o.Net_Total_Value__c);
        System.debug('oldValue:'+oldValue);
        System.debug('newValue:'+newValue);
        //if(oldValue != newValue)
        {
        	if(o.Sales_Group_Id__c != null && o.Sales_Group_Id__c != '')
            {
            	SGList.add(String.valueOf(o.Sales_Group_Id__c));
	            if(o.Billing_Date__c != null)
	                YrList.add(String.valueOf(o.Billing_Date__c.year()));
	            else 
	                YrList.add(String.valueOf(System.Today().year()));
            }
        }
    }
    
    System.debug('SGList:'+SGList);
    System.debug('YrList:'+YrList);
    
    sgqList = [Select Actual_MACS__c, Actual__c, Year__c, X11th_p_Total__c, Chairman_s_Club_Goal__c, Sales_Group_Id_New__c, Stretch_Goal__c, Super_Stretch_Goal__c from Sales_Group_Quota__c where Year__c in :YrList AND Sales_Group_Id_New__c in :SGList];
    
    System.debug('sgqList:'+sgqList);
    if(sgqList.size()>0)
    {
        for(Sales_Group_Quota__c s: sgqList)
        {
            System.debug('In the second loop:::');
            String key = s.Year__c + '~' + s.Sales_Group_Id_New__c;
            Sales_Group_Quota__c tmp;
            System.debug('quotaMap:::'+quotaMap);
            if(quotaMap.containsKey(key))
            {
                tmp = quotaMap.get(key);
                tmp.Actual_MACS__c = (tmp.Actual_MACS__c > 0 ? tmp.Actual_MACS__c : 0)+ (s.Actual_MACS__c == null ? 0 : s.Actual_MACS__c);
                tmp.Actual__c = (tmp.Actual__c > 0 ? tmp.Actual__c : 0) + (s.Actual__c == null ? 0 : s.Actual__c);
                tmp.X11th_p_Total__c = (tmp.X11th_p_Total__c > 0 ? tmp.X11th_p_Total__c : 0) + (s.X11th_p_Total__c == null ? 0 : s.X11th_p_Total__c);
                tmp.Chairman_s_Club_Goal__c = (tmp.Chairman_s_Club_Goal__c > 0 ? tmp.Chairman_s_Club_Goal__c : 0) + (s.Chairman_s_Club_Goal__c == null ? 0 : s.Chairman_s_Club_Goal__c);
                tmp.Stretch_Goal__c = (tmp.Stretch_Goal__c > 0 ? tmp.Stretch_Goal__c : 0) + (s.Stretch_Goal__c == null ? 0 : s.Stretch_Goal__c);
                tmp.Super_Stretch_Goal__c = (tmp.Super_Stretch_Goal__c > 0 ? tmp.Super_Stretch_Goal__c : 0) + (s.Super_Stretch_Goal__c == null ? 0 : s.Super_Stretch_Goal__c);
                sgqToDelete.add(s);
            }
            else
            {
                tmp = s;
            }
            quotaMap.put(key,tmp);
        }
        System.debug('quotaMap:'+quotaMap);
        
        for(Order_Shipment__c o: Trigger.new)
        {
            System.debug('In the third loop');
            String yr = String.valueOf(o.Billing_Date__c.year());
            String SGId = String.valueOf(o.Sales_Group_Id__c);
            if(mode=='Update')
                oldValue = Trigger.oldmap.get(o.id).Net_Total_Value__c;
            else
                oldValue = 0;
            newValue = o.Net_Total_Value__c;
            System.debug('mode:' + mode);
            System.debug('yr:' + yr);
            System.debug('SGId:' + SGId);
            System.debug('oldValue:' + oldValue);
            System.debug('newValue:' + newValue);
            
            if(oldValue == null)
                oldValue = 0;
            String key = yr +'~'+SGId;
            if(quotaMap.containsKey(key))
            {
                System.debug('Map Contains Key:'+key);
                Sales_Group_Quota__c sgq = quotaMap.get(key);
                if(sgq.Actual__c != null)
                {
                    sgq.Actual__c = (sgq.Actual__c - oldValue) + newValue;
                    //sgq.Actual__c = sgq.Actual__c + newValue;
                    quotaMap.put(key,sgq);
                }
                else
                {
                  	Sales_Group_Quota__c sg = new Sales_Group_Quota__c();
                    sg.Actual__c = o.Net_Total_Value__c;
                    sg.Sales_Group_Id_New__c = o.Sales_Group_Id__c;
                    sg.Year__c = yr;
                    sg.X11th_p_Total__c = 0;
                    sg.Chairman_s_Club_Goal__c = 0;
                    sg.Stretch_Goal__c = 0;
                    sg.Super_Stretch_Goal__c = 0;
                    quotaMap.put(key,sg);
                }
            }
            else
            {
                System.debug('Map Does NOT Contains Key:'+key);
                //User u = [Select Id, Sales_Group_Id__c from User where Sales_Group_Id__c = :SGId LIMIT 1];
                Sales_Group_Quota__c sg = new Sales_Group_Quota__c();
                sg.Actual__c = o.Net_Total_Value__c;
                sg.Sales_Group_Id_New__c = o.Sales_Group_Id__c;
                sg.Year__c = yr;
                sg.X11th_p_Total__c = 0;
                sg.Chairman_s_Club_Goal__c = 0;
                sg.Stretch_Goal__c = 0;
                sg.Super_Stretch_Goal__c = 0;
                quotaMap.put(key, sg);
            }
        }
    }
    else
    {
    	if(SGList.size()>0 && YrList.size() > 0) 
        {
        	for(Order_Shipment__c o: Trigger.new)
	        {
	            System.debug('No Matching records found in SGQ:');
	            System.debug('o.Net_Total_Value__c:'+o.Net_Total_Value__c);
	            System.debug('o.Sales_Group_Id__c:'+o.Sales_Group_Id__c);
	            //User u = [Select Id, Sales_Group_Id__c from User where Sales_Group_Id__c = :SGId LIMIT 1];
	            Sales_Group_Quota__c sg = new Sales_Group_Quota__c();
	            sg.Actual__c = o.Net_Total_Value__c;
	            sg.Sales_Group_Id_New__c = o.Sales_Group_Id__c;
	            sg.Year__c = String.valueOf(o.Billing_Date__c.year());
	            sg.X11th_p_Total__c = 0;
	            sg.Chairman_s_Club_Goal__c = 0;
	            sg.Stretch_Goal__c = 0;
	            sg.Super_Stretch_Goal__c = 0;
	            String key = sg.Year__c+'~'+sg.Sales_Group_Id_New__c;
	            quotaMap.put(key, sg);
	        }
        }
    }
    for(String s : quotaMap.keySet())
    {
        finalList.add(quotaMap.get(s));
    }
    
    if(sgqToDelete.size() > 0)
        delete sgqToDelete;
        
    if(finalList.size() > 0)
    {
        try{upsert finalList;}
        catch(System.Exception e){System.debug('Error in upsert Order Shipment Data in SGQ.'+e.getMessage());}
    }
}