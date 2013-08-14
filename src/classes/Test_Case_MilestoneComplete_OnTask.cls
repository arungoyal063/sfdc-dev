@isTest
private class Test_Case_MilestoneComplete_OnTask {
	
	
    
   	static testMethod void myUnitTest() {
   		List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
	    User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
	    System.runAs(mockUser){
    		Case c1=  MockTestData.createCaseRecord('New', 'Web', 'Level 3' , 'Test 1', 'test');
        	Task t1 = MockTestData.createTaskRecord(c1.Id);
    	}
    }
    
    static testMethod void myUnitTest2() {
   		List<Profile> pfList = new List<Profile>([SELECT id, name FROM Profile WHERE name =: 'System Administrator']);    
	    User mockUser = [SELECT User.Id FROM User WHERE User.Id =:UserInfo.getUserId()];
	    System.runAs(mockUser){
    		Case c1=  MockTestData.createCaseRecord('New', 'Web', 'Level 3' , 'Test 1', 'test');
        	Task t1 = MockTestData.createTaskRecord(c1.Id);
        	t1.status = 'Completed';
        	update t1;
    	}
    }
}