/*******************************************************************************************************************
** Module Name   : MeetingInfo
** Description   : Wrapper To get values returened by Callout.
** Throws        : No
** Calls         : No
** Test Class    : <MeetingInfo_unitTest>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/

global with sharing class MeetingInfo {
	global String createTime;
    global String status;
    global String subject;
    global String startTime;
   	global String conferenceCallInfo;
    global String AcccessCode;
    global String meetingType;
    global String maxParticipants;
    global String endTime;
    global String uniqueMeetingId;
    global String meetingid;
    global String passwordRequired;
}