trigger updateSalesGroupOnSGQ on Sales_Group_Quota__c (before insert, before update) {
    
    Set<Id> sgqIdSet = new Set<Id>();
    
    for(Sales_Group_Quota__c s : Trigger.new)
    {
        //if(Trigger.isInsert || (Trigger.isUpdate && s.Sales_Group_Id_New__c != Trigger.oldMap.get(s.Id).Sales_Group_Id_New__c))
            sgqIdSet.add(s.Id);
    }
    if(sgqIdSet.size() > 0)
    {
        //List <Sales_Group_Quota__c> listQuota = [Select Sales_Group_Id_New__c from Sales_Group_Quota__c where Id in :sgqIdSet];

        Map<String, Id> queueMap = new Map<String, Id>();
        List<Group> groupList = [Select Id, Name FROM Group where Type='Queue'];
        List<User> userList = [select SALES_GROUP_ID__C, SALES_OFFICE__C from User where SALES_OFFICE__C != NULL AND SALES_OFFICE__C != ''];
        
        Map<String, String> mapNameRegion = new Map<String, String>();
        Map<String, String> regionMap = new Map<String,String>();
        
        for(User u : userList)
            {regionMap.put(u.SALES_GROUP_ID__C, u.SALES_OFFICE__C);}
        
        Map<String, String> mapCodeName = new Map<String, String>();
        
        for(Group q : groupList)
        {
            String SalesGroupCode = q.Name.substring(0,3);
            String SalesGroupName = q.Name.substring(3);
          
            mapCodeName.put(SalesGroupCode,SalesGroupName);
            queueMap.put(SalesGroupCode, q.Id);
        }
        
        System.debug('mapCodeName:'+mapCodeName);
        System.debug('regionMap:'+regionMap);
        
        for(Sales_Group_Quota__c s : Trigger.new)
        {
            if(sgqIdSet.contains(s.Id))
            {
                if(mapCodeName.containsKey(s.Sales_Group_Id_New__c))
                    s.Sales_Group__c = mapCodeName.get(s.Sales_Group_Id_New__c);
                else
                    s.Sales_Group__c = 'UNDEFINED';
                
                if(regionMap.containsKey(s.Sales_Group_Id_New__c))
                    s.Region_New__c = regionMap.get(s.Sales_Group_Id_New__c);
                else
                    s.Region_New__c = 'UNDEFINED';
            }
            if(queueMap.containsKey(s.Sales_Group_Id_New__c))
            {
                s.OwnerId = queueMap.get(s.Sales_Group_Id_New__c);
            }
        }
    }
}