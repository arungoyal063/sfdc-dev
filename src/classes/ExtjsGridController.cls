/*******************************************************************************************************************
** Module Name   : ExtjsGridController
** Description   : This class is used for refreshing of ListView metadata from UI.
** Throws        : NA
** Calls         : NA
** Test Class    : ExtjsGridControllerTest
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author    WO#         Description of Action
** 1.0      2013-16-07  Rainmaker             Initial Version
******************************************************************************************************************/


public without sharing class ExtjsGridController {

    public String MetaDataFolder {get; set;}
    public String MetaDataType {get; set;} 
    public MetadataService.AsyncResult AsyncResult {get; private set;}        
    public String MetaDataRetrieveZip { get; private set; } // files unzipping complete or not   
    public List<MetadataCreateJob.MetadataFile> MetadataFiles { get; set; }  // List of metadata files     
    public Boolean metadataRes{get; private set;} // metadata recieve complete or not
    public String MetadataFileName {get; set;}    // metadata file name
    public String MetadataFileData {get; set;}    // file metadata content
    private MetadataService.MetadataPort service {get; set;} // service variable
    private List<String> listViewItemsList = new List<String>();     // ListView items List  
    
   public ExtjsGridController() {
        metadataRes = true;        
        try {
            fetchItemsList();
        } catch(NoAccessException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Login user doesn\'t have permission to Access Salesforce Metadata.'));    
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, e.getMessage()));
        }        
   }
   
   
   public void fetchItemsList(){            
        service  = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.type_x = 'ListView';
        queries.add(queryLayout);       
        MetadataService.FileProperties[] fileProperties;
        
        if(!Test.isRunningTest()){
            fileProperties = service.listMetadata(queries, 27);
        } else {
             MetadataService.FileProperties peopertyObj  = new  MetadataService.FileProperties();
             peopertyObj.fullName = 'Case.testView';
             fileProperties  = new List<MetadataService.FileProperties>{peopertyObj};
        }
        
        listViewItemsList = new List<String>(); 
        if(fileProperties!=null && FileProperties.size() > 0 ) {
            for(MetadataService.FileProperties fileProperty : fileProperties){
                if(fileProperty.fullName.startsWith('Case')){
                    listViewItemsList.add(fileProperty.fullName);
                }
            }
            listViewItemsList.sort();        
        }    
   }
    
    public void init(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
        metadataRes = false;
        MetaDataRetrieveZip = null;
        MetadataFiles = null;
        
        try {
            if(!listViewItemsList.isEmpty()) {
                MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
                retrieveRequest.apiVersion = 27;
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
                    AsyncResult = service.retrieve(retrieveRequest);
                } else {    
                   AsyncResult =  new MetadataService.AsyncResult();
                   AsyncResult.message = 'testing apex';
                   AsyncResult.done = false;    
                }
                System.debug(AsyncResult);
            } 
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, e.getMessage()));    
        }
    }
    
    
    public PageReference checkAsyncRequest()
    {
        // Check the status of the retrieve request
        service = createService();  
        System.debug(AsyncResult.Id);   
        MetadataService.AsyncResult[] aysncResults;
        
        if(!Test.isRunningTest()){
            aysncResults = service.checkStatus(new String[] { AsyncResult.Id });
        } else {
            aysncResults = new List<MetadataService.AsyncResult>();
            MetadataService.AsyncResult aysncResultObj =  new MetadataService.AsyncResult(); 
            aysncResultObj.message = 'testing apex';
            aysncResultObj.done = true; 
            aysncResults.add(aysncResultObj); 
        }
        
        System.debug('@@@'  + aysncResults[0]);
        if(aysncResults[0].done)
        {
           
            if(aysncResults[0].state == 'Error')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, aysncResults[0].message));
                AsyncResult = null;             
            }
            else
            {
                System.debug('RESPONSE::SUCCESS');
                // Place Base64 encoded zip data onto the page for the JSZip library to handle
                if(!Test.isRunningTest()){
                    MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(AsyncResult.id);
                    MetaDataRetrieveZip = retrieveResult.zipFile;
                } else {
                    MetaDataRetrieveZip = 'testing apex';    
                }
                
                MetadataFiles = new List<MetadataCreateJob.MetadataFile>();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
                metadataRes = true;
                AsyncResult = null;
           }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
        }  
        
        return null;
    }
    
    
    public PageReference receiveMetadataZipFile() {
    
     
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding ' + MetaDataFileName + '...'));
        MetadataCreateJob.MetadataFile metaDataFile = new MetadataCreateJob.MetadataFile();
        metaDataFile.fullName = MetaDataFileName;
        metaDataFile.content = MetaDataFileData;
        MetadataFiles.add(metaDataFile);
        return null;
        
        
        /*XmlStreamReader xmlReader = new XmlStreamReader(MetadataFileData);
        
         while(xmlReader.hasNext()) {
              if (xmlReader.getEventType() == XmlTag.START_ELEMENT) {
                  if ('listViews' == xmlReader.getLocalName()) {
                      System.debug('>>> ListView found');
                  }
              }
         
         }  */
        
    }
    
    
    public PageReference receiveComplete()
    {
        // Completed, cleared Base64 encoded zip data from viewstate
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Metadata retrieve completed'));
        MetaDataRetrieveZip = null;  
        Database.executeBatch(new MetadataCreateJob(MetadataFiles), 1);   
        return null;
    }
    
    
    /**
     * Simple container class for retrieve metadata file, may as well leverage the Metadata API class for this
     **/
    public class MetadataFile extends MetadataService.MetadataWithContent
    {
        public String getFullname()
        {
            return fullName;
        }
        
        public String getContent()
        {
            return content;
        }
    }
    
    
    private MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }  
    
}