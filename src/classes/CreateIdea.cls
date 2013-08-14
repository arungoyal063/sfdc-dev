global class CreateIdea{ 

    // webservice call
   webService static String createIdeaOnCase(String caseId) {   
      return createIdea(caseId);
   }
   
   // Create function for create Idea
   public static String createIdea(String caseId)
   {
           Idea ia;
   Case caseDetails;
   Product2 prodDetails;
   Community commObj;
   caseDetails = [SELECT Id,Resolution_Summary__c,AccountId,Subject,Problem_Statement__c,ProductId,Description FROM Case WHERE Id =: caseId];
   if(caseDetails !=null && caseDetails.ProductId != null)
   {
          prodDetails = [SELECT Id,Name FROM Product2 WHERE Id =: caseDetails.ProductId];        

          List<Community> commList = [SELECT Name,IsActive,Description FROM Community WHERE Name =: prodDetails.Name and IsActive = true LIMIT 1];
          if(commList.isEmpty()) {
              commList  = [SELECT Name,IsActive,Description FROM Community WHERE Name = 'Catch All' and IsActive = true LIMIT 1];   
          } 
          
       if(!commList.isEmpty()) {
           commObj = commList.get(0);
           ia = new Idea();
           ia.Case__c = caseDetails.Id;
           if(commObj != null)
               ia.CommunityId = commObj.Id;
           ia.Title = caseDetails.Subject;
           ia.Body  = caseDetails.Description;
           System.debug('caseDetails.Resolution_Summary__c.......'+caseDetails.Resolution_Summary__c);
           if((caseDetails.Resolution_Summary__c != null) && caseDetails.Resolution_Summary__c.trim().equals('')) {
               ia.Business_Purpose__c =  caseDetails.Resolution_Summary__c;
           } else {
               ia.Business_Purpose__c =  'Created from Case.  Please update this field.';
           }
           
           
           if(caseDetails.ProductId !=null)
           ia.Idea_Product__c  = caseDetails.ProductId;
           
           if(caseDetails.AccountId !=null)
               ia.Institution__c  = caseDetails.AccountId;
           ia.Status  = 'New';
           try
           {
               insert ia;
           }
           catch(Exception ex)
           {
               System.debug('Insertion Issue.'+ex);
       
           }
       }
     }      
   if(ia != null)
   {
        // return ia.Id;
       // return Edit Page URL
       System.debug('ia...'+ia);   
       String URL = '/ideas/editIdea.apexp?c='+commObj.Id+'&id='+ia.Id;
       return URL;
   }
      else
           return 'false';

}

webService static String createIdeaValidation(String caseId)
    {   
     return ideaValidate(caseId);        
   }
   
   public static String ideaValidate(String caseId)
   {    
       CaseArticle ca;
       KnowledgeArticle knowledgeObj;
       Product2 prodDetails;
       List<Community> commObj;

       Case caseDetails = [SELECT Id,Resolution_Summary__c,subject,ProductId,Problem_Statement__c FROM Case WHERE Id =: caseId];
       
      if(caseDetails.subject == null || caseDetails.subject == '')
       {
                return 'Please provide subject to create an Idea.';
       }
      else if(caseDetails.ProductId == null) {
          return 'Please Fill Case Product to create Idea.';
      }
       /*else if(caseDetails.Resolution_Summary__c == null || caseDetails.Resolution_Summary__c == '')
        {
                return 'Please Fill Resolution Summary to create Idea.';
        }*/
      /* else if(caseDetails.ProductId != null)
       {
              prodDetails = [SELECT Id,Name FROM Product2 WHERE Id =: caseDetails.ProductId];        
              commObj = [SELECT Name,IsActive,Description FROM Community WHERE Name =: prodDetails.Name and IsActive = true LIMIT 1];
           if(commObj.size() == 0 ) 
                   return 'Community is not available with supplied Product Name';
              else     
                   return 'success';       
       }         
       else
       {
               return 'Community is not available with supplied Product Name.';
       }*/
       return 'success';
   }
}