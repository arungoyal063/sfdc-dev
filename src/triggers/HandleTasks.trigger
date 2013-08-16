/**
    * HandleTasks - <description>
    * @author: Rainmaker Admin
    * @version: 1.0
*/

trigger HandleTasks on Task bulk (after update) {
    
    Set<String> accntIds = new Set<String>();
    List<Account> accnts;
    try{
    
        String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
        System.debug(' *** accountPrefix: ' +  accountPrefix);
        for(Task t : trigger.new){
            if(t.Status == 'Completed'){
                System.debug(' *** t.WhatId: ' +  t.WhatId);
                if(((String)t.WhatId).startsWith(accountPrefix)){
                    if(!accntIds.contains(t.WhatId)){
                        accntIds.add(t.WhatId);
                    }
                }
            }
         }
        
        System.debug('*** account count: ' + accntIds.size());
        if(accntIds.size() > 0){
            //accnts = [Select Id, Name, Company_Tier__c from Account where Id IN: accntIds];
            Map<Id, Account> entries = new Map<Id, Account>([Select Id, Name, Company_Tier__c from Account where Id IN: accntIds]);
            
            if(entries.size() > 0){
            
                List<Task> newTasks = new List<Task>();
                
                for(Task t : trigger.new){
                    if(t.Status == 'Completed'){
                        if(((String)t.WhatId).startsWith(accountPrefix)){
                            
                            if((entries.get(t.WhatId).Company_Tier__c == '1') || (entries.get(t.WhatId).Company_Tier__c == '2') || (entries.get(t.WhatId).Company_Tier__c == '3')){
                            
                                Task newTask = new Task();
                                newTask.Subject = 'Outreach';
                                newTask.WhatId = entries.get(t.WhatId).id;
                                newTask.OwnerId = t.OwnerId;
                                
                                Date dueDate = null;
                                
                                if(entries.get(t.WhatId).Company_Tier__c == '1'){
                                    dueDate = Date.today();
                                    newTask.ActivityDate = dueDate.addMonths(6);
                                }
                                
                                if(entries.get(t.WhatId).Company_Tier__c == '2'){
                                    dueDate = Date.today();
                                    newTask.ActivityDate = dueDate.addMonths(3);
                                }
                                
                                if(entries.get(t.WhatId).Company_Tier__c == '3'){
                                    dueDate = Date.today();
                                    newTask.ActivityDate = dueDate.addMonths(1);
                                }
                            
                                newTasks.add(newTask);
                            
                            }
                            
                        }
                    }
                 }
                
                System.debug('*** newTasks count: ' + newTasks.size());
                if(newTasks.size() > 0){
                    insert newTasks;
                }   
            }
        }
        
    }catch(Exception ex){
        
    }


}