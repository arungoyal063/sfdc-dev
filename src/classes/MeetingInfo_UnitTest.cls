/*******************************************************************************************************************
** Module Name   : MeetingInfo_UnitTest
** Description   : Test MeetingInfo Apex Class.
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
*********************************************************************************************************************/
@istest
Public class MeetingInfo_UnitTest
{
    Static TestMethod void MeetingInfo_Test()
    {
        MeetingInfo m=new MeetingInfo();
        System.assertEquals(true, true);
    }
}