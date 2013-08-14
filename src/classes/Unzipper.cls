global class Unzipper
{   
    webService static String unzipStaticResource(String fileName) {
        if(!Test.isRunningTest()){
            PageReference contentPage = new PageReference('/resource/MetaDataBatchResource/objects/' + fileName); return contentPage.getContent().toString();  
        } else {
            return 'testing apex';
        }
    }    
}