public with sharing class ProjectStatusReport {
        
    public Milestone1_Project__c milestoneProject{get;set;}
    public List<String> listProjectMgr{get; set;}
    public List<String> listEngagementMgr{get; set;}
    
    public list<selectOption> leftOptionsProjectMgr{get;set;}
    public list<selectOption> rightOptionsProjectMgr{get;set;}
    public String selectedValuesProjectMgr {get;set;}
    
    public list<selectOption> leftOptionsEngagementMgr{get;set;}
    public list<selectOption> rightOptionsEngagementMgr{get;set;}
    public String selectedValuesEngagementMgr {get;set;}
    
    public list<selectOption> leftOptionsProject{get;set;}
    public list<selectOption> rightOptionsProject{get;set;}
    public String selectedValuesProject {get;set;}
    
    public ProjectStatusReport (){
        milestoneProject = new Milestone1_Project__c();
        rightOptionsProjectMgr = new list<selectOption>();
        rightOptionsEngagementMgr = new list<selectOption>();
        rightOptionsProject = new list<selectOption>();     
    }
    
    public list<selectOption> getAllLeftOptionsProjectMgr(){
    
        leftOptionsProjectMgr = new list<selectOption>();
        if(milestoneProject.Kickoff__c != null && milestoneProject.Deadline__c != null) {
            Set<String> tempSet = new Set<String>();
            list<Milestone1_Project__c> mileStoneList = [SELECT Opportunity__r.Project_Manager__c, Opportunity__r.Project_Manager__r.Name FROM Milestone1_Project__c WHERE Status__c = 'Active'
                                                        AND Kickoff__c >= :milestoneProject.Kickoff__c AND Deadline__c <= :milestoneProject.Deadline__c ];
            for(Milestone1_Project__c mileStone:mileStoneList){
                if(mileStone.Opportunity__r.Project_Manager__c != null && tempSet.add(mileStone.Opportunity__r.Project_Manager__r.Name)){              
                    leftOptionsProjectMgr.add(new selectOption(mileStone.Opportunity__r.Project_Manager__c,mileStone.Opportunity__r.Project_Manager__r.Name));
                }           
            }
        }
        return leftOptionsProjectMgr;
    }
    
    public list<selectOption> getAllLeftOptionsEngagementMgr(){
        leftOptionsEngagementMgr = new list<selectOption>();
        listProjectMgr = new list<String>();
        if(selectedValuesProjectMgr != null && selectedValuesProjectMgr.trim() != ''){
        	listProjectMgr = selectedValuesProjectMgr.split(',');
        }
        
        Set<String> tempSet = new Set<String>();
        list<Milestone1_Project__c> mileStoneEngagementList = [SELECT Account__r.OwnerId, Account__r.Owner.Name FROM Milestone1_Project__c WHERE Status__c = 'Active'
                                                        AND Kickoff__c >= :milestoneProject.Kickoff__c AND Deadline__c <= :milestoneProject.Deadline__c AND Opportunity__r.Project_Manager__c in :listProjectMgr];
        for(Milestone1_Project__c mileStoneEngagement:mileStoneEngagementList){
			if(milestoneProject.Kickoff__c != null && milestoneProject.Deadline__c != null && selectedValuesProjectMgr != null && 
				selectedValuesProjectMgr.trim() != '' && mileStoneEngagement.Account__c != null && tempSet.add(mileStoneEngagement.Account__r.Owner.Name)) {
				leftOptionsEngagementMgr.add(new selectOption(mileStoneEngagement.Account__r.OwnerId,mileStoneEngagement.Account__r.Owner.Name));
			}
        }
        /*Set<String> tempSet = new Set<String>();
        list<Milestone1_Project__c> mileStoneEngagementList = [SELECT Account__c, Account__r.OwnerId, Account__r.Owner.Name FROM Milestone1_Project__c WHERE Status__c = 'Active'
                                                                AND Kickoff__c >= :milestoneProject.Kickoff__c AND Deadline__c <= :milestoneProject.Deadline__c];
        for(Milestone1_Project__c mileStoneEngagement:mileStoneEngagementList){
            if(mileStoneEngagement.Account__c != null && tempSet.add(mileStoneEngagement.Account__r.Owner.Name)){               
                 leftOptionsEngagementMgr.add(new selectOption(mileStoneEngagement.Account__r.OwnerId,mileStoneEngagement.Account__r.Owner.Name));
            }           
        }*/
        return leftOptionsEngagementMgr;
    }
    
    public list<selectOption> getAllLeftOptionsProject(){
        leftOptionsProject = new list<selectOption>();
		listEngagementMgr = new list<String>();
		if(selectedValuesEngagementMgr != null && selectedValuesEngagementMgr.trim() != ''){
			listEngagementMgr = selectedValuesEngagementMgr.split(',');
		}
        list<Milestone1_Project__c> mileStoneProjectList = [SELECT Name FROM Milestone1_Project__c WHERE Status__c = 'Active' AND Kickoff__c >= :milestoneProject.Kickoff__c 
        													AND Deadline__c <= :milestoneProject.Deadline__c AND Opportunity__r.Project_Manager__c IN 
        													:listProjectMgr and Account__r.OwnerId IN :listEngagementMgr order by Opportunity__r.Project_Manager__r.LastName];
        for(Milestone1_Project__c lMileStoneProject : mileStoneProjectList){
        	if(milestoneProject.Kickoff__c != null && milestoneProject.Deadline__c != null && selectedValuesProjectMgr != null && 
				selectedValuesProjectMgr.trim() != '' && selectedValuesEngagementMgr != null && selectedValuesEngagementMgr.trim() != '') {
             	leftOptionsProject.add(new selectOption(lMileStoneProject.Id,lMileStoneProject.Name));
			}
        }
        return leftOptionsProject;
    }
    
    public PageReference generateReport() {  
        PageReference pageRef = null;         
        try{         
        	if(selectedValuesProject != null && selectedValuesProject.trim() != ''){
        		pageRef = new PageReference('/apex/GeneratedReport?selectedProjectdIds='+selectedValuesProject);
        	}            
        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));}
        return pageRef;
    }
    
     public PageReference generatePdfReport() {  
        PageReference pageRef = null;         
        try{         
        	if(selectedValuesProject != null && selectedValuesProject.trim() != ''){
        		pageRef = new PageReference('/apex/GeneratedPdfReport?selectedProjectdIds='+selectedValuesProject);
        		//pageRef.getHeaders().put('content-disposition','attachment');
        		//pageRef = new PageReference('/apex/GeneratedReport1');
        		//pageRef.setRedirect(true);
        	}            
        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));}
        return pageRef;
    }
}