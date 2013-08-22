public with sharing class PanelSelectionController {
    public list<ProfileOrderChoice> objProfileOrderChoice {get;set;}
    public Profile__c objProfile {get;set;}
    public list<Profile__c> objProfiles {get;set;}
    public String selectedProfileOrderChoiceId {get;set;}
    /*Constructor*/
    public PanelSelectionController(){
        String profileId = ApexPages.currentPage().getParameters().get('pId');
        objProfiles = DBUtility.getProfileandOrderChoiceBypId(profileId);        
        if(!objProfiles.isEmpty()){  
            objProfile = objProfiles.get(0);
            objProfileOrderChoice = new list<ProfileOrderChoice>();      
            for(Profile_Order_Choice__c objPOC:objProfiles.get(0).Profile_Order_Choices__r){                
                objProfileOrderChoice.add(new ProfileOrderChoice(objPOC));            
            }
        }
    }
    /*
        @Description: To delete order Choice individually       
    */
    public pageReference onRemove(){
        list<Profile_Order_Choice__c> todelete = new list<Profile_Order_Choice__c>();
        list<Profile_Order_Choice__c> profiles = objProfiles.get(0).Profile_Order_Choices__r;
        Integer indx = 0;
        for(Profile_Order_Choice__c objPOC:profiles){ 
            if(objPOC.id == selectedProfileOrderChoiceId){
                todelete.add(objPOC);
                objProfileOrderChoice.remove(indx);
            }
            indx++;
        }
        if(!todelete.isEmpty()){
            delete todelete;
        }
        return null;
    }
    /*
        @Description: To delete order Choice all selected
    */
    public pageReference onRemoveAll(){
        list<Profile_Order_Choice__c> todelete = new list<Profile_Order_Choice__c>(); 
        list<ProfileOrderChoice> tempobjProfileOrderChoice = new list<ProfileOrderChoice>();
        for(ProfileOrderChoice objPOC1:objProfileOrderChoice){ 
            if(objPOC1.isSelected){
                tempobjProfileOrderChoice.add(objPOC1);  
            }
        }
        if(!tempobjProfileOrderChoice.isEmpty()){
            for(ProfileOrderChoice o:tempobjProfileOrderChoice){
                todelete.add(o.objPOC);
            }
            delete todelete;
        }
        pagereference pr = new pageReference('/apex/PanelSelection?pId='+ApexPages.currentPage().getParameters().get('pId'));
        pr.setRedirect(true);
        return pr; 
    }
    public pageReference onSaveAndAddPanel(){
        list<Profile_Order_Choice__c> todelete = new list<Profile_Order_Choice__c>(); 
        list<ProfileOrderChoice> tempobjProfileOrderChoice = new list<ProfileOrderChoice>();
        for(ProfileOrderChoice objPOC1:objProfileOrderChoice){ 
            if(objPOC1.isSelected){
                tempobjProfileOrderChoice.add(objPOC1);  
            }
        }
        if(!tempobjProfileOrderChoice.isEmpty()){
            for(ProfileOrderChoice o:tempobjProfileOrderChoice){
                todelete.add(o.objPOC);
            }
            delete todelete;
        }
        pagereference pr = new pageReference('/apex/PanelSelection?pId='+ApexPages.currentPage().getParameters().get('pId'));
        pr.setRedirect(true);
        pageReference pageref = new pageReference('/apex/NewProfileAndSearchPage');
        return pageref;
    
    
    
    
    
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
     /*public void onRemove(){
        list<Profile_Order_Choice__c> abc;
        list<WrapperClass> del = new list<WrapperClass>(); 
        del.addall(objWra);
        for(WrapperClass wc:del){
                abc=new list<Profile_Order_Choice__c>();
                if(wc.objPro.Id==profileOrderChoice){
                    abc.add(wc.objPro);
                    objWra.remove(0);                    
                }
        }
        if(!abc.isEmpty())
            delete abc;
    }
    
    public pageReference onDelete(){
        list<Profile_Order_Choice__c> abc;
        for(WrapperClass wc:objWra){
                abc=new list<Profile_Order_Choice__c>();
                if(wc.objBoo==true){
                        abc.add(wc.objPro);
                }
        }
        if(!abc.isEmpty())
            delete abc;
       PageReference pageRef = ApexPages.currentPage();
       pageRef.setRedirect(true);
       return null;        
    }
    public void onRemove(){
        list<Profile_Order_Choice__c> abc;
        list<WrapperClass> del = new list<WrapperClass>(); 
        del.addall(objWra);
        for(WrapperClass wc:del){
                abc=new list<Profile_Order_Choice__c>();
                if(wc.objPro.Id==profileOrderChoice){
                    abc.add(wc.objPro);
                    objWra.remove(0);                    
                }
        }
        if(!abc.isEmpty())
            delete abc;
        /*If(null != profileOrderChoice){
            delete [SELECT Id FROM Profile_Order_Choice__c WHERE Id=:profileOrderChoice];
        } /               
    }*/
    
    
    public class ProfileOrderChoice{
        public boolean isSelected{get;set;}
        public Profile_Order_Choice__c objPOC{get;set;}
        public ProfileOrderChoice(Profile_Order_Choice__c objPOC){
            this.objPOC = objPOC;
            this.isSelected = false;
        }
    }    
}