/*******************************************************************************************************************
** Module Name   : CreateMeetingInfo
** Description   : Wrapper having all property required for Create Meeting.
** Throws        : NO
** Calls         : No
** Test Class    : NO
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/

public with sharing class CreateMeetingInfo{
    public String subject;
    public DateTime starttime;
    public DateTime endtime;
    public String passwordrequired; // Always false
    //PSTN (PSTN only), Free (PSTN and VoIP), Hybrid, (PSTN and VoIP), 
    //Private (you provide numbers and access code), or VoIP (VoIP only)
    public String conferencecallinfo;
    //meeting type should be  Immediate, Scheduled or Recurring
    public String meetingtype;
    public String timezonekey;
}