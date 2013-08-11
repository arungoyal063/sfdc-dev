public class TriggerTests {
		static testMethod void taskTest() {
			Task t  = new task();
			t.activitydate = system.today();
			t.Subject = 'Email: xxx';
			insert t;
		}
		
		static testMethod void leadTest() {
			
			Campaign c = new Campaign();
			c.name = 'Robert Jones';
			insert c;
			
			Lead l  = new lead();
			l.LastName='tester';
			l.FirstName='joe';
			l.Company='comp1';
			l.Lead_Created_From_Sales_Lead__c = True;
			l.Lead_Submitted_By__c = 'Robert Jones';
		
			insert l;
		}
		
		
}