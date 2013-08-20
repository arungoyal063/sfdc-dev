trigger PriceBookEntryTrigger on Product2 (after insert, after update, before delete) {
	    
    if(trigger.isInsert || trigger.isUpdate){
        List<PriceBook2> standardPB = [SELECT Id FROM PriceBook2 WHERE IsStandard = true LIMIT 1];
        if (standardPB != NULL && standardPB.size() != 0) {
            PriceBook2 stdPriceBook = standardPB.get(0);
            
            List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();
            List<PriceBookEntry> pbEntriesForUpdate = new List<PriceBookEntry>();
            List<Id> insertedProductIds = new List<Id>();               
            for (Product2 product : Trigger.new) {            
                insertedProductIds.add(product.Id);
            }
            Map<Id, PriceBookEntry> existingEntries = new Map<Id, PriceBookEntry>();
            // removed LIMIT 1
            for (PriceBookEntry pbe : [SELECT IsActive, Id, Product2Id FROM PriceBookEntry WHERE Product2Id IN :insertedProductIds AND PriceBook2Id = :stdPriceBook.Id]) {
                existingEntries.put(pbe.Product2Id, pbe);
            }
            for (Product2 product : Trigger.new) {
                if (existingEntries.get(product.Id) == NULL) {
                    PriceBookEntry newEntry = new PriceBookEntry(
                        Product2Id = product.Id,
                        PriceBook2Id = stdPriceBook.Id,
                        UnitPrice = 1.0,
                        IsActive = product.IsActive  // changed from true to product's active state
                    );
                    pbEntries.add(newEntry);
                }
                /*----
                    Arun:rainmaker Code to update the pricebook entry's IsActive field
                    Date: 04/16/2013
                -----*/
                else{
                    PricebookEntry pbe = existingEntries.get(product.Id);
                    if(pbe != null){
                        pbe.IsActive = product.IsActive;
                        pbEntriesForUpdate.add(pbe);
                    }                   
                }
                /*----
                    Arun:rainmaker Code to update the pricebook entry's IsActive field
                    Date: 04/16/2013
                -----*/
            }
            insert pbEntries;
            update pbEntriesForUpdate;
        }
    }
    
    /*----
        Arun:rainmaker Code impletmented to avoid the SOQL Limitand category reached issue
        Date: 04/12/2013
    -----  
    Map<Id, Category__c> insertCategoriesMap = new Map<Id, Category__c>();
    Map<Id, Category__c> updateCategoriesMap = new Map<Id, Category__c>();
    Map<String, Category__c> categoryMap = new Map<String, Category__c>();
    List<Category__c> categoryList = [SELECT Name, Count__c FROM Category__c ORDER BY Name];
    
    for(Category__c cat : categoryList){
        categoryMap.put(cat.Name, cat);
    }
    
    if(trigger.isInsert || trigger.isUpdate){
        for (Integer i = 0 ;i < Trigger.New.Size(); i++){
            Product2 newProduct =  (Product2)Trigger.New[i];
            Category__c newCat = categoryMap.get(newProduct.Product_Category__c);
            if(trigger.isInsert){           
                if(newCat == null ){                                                 //if the category is new
                    Category__c categoryObj = new Category__c();
                    categoryObj.Name = newProduct.Product_Category__c;
                    if(newProduct.IsActive){                                        //increase the count only if product is in active state
                        categoryObj.Count__c = 1;
                        categoryMap.put(categoryObj.Name, categoryObj);
                    }   
                    insertCategoriesMap.put(categoryObj.id, categoryObj);
                }
                else{
                    if(newProduct.IsActive){     
                    	if(newCat.Count__c==null){
                    		newCat.Count__c =1;
                    	}   else{                                //if the category is not new and used in some other product as well
                        	newCat.Count__c = newCat.Count__c + 1;
                        }              
                        updateCategoriesMap.put(newCat.Id, newCat);
                    }               
                }
            }
            if(trigger.isUpdate){
                Product2 oldProduct =  (Product2)Trigger.Old[i];
                Category__c oldCat = categoryMap.get(oldProduct.Product_Category__c);
                if(newProduct.Product_Category__c != null && oldProduct.Product_Category__c != null && !newProduct.Product_Category__c.equals(oldProduct.Product_Category__c)){// The Products with modified PC
                    if(newCat == null){                                             //if the category is new
                        Category__c categoryObj = new Category__c();
                        categoryObj.Name = newProduct.Product_Category__c;
                        if(newProduct.IsActive){
                            categoryObj.Count__c = 1;
                            categoryMap.put(categoryObj.Name, categoryObj);
                        }
                        insertCategoriesMap.put(categoryObj.id, categoryObj);
                    }
                    else{      
                        if(newProduct.IsActive){                                    //if the category is not new and used in some other product as well
                            newCat.Count__c = newCat.Count__c + 1;                      
                            updateCategoriesMap.put(newCat.id, newCat);
                        }
                    }
                    if(oldCat != null){
                        if(oldProduct.IsActive){
                            oldCat.Count__c = oldCat.Count__c - 1;
                            updateCategoriesMap.put(oldCat.id, oldCat);
                        }
                    }                   
                }
                else if(oldProduct.Product_Category__c == null && newProduct.Product_Category__c != null){
                	if(newCat == null){
                        Category__c categoryObj = new Category__c();
                        categoryObj.Name = newProduct.Product_Category__c;
                        if(newProduct.IsActive){
                            categoryObj.Count__c = 1;
                            categoryMap.put(categoryObj.Name, categoryObj);
                        }
                        insertCategoriesMap.put(categoryObj.id, categoryObj);
                    }
                    else{      
                        if(newProduct.IsActive){                                  
                            newCat.Count__c = newCat.Count__c + 1;                      
                            updateCategoriesMap.put(newCat.id, newCat);
                        }
                    }
                }
                else if(oldProduct.Product_Category__c != null && newProduct.Product_Category__c == null){
                	if(oldCat != null){
                        if(oldProduct.IsActive){
                            oldCat.Count__c = oldCat.Count__c - 1;
                            updateCategoriesMap.put(oldCat.id, oldCat);
                        }
                    }
                }
                else{
                    if(newCat != null && !oldProduct.IsActive && newProduct.IsActive){
                        newCat.Count__c = newCat.Count__c + 1;          
                        updateCategoriesMap.put(newCat.id, newCat);
                    }
                    else if(newCat != null && oldProduct.IsActive && !newProduct.IsActive){
                        newCat.Count__c = newCat.Count__c - 1;              
                        updateCategoriesMap.put(newCat.id, newCat);
                    }
                }
            }                   
        }
    }
    
    if(trigger.isDelete){
        for (Integer i = 0 ;i < Trigger.old.Size(); i++){
            Product2 oldProduct =  (Product2)Trigger.Old[i];
            Category__c oldCat = categoryMap.get(oldProduct.Product_Category__c);   //The Products has been deleted
            if(oldProduct.IsActive){
                oldCat.Count__c = oldCat.Count__c - 1;          
                updateCategoriesMap.put(oldCat.id, oldCat);
            }
        }       
    }      
    
    try{
        List<Category__c> insertCategoriesList = new List<Category__c>();
        List<Category__c> updateCategoriesList = new List<Category__c>();
        insertCategoriesList = insertCategoriesMap.values();
        updateCategoriesList = updateCategoriesMap.values();        
        insert insertCategoriesList;
        update updateCategoriesList;
    }    
    catch(Exception e){
        System.debug('Message'+e.getMessage());
    }    
    /*----
        Arun:rainmaker Code impletmented to avoid the SOQL Limitand category reached issue
        Date: 04/12/2013
    -----*/  
}