/*******************************************************************************************************************
** Module Name   : schd_Milestone1Task
** Description   : scheduler for "batch_Milestone1Task"
** Throws        : NA
** Calls         : NA
** Test Class    : schd_Milestone1Task_UnitTest
** 
** Organization  : Rain Maker
**
** Revision History:-
** Version             Date            Author           WO#         Description of Action
** 1.0                               Arun              
******************************************************************************************************************/
global class schd_Milestone1Task implements Schedulable{
	global void execute(SchedulableContext SC) {
		batch_Milestone1Task b = new batch_Milestone1Task(); 
        database.executebatch(b);   
	}
}