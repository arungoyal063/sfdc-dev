/*******************************************************************************************************************
** Module Name   : schd_Milestone1Task_UnitTest
** Description   : Test Class
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
@isTest
public with sharing class schd_Milestone1Task_UnitTest 
{
	Static TestMethod void UnitTest()
	{
		schd_Milestone1Task clsCRON = new schd_Milestone1Task();
		System.Schedule('milestine Task scheduler', '0 3 5 * * ?', clsCRON);
	}
}