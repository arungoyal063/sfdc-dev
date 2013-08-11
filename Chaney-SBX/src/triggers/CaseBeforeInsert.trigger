trigger CaseBeforeInsert on Case (before insert,before update) {
	List <String> accountNumList = new List<String>();
	for (Case c : Trigger.new) {
		System.debug('Inside Case --> ' + c.Account_Number__c);
		accountNumList.add(c.Account_Number__c);
	}
	
	List <Account> aList = [select id,Account_Num__c from Account where Account_Num__c in :accountNumList];
	Map <String,Id> accountMap = new Map<String,ID>();
	for (Account a: aList){
		System.debug('Inside Account Map --> ' + a.Account_Num__c);
		accountMap.put(a.Account_Num__c,a.id);
	}
	
	for (Case c : Trigger.new) {
		System.debug('accountMap.get(c.Account_Number__c) ---> ' + accountMap.get(c.Account_Number__c));
		c.AccountId = accountMap.get(c.Account_Number__c);
		System.debug('c.AccountId ---> ' + c.AccountId);
	}

}