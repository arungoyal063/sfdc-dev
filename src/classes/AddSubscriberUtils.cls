/**
*********************************************************************************************************************
* Module Name   :  AddSubscriberUtils
* Description   :   
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Dependency    :  
* Test Class    :  
* 
* Organization  : Rainmaker Associates LLC
*  
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      06/5/2013     Milligan         362               Initial Version
*    
*******************************************************************************************************************
**/
public with sharing class AddSubscriberUtils {
    
    public List<SearchWrapper> users = new   List<SearchWrapper>();
    List<User> theUsers = new List<User>();
    public List<SearchWrapper> getSearchResults(List<String> sIds){
        
       theUsers =[Select Id, Name, Username, Email, FirstName, LastName, Profile.Name, contactid, (Select NetworkId, Id, Network.Status from NetworkMemberUsers where Network.Status = 'Live')  from User U where isactive = true and Profile.Name !=  'Ellucian Communities Profile'  and ContactId IN: sIds ];
        
        users = new List<SearchWrapper>();
        for (User u : theUsers) {
            SearchWrapper wrapper = new SearchWrapper(u);
            users.add(wrapper);
        }
        
        if(!users.IsEmpty()) 
        {
        	System.debug('AddSubcribers Size --> ' + users.size());
        }
        return users;
    }
    
    public class SearchWrapper {
        
        public string NetworkId{ get; set; }
        public Boolean checked{ get; set; }
        public User usr { get; set;}
        
        public SearchWrapper(User u){
            usr = u;
            checked = false;
            
            //this is a temporary workaround
            try{
                if(u.NetworkMemberUsers != null){
                    NetworkId = u.NetworkMemberUsers[0].networkid;
                }
            }catch(Exception ex){}
        
        }
        
    }   

}