/*******************************************************************************************************************
** Module Name   : CaseUtil
** Description   : utility class for the case object
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun               Initial Version
******************************************************************************************************************/
public with sharing class CaseUtil {
	//this method will check if the current time does exist in business hours(organization) or not
    public static Boolean checkBusinessHours(){
    
	    // Get the default business hours
		BusinessHours bh = [select id,  SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
							WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, 
							SaturdayStartTime, SaturdayEndTime from businesshours where IsDefault=true];
		
		DateTime currentDate = System.NOW();	
		String dayText = currentDate.format('EE');
		Boolean isCaseUpdateTimeCorrect = false;		
		
		if(dayText != '' &&  bh != null){
			Integer currentHour = currentDate.hour();
			if(dayText == 'Mon' && bh.MondayStartTime != null && bh.MondayEndTime != null && bh.MondayStartTime.hour() <= currentHour && currentHour <= bh.MondayEndTime.hour()){
				isCaseUpdateTimeCorrect = true;
			}
			else if(dayText == 'Tue' && bh.TuesdayStartTime != null && bh.TuesdayEndTime != null && bh.TuesdayStartTime.hour() <= currentHour && currentHour <= bh.TuesdayEndTime.hour()){
				isCaseUpdateTimeCorrect = true;
			}
			else if(dayText == 'Wed' && bh.WednesdayStartTime != null && bh.WednesdayEndTime != null && bh.WednesdayStartTime.hour() <= currentHour && currentHour <= bh.WednesdayEndTime.hour()){
				isCaseUpdateTimeCorrect = true;
			}
			else if(dayText == 'Thu' && bh.ThursdayStartTime != null && bh.ThursdayEndTime != null && bh.ThursdayStartTime.hour() <= currentHour && currentHour <= bh.ThursdayEndTime.hour()){
				isCaseUpdateTimeCorrect = true;
			}
			else if(dayText == 'Fri' && bh.FridayStartTime != null && bh.FridayEndTime != null && bh.FridayStartTime.hour() <= currentHour && 	currentHour <= bh.FridayEndTime.hour()){
				isCaseUpdateTimeCorrect = true;
			}
			else if(dayText == 'Sat' && bh.SaturdayStartTime != null && bh.SaturdayEndTime != null && bh.SaturdayStartTime.hour() <= currentHour && currentHour <= bh.SaturdayEndTime.hour()){
				isCaseUpdateTimeCorrect = true;
			}
			else if(dayText == 'Sun' && bh.SundayStartTime != null && bh.SundayEndTime != null && bh.SundayStartTime.hour() <= currentHour && 	currentHour <= bh.SundayEndTime.hour()){
				isCaseUpdateTimeCorrect = true;
			}
		}
		return isCaseUpdateTimeCorrect;
    }
}