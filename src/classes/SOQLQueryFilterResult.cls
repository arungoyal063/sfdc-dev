/*********************************************************************************************************************
* Module Name   :  SOQLQueryFilterResult 
* Description   :  SOQLQueryFilterResult 
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <Test_AccountExtension>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      2/27/2013       Algoworks     1255     Initial Version
*******************************************************************************************************************/
public with sharing class SOQLQueryFilterResult {
    // this is the sting that will be plugged into your SOQL where clause
    public string WhereConditionString {get;set;}
    
    // this is a list of the fields that exist in the where clause
    public List<String> FieldsList {get; set;}  
    
    // this will translate the list into a comma delimited string
    public string FieldsListString {
        get {
            string returnValue = '';
            
            // build our comma+space delimited string
            for (string CurrentField: FieldsList) {
                returnValue += CurrentField + ', ';
            } // loop thru FieldsList
            
            // trim any trailing delimiters
            returnValue = returnValue.removeEnd(', ');
            
            return ReturnValue;
        } // get
    } // FieldsListString
} // SOQLQueryFilterResult