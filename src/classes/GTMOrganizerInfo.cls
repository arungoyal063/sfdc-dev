/*******************************************************************************************************************
** Module Name   : GTMOrganizerInfo
** Description   : It is a wrapper which contains property of GTM organizer
** Throws        : No
** Calls         : No
** Test Class    : <GTMOrganizerInfo_UnitTest>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-05-16  AW                    Initial Version
******************************************************************************************************************/
public with sharing class GTMOrganizerInfo{
	/*GTM Organizer Info Wrapper*/
	public String organizerKey;
    public String firstName;
    public String lastName;
    public String email;
    public String status;
    public String groupId;
    public String groupName;
    public String maxNumAttendeesAllowed;
}