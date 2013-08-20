trigger createBillingOnDeposit on Appirio_PSAe__Proj__c (after insert, after update,before insert, before update ) {
    //Deposit__c
    Boolean isDepositAmountFound = true;
    
    System.debug('>>>>>>Ajay>>>>>'); 
  map<Id,Account> objAccounts1 = new map<Id,Account>([SELECT Name FROM Account WHERE Id =: Trigger.new[0].Appirio_PSAe__Account__c]);
  
  if(!(objAccounts1.get(Trigger.new[0].Appirio_PSAe__Account__c).Name.containsIgnoreCase('rainmaker'))){     
    if(Trigger.isBefore && Trigger.isInsert){
            ID oppId = Trigger.new[0].Appirio_PSAe__Opportunity__c;
        if(null == oppId){
            Trigger.new[0].addError('Pelase select an opportunity!');        
        }else{
            map<Id,Opportunity> mapOpportunities = new map<Id,Opportunity>([SELECT Deposit_Amount__c, name, id FROM Opportunity WHERE id =:oppId]);
            if(null == mapOpportunities.get(Trigger.new[0].Appirio_PSAe__Opportunity__c).Deposit_Amount__c && Trigger.new[0].Deposit__c == null){
            //Trigger.new[0].addError('Opportunity do not have any Deposit Amount!');
                 isDepositAmountFound =false;   
            }else{
                if(Trigger.new[0].Deposit__c == null)
                Trigger.new[0].Deposit__c = - mapOpportunities.get(Trigger.new[0].Appirio_PSAe__Opportunity__c).Deposit_Amount__c;          
            }
        } 
    }
    if(Trigger.isAfter && Trigger.isInsert && isDepositAmountFound){
            ID oppId = Trigger.new[0].Appirio_PSAe__Opportunity__c;
        map<Id,Opportunity> mapOpportunities = new map<Id,Opportunity>([SELECT Deposit_Amount__c, name, id FROM Opportunity WHERE id =:oppId]);
         
        System.debug('mapOpportunities...........'+mapOpportunities);
        System.debug('Trigger.newMap.keySet()...........'+Trigger.newMap.keySet());
        for(Appirio_PSAe__Proj__c proj : Trigger.new)
        {
            if(proj.Appirio_PSAe__Opportunity__c != null)
            {
                Opportunity op = mapOpportunities.get(proj.Appirio_PSAe__Opportunity__c);//[SELECT Deposit_Amount__c, name, id FROM Opportunity WHERE id =: proj.Appirio_PSAe__Opportunity__c];
               System.debug('............'+op); 
                if(op != null){
                
                    if(op.Deposit_Amount__c > 0 || proj.Deposit__c > 0)
                    {
                        Billing_Line_Item__c bill = new Billing_Line_Item__c();
                        bill.Project__c = proj.id;
                        bill.Hours__c =1;
                       // bill.Rate_per_Hour__c = -1000;
                        //bill.Rate_per_Hour__c = proj.deposit__c;
                        if(op.Deposit_Amount__c > 0)
                        bill.Rate_per_Hour__c = - mapOpportunities.get(proj.Appirio_PSAe__Opportunity__c).Deposit_Amount__c;
                        else
                        bill.Rate_per_Hour__c = - proj.deposit__c;
                        bill.Notes__c = 'Project Deposit';
                        bill.Invoiced__c = 'Not Invoiced';
                        // added code
                        System.debug('bill.Rate_per_Hour__c............'+bill.Rate_per_Hour__c+'.............'+proj.deposit__c);
                        
                        List<Billing_Line_Item__c> blis = proj.Billing_Line_Items__r;//[SELECT id, Project__c, Notes__c FROM Billing_Line_Item__c WHERE Project__c =: proj.id];
                        system.debug('getting the value of blis'+blis);
                        boolean projectDeposited = false;
                        for(Billing_Line_Item__c oldBill : blis){   
                            if(oldBill.Notes__c == 'Project Deposit'){
                                projectDeposited = true;
                            }                                
                        }
                        
                        if(!projectDeposited){
                           insert(bill);
                           System.debug('projectDeposited...'+projectDeposited);
                        }
                    }
                }
            }
        }
    }
  }  
    /*@Description of requirement:Close a Project as soon as the Billable Hours Remaining field hit’s 0 (except the project is related to Rainmaker Account)*/
    System.debug('.....master execution');
    if(Trigger.isBefore)
    //if(Trigger.isAfter)
    {
        // added code
        String projectID;
        boolean flag = false;
        list<Billing_Line_Item__c> billList = new list<Billing_Line_Item__c>();
        
  //    list<Appirio_PSAe__Timecard__c> timeCardList = new list<Appirio_PSAe__Timecard__c>();
  //    list<Id> timeCardIds = new list<Id>();
         
          
        Profile pf = [SELECT Id,Name FROM Profile WHERE Id =:Userinfo.getProfileId() limit 1]; 
        
        list<Appirio_PSAe__Assignment__c> toUpdateAssignment = new list<Appirio_PSAe__Assignment__c>();
        list<Appirio_PSAe__Proj__c> toUpdateProject = new list<Appirio_PSAe__Proj__c>();
        
        set<Id> accountIds = new Set<Id>();
        for(Appirio_PSAe__Proj__c proj : Trigger.new){
            accountIds.add(proj.Appirio_PSAe__Account__c);
            projectID = proj.Id;
        }
        
     // added code 
    billList =  [select Hours__c,Invoice__c,Invoiced__c,Line_Item_Charge__c,Project__c,Timecard__c,Notes__c from Billing_Line_Item__c where Project__c =: projectID and Invoiced__c != 'Invoiced'];
    System.debug('billList......'+billList);
    if(billList.isEmpty())
    {
        flag = true;
        System.debug('flag.....'+flag);
    }   
        /* commented code for time card
        for(Billing_Line_Item__c bill:billList) {
             timeCardIds.add(bill.Timecard__c);
        }
        if(timeCardIds.size() == billList.size())
        {
            timeCardList = [select Appirio_PSAe__SFDC_Projects__c,Appirio_PSAe__Status__c from Appirio_PSAe__Timecard__c where id =: timeCardIds  and Appirio_PSAe__SFDC_Projects__c =: projectID];
        }
        System.debug('timeCardList.......'+timeCardList);
        for(Appirio_PSAe__Timecard__c timeCard:timeCardList) {
             if(timeCard.Appirio_PSAe__Status__c != 'Billed')
             {
                flag = false;   
             }
             else if(timeCard.Appirio_PSAe__Status__c == 'Billed')
             {
                flag = true;
             }
        }
        */
    
        
        map<Id,Account> objAccounts = new map<Id,Account>([SELECT Name FROM Account WHERE Id IN: accountIds]);
        
        for(Appirio_PSAe__Proj__c app:Trigger.new){
            if((objAccounts != null && !(objAccounts.get(app.Appirio_PSAe__Account__c).Name.containsIgnoreCase('rainmaker') || (objAccounts.get(app.Appirio_PSAe__Account__c).Name.containsIgnoreCase('Rainmaker'))))){
                System.debug('objAccounts.get(app.Appirio_PSAe__Account__c).Name........'+objAccounts.get(app.Appirio_PSAe__Account__c).Name);
                System.debug('Issue......'+objAccounts.get(app.Appirio_PSAe__Account__c).Name.Contains('rainmaker'));
                if(app.Appirio_PSAe__Billable_Hours_Remaining__c <= 0 && flag){
                   // app.Appirio_PSAe__Project_Stage__c = 'Cancelled';
                   if(Trigger.isUpdate && pf.Name == 'System Administrator' && Trigger.oldMap.get(app.Id).Appirio_PSAe__Project_Stage__c == 'Completed'){
                   System.debug('......in if');
                   }else{
                        app.Appirio_PSAe__Project_Stage__c = 'Completed';
                       //  toUpdateProject.add(app);
                          System.debug('......in else');
                    }
                   
                    toUpdateProject.add(app);
                    for(Appirio_PSAe__Assignment__c assig:app.Appirio_PSAe__Assignments__r){
                        assig.Appirio_PSAe__Status__c = 'Closed';
                        toUpdateAssignment.add(assig);
                    }
                }
            }
            if(Trigger.isUpdate && pf.Name != 'System Administrator' && (Trigger.oldMap.get(app.Id).Appirio_PSAe__Project_Stage__c =='Cancelled' || Trigger.oldMap.get(app.Id).Appirio_PSAe__Project_Stage__c =='Completed') &&(app.Appirio_PSAe__Project_Stage__c == 'In Progress' || app.Appirio_PSAe__Project_Stage__c == 'Planning')){
               app.Appirio_PSAe__Project_Stage__c.addError('You are not authorized to reopen this Project. Please contact your Administrator!');
             //  app.Appirio_PSAe__Project_Stage__c.addError('There are not enough hours left on this project to create an assignment contact your administrator!');
            }
        }
        
        if(!toUpdateAssignment.isEmpty()){
            //update toUpdateProject;
            update toUpdateAssignment;
        }
    }
}