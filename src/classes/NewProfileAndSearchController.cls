/*
** Module Name   : NewProfileAndSearchController
** Description   : 
** Throws        : 
** Calls         : 
** Test Class    : 
** 
** Organization  : 
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
**                   Atulit Gupta      
**********************************************************************************************************************************************************/

public with sharing class NewProfileAndSearchController {
    //Variable Declaration  
    public Profile__c profObj {get;set;}
    public String searchInput {get;set;}
    public list<ProfileOrderChoice> objProfileOrderChoice{get;set;}
    
    // Constructor
    public NewProfileAndSearchController(){
        profObj = new Profile__c();
        objProfileOrderChoice = new list<ProfileOrderChoice>();
        for(Profile_Order_Choice__c obj : DBUtility.getProfileOrder()){
            objProfileOrderChoice.add(new ProfileOrderChoice(obj));
        }
    }
    
    
    public class ProfileOrderChoice{
        public boolean isAdded {get;set;}
        public Profile_Order_Choice__c objProfileOrder {get;set;}
        public ProfileOrderChoice(Profile_Order_Choice__c objProfileOrder){
            isAdded = false;
            this.objProfileOrder = objProfileOrder;
        }
    
    
    
    }
}