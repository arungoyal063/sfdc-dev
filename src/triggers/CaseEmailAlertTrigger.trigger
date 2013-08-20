/*******************************************************************************************************************
** Module Name   : CaseEmailAlertTrigger
** Description   : Trigger to notify on case updation by sending email  
** Throws        : NA
** Calls         : NA
** Test Class    :  
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun Goyal                       Initial Version
******************************************************************************************************************/

trigger CaseEmailAlertTrigger on Case (before update) 
{   
    system.debug('$$$$$$$$$$$$$$$$$$$$');
    //public static List<Case> caseList = new List<Case>();
    public static List<Escalation_Track__c> escalationTrackList = new List<Escalation_Track__c>();
    
    // checking for curent time exist in business hour or not
    Boolean isCaseUpdateTimeCorrect;
    if(!Test.IsRunningTest()){
    isCaseUpdateTimeCorrect = CaseUtil.checkBusinessHours();}
    else{isCaseUpdateTimeCorrect = True;}
    system.debug('$$$$$$$$$$$$$$$$$$$$isCaseUpdateTimeCorrect$$$$$$$$$$$$$$$$$$$'+isCaseUpdateTimeCorrect);
    
    if(isCaseUpdateTimeCorrect && !CaseEmailAlert.isUpadted){
        
        for(Case caseObj: Trigger.new){     
            Case olCaseObj = Trigger.oldMap.get(caseObj.Id);
            system.debug('olCaseObj...'+ olCaseObj+  '%%%%%%%%%%%%couneroldCaseObj...'+olCaseObj.CaseLastUpdationTime__c);
            if(caseObj.CaseLastUpdationTime__c != Null && caseObj.CaseLastUpdationTime__c != olCaseObj.CaseLastUpdationTime__c) 
            {
                Integer hoursdiff;
                hoursdiff = system.now().hour() - caseObj.CaseLastUpdationTime__c.hour(); 
                system.debug('>>>>>>'+hoursdiff);
                if(hoursdiff >= 2 && hoursdiff < 4)
                //if(hoursdiff >= 1 && hoursdiff < 2)
                {
                    escalationTrackList.add(CaseEmailAlert.sendMail(caseObj, '2'));
                    //sendmail(caseObj, '2');
                }   
                else if(hoursdiff >= 4 && hoursdiff < 8)
                //else if(hoursdiff >= 2 && hoursdiff < 3)
                {
                    escalationTrackList.add(CaseEmailAlert.sendMail(caseObj, '4'));
                    //sendmail(caseObj, '4');                       
                }   
                else if(hoursdiff >= 8 && hoursdiff < 24)
                //else if(hoursdiff >= 3 && hoursdiff < 4)
                {
                    escalationTrackList.add(CaseEmailAlert.sendMail(caseObj, '8'));
                    //sendmail(caseObj, '8');
                }   
                else if(hoursdiff >= 24 && hoursdiff < 48)
                //else if(hoursdiff >= 4 && hoursdiff < 5)
                {
                    escalationTrackList.add(CaseEmailAlert.sendMail(caseObj, '24'));
                    //sendmail(caseObj, '24');
                }
                else if(hoursdiff >= 48)
                //else if(hoursdiff >= 5)
                {
                    escalationTrackList.add(CaseEmailAlert.sendMail(caseObj, '48'));
                    //sendmail(caseObj, '48');
                }               
                
                caseObj.CaseLastUpdationTime__c = Null;
                //caseList.add(caseObj);
            }
        }
        
        try{        
            system.debug('>>>>>>>>>>>>>escalationTrackList...'+escalationTrackList);            
            insert escalationTrackList;
            //update caseList;
        }catch(Exception Ex){}
        
        CaseEmailAlert.isUpadted = true;
    }
    
}