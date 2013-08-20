/**
* POJO
*
**/
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