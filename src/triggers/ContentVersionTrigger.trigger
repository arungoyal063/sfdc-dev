trigger ContentVersionTrigger on ContentVersion bulk (before insert, before update) {

	if((trigger.isInsert) || (trigger.isUpdate)){
			ContentVersion[] items = Trigger.new;
			ContentManagementService.applyFormulas(items);
		
	}
}