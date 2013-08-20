/*******************************************************************************************************************
** Module Name   : schd_Milestone1Milestone
** Description   : scheduler for "batch_Milestone1Milestone"
** Throws        : NA
** Calls         : NA
** Test Class    : schd_Milestone1Milestone_UnitTest
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun              
******************************************************************************************************************/
global class schd_Milestone1Milestone implements Schedulable{
	global void execute(SchedulableContext SC) {
		batch_Milestone1Milestone b = new batch_Milestone1Milestone(); 
        database.executebatch(b);   
	}
}