@isTest
private class LisViewtMetaDataBatchTest {
   static testmethod void testschedule() {
   		List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
        User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
        system.runAs(mockUser){
	       Test.startTest();  
	       List<LisViewtMetaDataBatch.Item> itemsList = new List<LisViewtMetaDataBatch.Item>();
	       LisViewtMetaDataBatch.Item scheduleItem = new LisViewtMetaDataBatch.Item();
	       itemsList.add(scheduleItem);
	       LisViewtMetaDataBatch.run(itemsList); 
	       Test.stopTest();
        }
   }
}