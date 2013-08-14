global class createArticle { 

   webService static String createArticleOnCase(String caseId){   
        return createArticleCase(caseId);
   } 
 
 public static String createArticleCase(String caseId){
    CaseArticle ca;
   KnowledgeArticle knowledgeObj;
   FAQ__kav article;
   Case caseDetails = [SELECT Id,Resolution_Summary__c,Status,subject,Problem_Statement__c FROM Case WHERE Id =: caseId];
   if(caseDetails != null)
       {
            // code for  articles
             article = new FAQ__kav();
             String artilceTitle =  caseDetails.subject;            
             article.put('title', artilceTitle);
             
             System.debug('caseDetails.Problem_Statement__c..........'+caseDetails.Problem_Statement__c);
             System.debug('caseDetails.Resolution_Summary__c..........'+caseDetails.Resolution_Summary__c);
             
             if(caseDetails.Problem_Statement__c == null)
                     caseDetails.Problem_Statement__c = '';
                 
             if(caseDetails.Resolution_Summary__c == null)
                      caseDetails.Resolution_Summary__c = '';
                     
             article.put('FAQ_Details__c','Problem Statement: '+caseDetails.Problem_Statement__c+'<br/>'+'Resolution Summary: '+caseDetails.Resolution_Summary__c);  

             String NewString = caseDetails.subject.replace(' ', '-');  
             String Urlname =   NewString + '' + System.now().getTime();
//              String Urlname =   caseDetails.subject.replace(' ', '-');
             article.put('UrlName',Urlname);  
            try {
                    System.debug('insert article.4....');
                    insert article;
                    System.debug('insert article...5...'+article);
                }
             catch(Exception ex)
                {
                        System.debug('Exception on article....'+ex.getMessage());
                        Integer firstIndex = ex.getMessage().indexOf('first error:');
                        String msg = ex.getMessage().substring(firstIndex+12);
                        return msg;
                }
                // fecth knowledge article
                System.debug('article.........'+article.id);
              //  knowledgeObj = [SELECT ArticleNumber,createdDate FROM KnowledgeArticle  where Id != null order by  createdDate desc LIMIT 1];
              
              knowledgeObj = [SELECT ArticleNumber,createdDate FROM KnowledgeArticle order by  createdDate desc LIMIT 1];
              
           //   product__kav knowledgeObja = [SELECT ArticleNumber,createdDate FROM product__kav  WHERE PublishStatus='Draft' AND Language = 'en_US' order by  createdDate desc LIMIT 1];
                
                
                System.debug(' knowledgeObj.........'+ knowledgeObj.id);
        //        System.debug(' knowledgeObja.........'+ knowledgeObja.id);      
              
                      
                if(knowledgeObj.Id != null)           
                {
                    System.debug(' knowledgeObj..inside if');
                    ca = new CaseArticle();
                    ca.CaseID = caseId;
                    ca.KnowledgeArticleId = knowledgeObj.Id;
                    insert ca; 
                    System.debug(' knowledgeObj..after insert');
                }
                /* Code Commented
              // update case
                   caseDetails.Status = 'Closed';
                    try
                    {
                        update caseDetails;
                    }
                    catch(Exception ex)
                    {
                        System.debug('Exception'+ex);
                    }  
                    */
       }
       if(knowledgeObj.Id != null)
              return knowledgeObj.Id;  
        else
        return 'false';
 }

webService static String createArticleValidation(String caseId){   
       return articleValidation(caseId);
}
public static String articleValidation(String caseId){
    CaseArticle ca;
       Case caseDetails = [SELECT Id,Resolution_Summary__c,subject,Status,Problem_Statement__c FROM Case WHERE Id =: caseId];
/*       
       if(caseDetails.Status == 'Closed')
       {
           return 'Case is already closed.';
       } 
*/       
      if(caseDetails.subject == null || caseDetails.subject == '')
       {
                return 'Please provide subject to create an Article.';
       }         
       else
       {    
               return 'success';
       }
       return 'success';     
   }
}