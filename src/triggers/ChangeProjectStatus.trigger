trigger ChangeProjectStatus on Appirio_PSAe__Timecard__c (before insert,before update) {
    
    try{
    System.debug('test on Assignment');
    String AssignmentID;
    List<Appirio_PSAe__Timecard__c> timeList = new List<Appirio_PSAe__Timecard__c>();
    Appirio_PSAe__Assignment__c assignmentObj;
    decimal totalTimeCardHours = 0;
    Map<Id,List<Appirio_PSAe__Timecard__c>> projectTimecardMap = new Map<Id,List<Appirio_PSAe__Timecard__c>>();
    Map<Id,List<Appirio_PSAe__Timecard__c>> assignmetTimecardMap = new Map<Id,List<Appirio_PSAe__Timecard__c>>();
    List<Appirio_PSAe__Assignment__c> parentAssignmentList = new List<Appirio_PSAe__Assignment__c>();
    List<Appirio_PSAe__Proj__c> parentProjectList = new List<Appirio_PSAe__Proj__c>();
    //Map<Id,Appirio_PSAe__Assignment__c> parentAssignmentMap;
    String testoo = '';
    
    if(Trigger.isInsert){
    for(Appirio_PSAe__Timecard__c tc : Trigger.new){
        /*Project Timecard Map Preperation*/
        List<Appirio_PSAe__Timecard__c> temptimecardList = projectTimecardMap.get(tc.Appirio_PSAe__SFDC_Projects__c);
        if(null==temptimecardList){
            temptimecardList = new List<Appirio_PSAe__Timecard__c>();
            temptimecardList.add(tc);
            projectTimecardMap.put(tc.Appirio_PSAe__SFDC_Projects__c, temptimecardList);
        }else{
            temptimecardList.add(tc);           
        }
        /*Assignment Timecard Map preperation*/
        List<Appirio_PSAe__Timecard__c> temptimecardList2 = assignmetTimecardMap.get(tc.Appirio_PSAe__Assignment__c);
        testoo += tc.Appirio_PSAe__Assignment__c;
        if(null==temptimecardList2){
            temptimecardList2 = new List<Appirio_PSAe__Timecard__c>();
            temptimecardList2.add(tc);
            assignmetTimecardMap.put(tc.Appirio_PSAe__Assignment__c, temptimecardList2);
            
        }else{
            temptimecardList2.add(tc);          
        } 
        
        try
        {
            List<Appirio_PSAe__Assignment__c> assignmentList = new List<Appirio_PSAe__Assignment__c>(); 
            assignmentList = [select Non_Billable_Assignment__c,Id,Name from Appirio_PSAe__Assignment__c where id=: tc.Appirio_PSAe__Assignment__c];
            if(assignmentList.size() > 0 && assignmentList !=null)
            {
                if(assignmentList[0].Non_Billable_Assignment__c  == true){
                System.debug('1....Non Billable');
                 tc.Appirio_PSAe__Bill_To__c = 'Non Billable'; 
                }   
            }
       }
       catch(Exception ex)
       {
         System.debug('exception....'+ex.getMessage());
       }
        // added code
        
        
        
        /*
        if(tc.Appirio_PSAe__Assignment__r.Non_Billable_Assignment__c  == true){
            System.debug('1....Non Billable');
             tc.Appirio_PSAe__Bill_To__c = 'Non Billable'; 
        }else{
            System.debug('1.... Billable');
            tc.Appirio_PSAe__Bill_To__c = 'Billable';
        }
        */
        
    }
    /*Get all the Project*/
    Map<Id,Appirio_PSAe__Proj__c> parentProjectMap = new Map<Id,Appirio_PSAe__Proj__c>( 
                            [SELECT Name, id, Appirio_PSAe__Hours_Allocated__c, Non_Billable_Assigned_Hours__c  , Total_Time_Card__c  , 
                            Total_NonBillable_Timecard_Hours__c,Appirio_PSAe__Account__c  FROM  Appirio_PSAe__Proj__c
                                                     WHERE id =: projectTimecardMap.keySet() AND Appirio_PSAe__Project_Stage__c !='Completed' 
                                                     AND Appirio_PSAe__Project_Stage__c !='Cancelled' ]);
                                                
    if(parentProjectMap.isEmpty()){
        if(!Trigger.new[0].Appirio_PSAe__SFDC_Projects__r.Name.containsIgnoreCase('Rainmaker'))
        Trigger.new[0].addError('No Open Project found for the Timecard. Project Name:'+Trigger.new[0].Appirio_PSAe__SFDC_Projects__r.Name);
    }else{
        parentProjectList =  parentProjectMap.values();
    }
    for(Appirio_PSAe__Proj__c tempProj: parentProjectList){
        List<Appirio_PSAe__Timecard__c> temptimecardList = projectTimecardMap.get(tempProj.Id);
        Decimal totalTChours = tempProj.Total_Time_Card__c - tempProj.Total_NonBillable_Timecard_Hours__c ;
        Decimal totalTCNonhours = tempProj.Total_NonBillable_Timecard_Hours__c;
        for(Appirio_PSAe__Timecard__c tempTimeC: temptimecardList){
            if(tempTimeC.Appirio_PSAe__Bill_To__c =='Billable'){
                if(Trigger.isInsert){
                    totalTChours += tempTimeC.Appirio_PSAe__Week_Total_Hrs__c;
                }else{
                    totalTChours += Trigger.newMap.get(tempTimeC.Id).Appirio_PSAe__Week_Total_Hrs__c - Trigger.oldMap.get(tempTimeC.Id).Appirio_PSAe__Week_Total_Hrs__c;
                }
                if(totalTChours >tempProj.Appirio_PSAe__Hours_Allocated__c ){
                    if(!tempProj.Name.containsIgnoreCase('Rainmaker'))
                    tempTimeC.addError('Total Billable TimeCard Hours Cannot Be More Than The Total Billable Project Hours for '+tempProj.Name+'.');
                }
            }else{
                if(Trigger.isInsert){
                    totalTCNonhours += tempTimeC.Appirio_PSAe__Week_Total_Hrs__c;
                }else{
                    totalTCNonhours += Trigger.newMap.get(tempTimeC.Id).Appirio_PSAe__Week_Total_Hrs__c - Trigger.oldMap.get(tempTimeC.Id).Appirio_PSAe__Week_Total_Hrs__c;
                }
                /*if(totalTCNonhours >tempProj.Non_Billable_Assigned_Hours__c ){
                    if(!tempProj.Name.containsIgnoreCase('Rainmaker'))
                    tempTimeC.addError('Total Non Billable TimeCard Hours Cannot Be More Than The Total Non Billable Project Hours for '+tempProj.Name+'.');
                }*/
            }
        }
    }
    /*Get all the Assignments*/
    Map<Id,Appirio_PSAe__Assignment__c> parentAssignmentMap = new Map<Id,Appirio_PSAe__Assignment__c>(
            [SELECT Id,Name,  Appirio_PSAe__Remaining_Billable_Hours__c,Non_Billable_Assignment__c,Appirio_PSAe__End_Date__c, 
            Appirio_PSAe__Actual_Billable_Hours__c,Appirio_PSAe__Total_Assignment_Hours__c,Appirio_PSAe__Description__c        
                    FROM Appirio_PSAe__Assignment__c
                    WHERE id =: assignmetTimecardMap.keySet()  AND Appirio_PSAe__Status__c!='Closed']);
    if(null==parentAssignmentMap || parentAssignmentMap.isEmpty()){
        //Trigger.new[0].addError('No Open Assignment found for the '+testoo+' Timecard.'+parentAssignmentMap+'<><>'+assignmetTimecardMap.keySet()+'<><>');
    }else{                                                 
        parentAssignmentList = parentAssignmentMap.values();
        /*Get all the Timecards Assignments*/
        if(trigger.isUpdate){
            timeList = [SELECT id, Appirio_PSAe__Week_Total_Hrs__c,Appirio_PSAe__SFDC_Projects__c , Appirio_PSAe__Assignment__c ,Appirio_PSAe__Assignment__r.Appirio_PSAe__Total_Assignment_Hours__c,
                                                    Appirio_PSAe__Assignment__r.Appirio_PSAe__Description__c , Appirio_PSAe__SFDC_Projects__r.Name 
                                                     FROM Appirio_PSAe__Timecard__c
                                                     WHERE Appirio_PSAe__Assignment__c =: parentAssignmentMap.keySet() AND id <>: Trigger.newMap.keySet() AND Appirio_PSAe__Bill_To__c =:'Billable'];
        }else{
            timeList = [SELECT id, Appirio_PSAe__Week_Total_Hrs__c,Appirio_PSAe__SFDC_Projects__c , Appirio_PSAe__Assignment__c  ,Appirio_PSAe__Assignment__r.Appirio_PSAe__Total_Assignment_Hours__c ,    
                                                     Appirio_PSAe__Assignment__r.Appirio_PSAe__Description__c , Appirio_PSAe__SFDC_Projects__r.Name 
                                                     FROM Appirio_PSAe__Timecard__c
                                                     WHERE Appirio_PSAe__Assignment__c =: parentAssignmentMap.keySet() AND Appirio_PSAe__Bill_To__c =:'Billable'];
        }
        
        for(Appirio_PSAe__Timecard__c testMe: Trigger.new){
            Id tempAssignId = testMe.Appirio_PSAe__Assignment__c;
            Decimal tempTotalHours = 0.0;
            Decimal assignmentTotalHours = parentAssignmentMap.get(testMe.Appirio_PSAe__Assignment__c).Appirio_PSAe__Total_Assignment_Hours__c;
            String projectName = parentProjectMap.get(testMe.Appirio_PSAe__SFDC_Projects__c).Name;
            String assignmentDescrript = parentAssignmentMap.get(testMe.Appirio_PSAe__Assignment__c).Appirio_PSAe__Description__c; 
            for(Appirio_PSAe__Timecard__c testAll: timeList){
                if( testAll.Appirio_PSAe__Assignment__c == tempAssignId ){
                    tempTotalHours += testAll.Appirio_PSAe__Week_Total_Hrs__c;
                }
            }
            List<Appirio_PSAe__Timecard__c> testtimeoo = assignmetTimecardMap.get(testMe.Appirio_PSAe__Assignment__c);
            for(Appirio_PSAe__Timecard__c testti: testtimeoo){
                //if(trigger.isUpdate){
                //    tempTotalHours += Trigger.newMap.get(testti.Id).Appirio_PSAe__Week_Total_Hrs__c - Trigger.oldMap.get(testti.Id).Appirio_PSAe__Week_Total_Hrs__c;
                //}else{
                    if(testTi.Appirio_PSAe__Bill_To__c == 'Billable')
                    tempTotalHours += testti.Appirio_PSAe__Week_Total_Hrs__c;
                //}
            }
            //testMe.addError('Total TimeCard Hours Cannot'+tempTotalHours+'total_Assignment_Hours__c'+testMe.Appirio_PSAe__Assignment__r.Appirio_PSAe__Total_Assignment_Hours__c);
            if(tempTotalHours > assignmentTotalHours){
                if(!projectName.containsIgnoreCase('Rainmaker'))
                testMe.addError('Total TimeCard Hours Cannot Be More Than The Total Assignment Hours for '+projectName +' -- '+assignmentDescrript+'.');
            }
            
        } 
    
    }
    
    }
    if(trigger.isupdate){
    
    for(Appirio_PSAe__Timecard__c tc : Trigger.new){
        /*Project Timecard Map Preperation*/
        List<Appirio_PSAe__Timecard__c> temptimecardList = projectTimecardMap.get(tc.Appirio_PSAe__SFDC_Projects__c);
        if(null==temptimecardList){
            temptimecardList = new List<Appirio_PSAe__Timecard__c>();
            temptimecardList.add(tc);
            projectTimecardMap.put(tc.Appirio_PSAe__SFDC_Projects__c, temptimecardList);
        }else{
            temptimecardList.add(tc);           
        }
        
        /*Assignment Timecard Map preperation*/
        List<Appirio_PSAe__Timecard__c> temptimecardList2 = assignmetTimecardMap.get(tc.Appirio_PSAe__Assignment__c);
        testoo += tc.Appirio_PSAe__Assignment__c;
        if(null==temptimecardList2){
            temptimecardList2 = new List<Appirio_PSAe__Timecard__c>();
            temptimecardList2.add(tc);
            assignmetTimecardMap.put(tc.Appirio_PSAe__Assignment__c, temptimecardList2);
            
        }else{
            temptimecardList2.add(tc);          
        }
         
        try
        {
            List<Appirio_PSAe__Assignment__c> assignmentList = new List<Appirio_PSAe__Assignment__c>(); 
            assignmentList = [select Non_Billable_Assignment__c,Id,Name from Appirio_PSAe__Assignment__c where id=: tc.Appirio_PSAe__Assignment__c];
            if(assignmentList.size() > 0 && assignmentList !=null)
            {
                if(assignmentList[0].Non_Billable_Assignment__c  == true){
                System.debug('1....Non Billable');
                 tc.Appirio_PSAe__Bill_To__c = 'Non Billable'; 
                }   
            }
       }
       catch(Exception ex)
       {
         System.debug('exception....'+ex.getMessage());
       }
        // added code
        
        
        
        /*
        if(tc.Appirio_PSAe__Assignment__r.Non_Billable_Assignment__c  == true){
            System.debug('1....Non Billable');
             tc.Appirio_PSAe__Bill_To__c = 'Non Billable'; 
        }else{
            System.debug('1.... Billable');
            tc.Appirio_PSAe__Bill_To__c = 'Billable';
        }
        */
        
    }
        
    /*Get all the Assignments*/
    Map<Id,Appirio_PSAe__Assignment__c> parentAssignmentMap = new Map<Id,Appirio_PSAe__Assignment__c>(
            [SELECT Id,Name,  Appirio_PSAe__Remaining_Billable_Hours__c,Non_Billable_Assignment__c,Appirio_PSAe__End_Date__c, 
            Appirio_PSAe__Actual_Billable_Hours__c,Appirio_PSAe__Total_Assignment_Hours__c,Appirio_PSAe__Description__c        
                    FROM Appirio_PSAe__Assignment__c
                    WHERE id =: assignmetTimecardMap.keySet()]);
     /*Get all the Project*/
    Map<Id,Appirio_PSAe__Proj__c> parentProjectMap = new Map<Id,Appirio_PSAe__Proj__c>( 
                            [SELECT Name, id, Appirio_PSAe__Hours_Allocated__c, Non_Billable_Assigned_Hours__c  , Total_Time_Card__c  , 
                            Total_NonBillable_Timecard_Hours__c,Appirio_PSAe__Account__c  FROM  Appirio_PSAe__Proj__c
                                                     WHERE id =: projectTimecardMap.keySet() AND Appirio_PSAe__Project_Stage__c !='Completed' 
                                                     AND Appirio_PSAe__Project_Stage__c !='Cancelled' ]);
     
     timeList = [SELECT id, Appirio_PSAe__Week_Total_Hrs__c,Appirio_PSAe__SFDC_Projects__c , Appirio_PSAe__Assignment__c ,Appirio_PSAe__Assignment__r.Appirio_PSAe__Total_Assignment_Hours__c,
                                                    Appirio_PSAe__Assignment__r.Appirio_PSAe__Description__c , Appirio_PSAe__SFDC_Projects__r.Name 
                                                     FROM Appirio_PSAe__Timecard__c
                                                     WHERE Appirio_PSAe__Assignment__c =: parentAssignmentMap.keySet() AND id <>: Trigger.newMap.keySet() AND Appirio_PSAe__Bill_To__c =:'Billable' ];
                                                                                                                                               
    if(parentProjectMap.isEmpty()){
        if(!Trigger.new[0].Appirio_PSAe__SFDC_Projects__r.Name.containsIgnoreCase('Rainmaker'))
        Trigger.new[0].addError('No Open Project found for the Timecard. Project Name:'+Trigger.new[0].Appirio_PSAe__SFDC_Projects__r.Name);
    }else{
        System.debug('<<<<<inside else>>>>>');
        parentProjectList =  parentProjectMap.values();
    }
    for(Appirio_PSAe__Proj__c tempProj: parentProjectList){
        List<Appirio_PSAe__Timecard__c> temptimecardList = projectTimecardMap.get(tempProj.Id);
        Decimal totalTChours = tempProj.Total_Time_Card__c - tempProj.Total_NonBillable_Timecard_Hours__c ;
        Decimal totalTCNonhours = tempProj.Total_NonBillable_Timecard_Hours__c;
        System.debug('<<totalTChours>>>' + totalTChours);
        for(Appirio_PSAe__Timecard__c tempTimeC: temptimecardList){
            if(tempTimeC.Appirio_PSAe__Bill_To__c =='Billable'){
                totalTChours = totalTChours - Trigger.oldMap.get(tempTimeC.Id).Appirio_PSAe__Week_Total_Hrs__c;
                //}
                
            }
        } 
        System.debug('<<totalTChours>>>' + totalTChours);   
        for(Appirio_PSAe__Timecard__c tempTimeC: temptimecardList){
            if(tempTimeC.Appirio_PSAe__Bill_To__c =='Billable'){
                //if(Trigger.isInsert){
                    totalTChours += tempTimeC.Appirio_PSAe__Week_Total_Hrs__c;
                //}else{
                    //totalTChours += Trigger.newMap.get(tempTimeC.Id).Appirio_PSAe__Week_Total_Hrs__c - Trigger.oldMap.get(tempTimeC.Id).Appirio_PSAe__Week_Total_Hrs__c;
                //}
                
            }
            System.debug('<<totalTChours>>>' + totalTChours);
            if(totalTChours >tempProj.Appirio_PSAe__Hours_Allocated__c ){
                    if(!tempProj.Name.containsIgnoreCase('Rainmaker'))
                    tempTimeC.addError('Total Billable TimeCard Hours Cannot Be More Than The Total Billable Project Hours for '+tempProj.Name+'.');
            }
        }
        
    } 
     
     for(Appirio_PSAe__Timecard__c testMe: Trigger.new){
            if(testMe.Appirio_PSAe__Assignment__c != null){ 
            system.debug('<<<IUnside for>>>>');
            Id tempAssignId = testMe.Appirio_PSAe__Assignment__c;
            Decimal tempTotalHours = 0.0;
            Decimal assignmentTotalHours = 0.0;
            if(testMe.Appirio_PSAe__Assignment__c != null && parentAssignmentMap.get(testMe.Appirio_PSAe__Assignment__c) != null)
              assignmentTotalHours = parentAssignmentMap.get(testMe.Appirio_PSAe__Assignment__c).Appirio_PSAe__Total_Assignment_Hours__c;
            String projectName = '';
            if(parentProjectMap.get(testMe.Appirio_PSAe__SFDC_Projects__c) != null)
             projectName = parentProjectMap.get(testMe.Appirio_PSAe__SFDC_Projects__c).Name;
            String assignmentDescrript = '';
            if(testMe.Appirio_PSAe__Assignment__c != null && parentAssignmentMap.get(testMe.Appirio_PSAe__Assignment__c) != null)
             assignmentDescrript = parentAssignmentMap.get(testMe.Appirio_PSAe__Assignment__c).Appirio_PSAe__Description__c; 
            for(Appirio_PSAe__Timecard__c testAll: timeList){
                if( testAll.Appirio_PSAe__Assignment__c == tempAssignId ){
                    system.debug('<<<IUnside if>>>>');
                    system.debug('<<<IUnside if>>>>'+testAll.Id);
                    system.debug('<<<IUnside if>>>>'+tempAssignId );
                    tempTotalHours += testAll.Appirio_PSAe__Week_Total_Hrs__c;
                }
            }
            system.debug('<<<totalhours>>>>' + tempTotalHours);
            List<Appirio_PSAe__Timecard__c> testtimeoo = assignmetTimecardMap.get(testMe.Appirio_PSAe__Assignment__c);
            for(Appirio_PSAe__Timecard__c testti: testtimeoo){
                system.debug('<<<IUnside for>>>>');
                //if(trigger.isUpdate){
                //    tempTotalHours += Trigger.newMap.get(testti.Id).Appirio_PSAe__Week_Total_Hrs__c - Trigger.oldMap.get(testti.Id).Appirio_PSAe__Week_Total_Hrs__c;
                //}else{
                    if(testTi.Appirio_PSAe__Bill_To__c == 'Billable')
                    tempTotalHours += testti.Appirio_PSAe__Week_Total_Hrs__c;
                //}
            }
            system.debug('<<<totalhours>>>>' + tempTotalHours);
            system.debug('<<<assignmenttotal>>>>' + assignmentTotalHours );
            //testMe.addError('Total TimeCard Hours Cannot'+tempTotalHours+'total_Assignment_Hours__c'+testMe.Appirio_PSAe__Assignment__r.Appirio_PSAe__Total_Assignment_Hours__c);
            if(tempTotalHours > assignmentTotalHours){
                system.debug('<<<IUnside for>>>>');
                if(!projectName.containsIgnoreCase('Rainmaker'))
                testMe.addError('Total TimeCard Hours Cannot Be More Than The Total Assignment Hours for '+projectName +' -- '+assignmentDescrript+'.');
            }
            
         }
        }
       }
      }Catch(Exception e){}   
}