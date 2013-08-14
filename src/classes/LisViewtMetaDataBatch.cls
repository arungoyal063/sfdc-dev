/*******************************************************************************************************************
** Module Name   : LisViewtMetaDataBatch
** Description   : Batch Class for Refreshing of Listview Metadata
** Throws        : NA
** Calls         : NA
** Test Class    : LisViewtMetaDataBatchTest
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-16-07  Rainmaker             Initial Version
******************************************************************************************************************/
public class LisViewtMetaDataBatch 
        implements Database.Batchable<Item>,  Database.Stateful, Database.AllowsCallouts {

    private String sessionId;   
    private List<Item> items;
    private Item metaDataJobItem;
    private String RESOURCE_NAME = 'MetaDataBatchResource';
    private List<MetadataCreateJob.MetadataFile> metaDataFiles;
    
    public LisViewtMetaDataBatch(String sessionId, List<Item> items) {
       
        this.sessionId = sessionId;
        this.items = items; 
        metaDataJobItem = this.items[0]; 
        metaDataFiles = new List<MetadataCreateJob.MetadataFile>();    
    }
    
    
    public Iterable<Item> start(Database.BatchableContext info) {
        return new ItemIterable(items);           
    } 
    
    public void execute(Database.batchableContext info, List<Item> scope) {
        
        // Process the given Metadata job items components 
        if(String.isEmpty(sessionId)){
            sessionId = getAPISessionId();    
        }
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        
        Item item = metaDataJobItem;
       
       try {
           if(item.aysncResult == null) {
              
              MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
              retrieveRequest.apiVersion = 28;
              retrieveRequest.packageNames = null;
              retrieveRequest.singlePackage = true;
              retrieveRequest.specificFiles = null;
              retrieveRequest.unpackaged = new MetadataService.Package_x();
              retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
              MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
              packageType.name = 'CustomObject'; //'ListView'; 
              packageType.members = new String[]{'Case', 'Change_Request__c', 'Idea'}; //listViewItemsList;
              retrieveRequest.unpackaged.types.add(packageType);
              
              if(!Test.isRunningTest()){
                  item.aysncResult = service.retrieve(retrieveRequest);
              } else {
                   item.aysncResult =  new MetadataService.AsyncResult();
                   item.aysncResult.message = 'testing apex';
                   item.aysncResult.done = false;
              }
            
           } else if(item.aysncResult != null) {
                   
                  if(!Test.isRunningTest()){
                      item.aysncResult = service.checkStatus(new String[] { item.aysncResult.Id } )[0];
                  } else {    
                       item.aysncResult =  new MetadataService.AsyncResult();
                       item.aysncResult.message = 'testing apex';
                       item.aysncResult.done = true;
                  }
     
                   if(item.aysncResult.done){
                       
                       if(item.isMetadataRecieved) {  // if metadata recieved
                           System.debug('############isResourceCreated Block');
                           metaDataFiles = getResContent(sessionId, new List<String>{'Case.object', 'Change_Request__c.object', 'Idea.object'});
                           item.isResourceCreated = true; 
                       }
                          
                       else {   // if metadata not recieved
                           
                           String MetaDataRetrieveZip;
                           if(!Test.isRunningTest()){
                               MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(item.aysncResult.Id);
                               MetaDataRetrieveZip = retrieveResult.zipFile;
                               System.debug('zip file' + MetaDataRetrieveZip);
                           } else {
                               MetaDataRetrieveZip = 'testing apex';    
                           }
                          
                           
                           if(MetaDataRetrieveZip != null) {
                               item.isMetadataRecieved = true;   
                           }
                           
                           if(item.isMetadataRecieved && (!item.isResourceCreated)) { // static resource not created    
                                System.debug('Request for Metadata Update');
                                MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
                                staticResource.fullName = 'MetaDataBatchResource';
                                staticResource.contentType = 'application/zip';
                                staticResource.cacheControl = 'public';
                                staticResource.content = MetaDataRetrieveZip;
                                MetadataService.UpdateMetadata metadataObj = new MetadataService.UpdateMetadata();  
                                metadataObj.currentName =  staticResource.fullName;
                                metadataObj.metadata =  staticResource;
                                
                                if(!Test.isRunningTest()){
                                    item.aysncResult = service.updateMetadata(new List<MetadataService.UpdateMetadata> { metadataObj })[0];   
                                    System.debug('>>' + item.aysncResult);
                                } else {
                                    item.aysncResult = new MetadataService.AsyncResult();
                                    item.aysncResult.message = 'testing apex';
                                    item.aysncResult.done = false;     
                                }   
                           }    
                       }
                   }
                   
           } 
       } catch(Exception e) {
           item.createException = e;
           System.debug('Exception ::'+ e.getMessage());
       }
    }
    
     public void finish(Database.batchableContext info){
        if (new ItemIterable(items).Iterator().hasNext()){
            run(sessionId, items);
        } else if(MetadataFiles != null && (!MetadataFiles.isEmpty())){
             if(!Test.isRunningTest()){
                 Database.executeBatch(new MetadataCreateJob(MetadataFiles), 1);  
             } 
        } else {
            // metadata retrieve complete
        }       
    }  
    
    
  public static String getAPISessionId(){ 
      partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
      if(!Test.isRunningTest()){  
          API_Only_User_Credentials__c apiUser = API_Only_User_Credentials__c.getInstance('Metadata API User');
          partnerSoapSforceCom.LoginResult loginResult = sp.login(apiUser.Username__c.trim(), apiUser.Password__c.trim()); 
          return loginResult.sessionId;  
      }
      return 'testing apex';
  }   
    
      /** get content of Static Resources by Static Resources names **/
   public List<MetadataCreateJob.MetadataFile> getResContent(String sessionId, List<String> fileList) {
       List<MetadataCreateJob.MetadataFile> metaDataFiles = new List<MetadataCreateJob.MetadataFile>();
       SoapUnzipper.SessionHeader_element sessionHeader = new SoapUnzipper.SessionHeader_element();
       sessionHeader.sessionId = sessionId;
       SoapUnzipper.Unzipper unzipObj = new SoapUnzipper.Unzipper();
       unzipObj.SessionHeader = sessionHeader;
       unzipObj.timeout_x = 120000;
       MetadataCreateJob.MetadataFile metaDataFile;
       
       for(String file :fileList){
           metaDataFile = new MetadataCreateJob.MetadataFile(); 
           metaDataFile.fullName = file;
           
           if(!Test.isRunningTest()){
               metaDataFile.content =  unzipObj.unzipStaticResource(file);
           } else {
               metaDataFile.content = 'testing apex';    
           }
           metaDataFiles.add(metaDataFile); 
       }
       return metaDataFiles;
    }
   
   
   
   
    public static void run(List<Item> items){ 
        run(null, items); 
    }
    
    public static void run(String sessionId, List<Item> items) {
        Database.executeBatch(new LisViewtMetaDataBatch(sessionId, items), 1);     
    }
    
     
    public class Item {
        public Integer index {get; private set;}
        public MetadataService.AsyncResult aysncResult {get; set;}
        public Exception createException  {get; set;}
        public Boolean isMetadataRecieved {get; private set;}
        public Boolean isResourceCreated {get; private set;}
     
        public Item() {
           this.isMetadataRecieved = false;
           this.isResourceCreated = false;
        }
    }
    
    
    /* Internal Metadata interator implementation for Batch Apex job
     **/ 
    private class ItemIterator
        implements Iterator<Item>
    {
        private List<Item> items;
        private Integer nextIdx;
        
        public ItemIterator(List<Item> items)
        {
            this.items = items;
            this.nextIdx = 0;
        }
        
        public boolean hasNext()
        {
            return nextIdx >= items.size() ? false : true;
        }
        
        public Item next()
        {
            return items[nextIdx++];
        }
    }
    
     
    /**
     * Internal Metadata Items Iterable implementation for Batch Apex job
    **/
    
    private class ItemIterable implements Iterable<Item> {
        private List<Item> iteratorItems;
        
        public ItemIterable(List<Item> items) {
            iteratorItems = new List<Item>();
            for(Item item : items)
            {
                if(item.aysncResult!=null && item.aysncResult.done)  // if job completed but metadata not recieved
                    continue;
                if(item.isMetadataRecieved && item.isResourceCreated) // if metadata recieved but resource not created
                    continue;
                if(item.createException != null)  // if exception occur
                    continue;
                    
                iteratorItems.add(item);
            }
        }
        
        public Iterator<Item> Iterator() {
            return new ItemIterator(iteratorItems);
        }        
    }
    
    
}