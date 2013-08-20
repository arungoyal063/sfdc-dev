trigger UpdateValueToSGQ on MACS_Data__c (after insert, after update) {

    List<MACS_Data__c> oList;
    List<Sales_Group_Quota__c> sgq = new List<Sales_Group_Quota__c>();
    List<Sales_Group_Quota__c> finalList = new List<Sales_Group_Quota__c>();
    List<Sales_Group_Quota__c> sgqToDelete = new List<Sales_Group_Quota__c>();
    
    List<String> SGList = new List<String>();
    List<String> YrList = new List<String>();
    
    //Map<String, List<Sales_Group_Quota__c>> quotaMap = new Map<String, List<Sales_Group_Quota__c>>();
    Map<String, Sales_Group_Quota__c> quotaMap = new Map<String, Sales_Group_Quota__c>();
    
    String mode;
    
    if(Trigger.isUpdate)
        mode = 'Update';
    else
        mode = 'Insert';
    Decimal oldValue;
    Decimal newValue;
    
    //Get List of Sales Group Id and Yr from Order Shipments
    for(MACS_Data__c o: Trigger.new)
    {
        System.debug('In the first loop:::');
        if(mode=='Update')
            oldValue = Trigger.oldmap.get(o.id).Dlrs__c;
        else
            oldValue = 0;
        newValue = o.Dlrs__c;
        System.debug('oldValue:::'+oldValue);
        System.debug('newValue:::'+newValue);
        if(oldValue != newValue)
        {
            SGList.add(String.valueOf(o.Carp_DM__c));
            YrList.add(String.valueOf(o.Cal_Year__c));
        }
    }
    
    System.debug('SGList:::'+SGList);
    System.debug('YrList:::'+YrList);
    
    sgq = [Select Actual_MACS__c, Actual__c, Year__c, X11th_p_Total__c, Chairman_s_Club_Goal__c, Sales_Group_Id_New__c, Stretch_Goal__c, Super_Stretch_Goal__c from Sales_Group_Quota__c where Year__c in :YrList AND Sales_Group_Id_New__c in :SGList];
    
    System.debug('sgq:::'+sgq);
    if(sgq.size()>0)
    {
        for(Sales_Group_Quota__c s: sgq)
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
        
        for(MACS_Data__c o: Trigger.new)
        {
            System.debug('In the third loop:::');
            String yr = String.valueOf(o.Cal_Year__c);
            String SGId = String.valueOf(o.Carp_DM__c);
            if(mode=='Update')
                oldValue = Trigger.oldmap.get(o.id).Dlrs__c;
            else
                oldValue = 0;
            newValue = o.Dlrs__c;
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
                Sales_Group_Quota__c sgq1 = quotaMap.get(key);
                if(sgq1 != null)
                {
                    sgq1.Actual_MACS__c = (sgq1.Actual_MACS__c - oldValue) + newValue;
                    quotaMap.put(key,sgq1);
                }
                else
                {
                    Sales_Group_Quota__c sg = new Sales_Group_Quota__c();
                    sg.Actual_MACS__c = o.Dlrs__c;
                    sg.Sales_Group_Id_New__c = o.Carp_DM__c;
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
                //User u = [Select Id, Carp_DM__c from User where Carp_DM__c = :SGId LIMIT 1];
                Sales_Group_Quota__c sg = new Sales_Group_Quota__c();
                sg.Actual_MACS__c = o.Dlrs__c;
                sg.Sales_Group_Id_New__c = o.Carp_DM__c;
                sg.Year__c = yr;
                sg.X11th_p_Total__c = 0;
                sg.Chairman_s_Club_Goal__c = 0;
                sg.Stretch_Goal__c = 0;
                sg.Super_Stretch_Goal__c = 0;
                quotaMap.put(key,sg);
            }
        }
    }
    else
    {
        if(SGList.size()>0 && YrList.size() > 0) 
        {
            for(MACS_Data__c o: Trigger.new)
            {
                System.debug('No Matching records found in SGQ:');
                System.debug('o.Dlrs__c:'+o.Dlrs__c);
                System.debug('o.Carp_DM__c:'+o.Carp_DM__c);
                //User u = [Select Id, Carp_DM__c from User where Carp_DM__c = :SGId LIMIT 1];
                Sales_Group_Quota__c sg = new Sales_Group_Quota__c();
                sg.Actual_MACS__c = o.Dlrs__c;
                sg.Sales_Group_Id_New__c = o.Carp_DM__c;
                sg.Year__c = String.valueOf(o.Cal_Year__c);
                sg.X11th_p_Total__c = 0;
                sg.Chairman_s_Club_Goal__c = 0;
                sg.Stretch_Goal__c = 0;
                sg.Super_Stretch_Goal__c = 0;
                String key = sg.Year__c +''+sg.Sales_Group_Id_New__c;
                quotaMap.put(key,sg);
            }
        }
    }
    for(String s: quotaMap.keySet())
    {
        finalList.add(quotaMap.get(s));
    }
    
    if(sgqToDelete.size() > 0)
        delete sgqToDelete;
        
    if(finalList.size() > 0)
    {
        try{upsert finalList;}
        catch(System.Exception e){System.debug('Error in upsert MACS Data.'+e.getMessage());}
    }
}