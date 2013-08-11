trigger taskBeforeInsert on Task (before insert) {
	for (Task t : Trigger.New) {
		if (t.Subject.StartsWith('Email:') || t.Subject.StartsWith('Mass Email:')) {
			t.type = 'Email';
		}	
	}
}