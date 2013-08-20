public with sharing class GeneratedReport {
    
    public List<String> projectIdList{get; set;}    
    public list<ProjectM> objProjectM {get;set;}
    
    public GeneratedReport(){
        objProjectM = new list<ProjectM>();
        if(apexpages.currentpage().getparameters().get('selectedProjectdIds') != null && apexpages.currentpage().getparameters().get('selectedProjectdIds').trim() != ''){
            projectIdList = apexpages.currentpage().getparameters().get('selectedProjectdIds').split(',');          
            try{
                List<Milestone1_Project__c> mileStoneList = [SELECT Account__r.Name, Status__c,   
                            Account__r.Owner.Name, Opportunity__r.Project_Manager__r.Name,
                            Kickoff__c, Deadline__c, Name,
                            (Select Name, Status_Summary__c, Status__c, LastModifiedDate, LastModifiedBy.Name FROM PM_Status__r order by LastModifiedDate desc),
                            (Select  Description__c FROM Risks__r),
                            (Select Name, Deadline__c, Kickoff__c FROM Project_Milestones__r order by Kickoff__c desc)
                            FROM Milestone1_Project__c m WHERE Id IN :projectIdList order by Opportunity__r.Project_Manager__r.LastName];
                            
                for(Milestone1_Project__c mileStone : mileStoneList){
                    list<Milestone1_Milestone__c> currentMileStones = new list<Milestone1_Milestone__c>();
                    list<Milestone1_Milestone__c> nextMileStones = new list<Milestone1_Milestone__c>();
                    for(Milestone1_Milestone__c currentMileStone : mileStone.Project_Milestones__r){
                        if(System.TODAY() >= currentMileStone.Kickoff__c && System.TODAY() <= currentMileStone.Deadline__c){
                            currentMileStones.add(currentMileStone);
                        }
                        else if(currentMileStone.Kickoff__c >= System.TODAY()){
                            nextMileStones.add(currentMileStone);
                        }                       
                    }
                    
                    list<Relationship_Status__c> relationshipStatus = new list<Relationship_Status__c>();
                    list<Account> accountList;
                    if(mileStone.Account__c != null){
                        accountList = [SELECT Name, (SELECT Id, Status_Summary__c, Status__c FROM Relationship_Status__r order by CreatedDate desc) FROM Account WHERE ID =: mileStone.Account__c LIMIT 1];
                    }
                    if(accountList != null && !accountList.isEmpty()){
                        relationshipStatus = accountList.get(0).Relationship_Status__r;
                    }
                    objProjectM.add(new ProjectM(mileStone, mileStone.Risks__r, currentMileStones, nextMileStones, mileStone.PM_Status__r, relationshipStatus));
                }
            }
            catch(Exception e){
                
            }           
        }
        
    }
    
    public class ProjectM{
        public Milestone1_Project__c objMilestone1Project{get;set;}     
        public list<Risk_and_Issues__c> objRisk {get;set;}
        public list<Milestone1_Milestone__c> objCurrentMilestone {get;set;}
        public list<Milestone1_Milestone__c> objNextMilestone {get;set;}
        public list<PM_Status__c> objPMStatus {get;set;}
        public list<Relationship_Status__c> objRelationshipStatus {get;set;}
        public ProjectM(Milestone1_Project__c objMilestone1Project, list<Risk_and_Issues__c> objRisk, list<Milestone1_Milestone__c> objCurrentMilestone,
                        list<Milestone1_Milestone__c> objNextMilestone, list<PM_Status__c> objPMStatus, list<Relationship_Status__c> objRelationshipStatus){
            this.objMilestone1Project = objMilestone1Project;           
            //this.objRisk = objRisk;
            this.objCurrentMilestone = objCurrentMilestone;
            this.objNextMilestone = objNextMilestone;
            this.objPMStatus = objPMStatus;
            this.objRelationshipStatus = objRelationshipStatus;
        }
    }
}