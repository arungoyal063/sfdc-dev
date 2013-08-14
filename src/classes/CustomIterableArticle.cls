global class CustomIterableArticle 
   implements Iterator<FAQ__kav >{ 

   List<FAQ__kav > faq {get; set;} 
   Integer i {get; set;} 

   public CustomIterableArticle(){ 
       //datetime d = system.Today().addDays(-1);
       DateTime startDT=system.now().AddMinutes(-15); 
       DateTime endDT=system.now(); 
       system.debug(startDT);
       system.debug(endDT);
       faq = [Select Id, lastPublishedDate, KnowledgeArticleId, ArticleNumber, UrlName, Summary, Title, attachment_5__Body__s,
              attachment_4__Body__s, Attachment__Body__s, Attachment_3__Body__s, Attachment_2__Body__s, FAQ_Details__c, Type__c,
              Partner__c, Partner_Article_ID__c, FirstPublishedDate, LastModifiedDate, Attachment__Name__s, Attachment__ContentType__s 
              from FAQ__kav where PublishStatus = 'online' and Language = 'en_US'  and lastPublishedDate >: startDT and lastPublishedDate <: endDT Limit 50]; 
       i = 0; 
   }   

   global boolean hasNext(){ 
       if(i >= faq.size()) {
           return false; 
       } else {
           return true; 
       }
   }    

   global FAQ__kav next(){ 
       // 8 is an arbitrary 
       // constant in this example
       // that represents the 
       // maximum size of the list.
       if(i == 50){return null;} 
       i++; 
       return faq[i-1]; 
   } 
}