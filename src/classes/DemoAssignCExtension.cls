public with sharing class DemoAssignCExtension {
    private Contact contact;
    //Create a List of Queues for dropdown selection
    List<Queue__c> queues;
    //String to hold ID of selected queue
    private String selectedQueue;
    //Boolean used to indicate whether the save button is available or not
    private Boolean canSave = false;
    public String encodedFullName;
    public String UserId;
    
    public DemoAssignCExtension(Apexpages.Standardcontroller stdController)
    {
        //Default Constructor
        this.contact = (Contact)stdController.getRecord();
        //Gather a list of queues
        this.queues = [SELECT
        Queue__c.Id,
        Queue__c.Name
        FROM Queue__c
        ORDER BY Queue__c.Name];
    }
    //Selected Queue Properties
    public String getSelectedQueue()
    {
        return this.selectedQueue;
    }
    public void setSelectedQueue(String s)
    {
        this.selectedQueue = s;
    }
    //Queue Dropdown Options
    public List<SelectOption> getAvailableQueues()
    {
        List<SelectOption> options = new List<SelectOption>();
        if (this.queues.size() > 0)
            options.add(new SelectOption('-SELECT-','-SELECT-'));
        for (Queue__c queue:this.queues)
        {
            options.add(new SelectOption(queue.Id,queue.Name));
        }
        return options;
    }
    public void CheckSelection()
    {
        if (this.selectedQueue <> null && this.selectedQueue <> '-SELECT-')
            this.canSave = true;
        else
            this.canSave = false;
        //throw new CustomException(String.valueOf(this.canSave));
    }
    //Save button properties
    public Boolean getCanSave()
    {
        return this.canSave;
    }
    public Pagereference Assign()
    {
        //Occurs when assignment occurs
        //Gather the Positions for selected queue
        List<Position__c> pos = new List<Position__c>();
        pos = [SELECT
        Position__c.Id,
        Position__c.Queue__c,
        Position__c.Name,
        Position__c.User__c,
        Position__c.Last_Assigned__c
        FROM Position__c
        WHERE Position__c.Queue__c = :this.selectedQueue
        ORDER BY Position__c.Last_Assigned__c, Name];
        //Ensure that positions were collected
        if (pos.size() > 0)
        {
            //Redirect to an Event Page - Prepoulated with Information through URL parameters
            //Create URL string for sending Request
            //Event Prefix ID
            String url = '/00U/';
            //Add on the WhoIs ID
            url += 'e?who_id=' + this.contact.Id;
            //Add on User Assigned to
            List<User> user = [SELECT
            User.FirstName,
            User.LastName
            FROM User
            WHERE User.Id = :pos[0].User__c];
            if (user.size() > 0)
            {
                
                String FullName = user[0].FirstName + ' ' + user[0].LastName;
                encodedFullName = System.Encodingutil.urlEncode( FullName, 'UTF-8');
                url += '&evt1_lkold=' + System.Encodingutil.urlEncode( FullName, 'UTF-8');
                UserId = String.valueOf(pos[0].User__c).substring(0, String.valueOf(pos[0].User__c).length()-3);
                url += '&evt1_lkid=' + String.valueOf(pos[0].User__c).substring(0, String.valueOf(pos[0].User__c).length()-3);
                url += '&evt1='+ System.Encodingutil.urlEncode( FullName, 'UTF-8');
            }
            Pagereference p = new Pagereference(url);
            p.setRedirect(true);
            //Update the Position with today's date and time
            pos[0].Last_Assigned__c = Datetime.now();
            update(pos[0]);
            return p;
        }
        else
        {
            //No positions were found - notify user that this queue is unavailable
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'There are no Positions in this Queue! Please Select another Queue.'));
            return null;
        }
    }
    public class CustomException extends Exception{}
    public static testMethod void testDemoAssignCExtension()
    {
    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
    	//Dynamically Create a Queue
    	Queue__c testQueue = new Queue__c();
    	testQueue.Name = 'TEST';
    	insert(testQueue);
    	//Dyanmically Create a Position Record
    	Position__c testPosition = new Position__c();
    	testPosition.Name = 'TEST';
    	testPosition.Queue__c = testQueue.Id;
    	testPosition.Last_Assigned__c = Datetime.now().addDays(-1);
    	testPosition.User__c = thisUser.Id;
    	insert(testPosition);	

        //Create a Contact and then assign the controller to it
        Contact contact = new Contact();
        contact.LastName = 'Test';
        insert(contact);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(contact);
        DemoAssignCExtension extension = new DemoAssignCExtension(controller);
        //Test the rest of the methods and success
        //Set dropdown selection to an existing queue id
        //Get a list of options and select the first Queue in the list
        List<SelectOption> options = extension.getAvailableQueues();
        //JGP Modification to pass production test dynamically
        if (options.size() > 1) //There are existing queues
        {
        	//Set to the first Queue Available
        	for (SelectOption so:options)
        	{
        		if (so.getLabel() == 'TEST')
        			extension.setSelectedQueue(so.getValue());
        	}        	
        }
        //See if we can save
        Boolean temp = extension.getCanSave();
        //Run check on selection
        extension.CheckSelection();
        //Read the selected queue
        String selectedQueue = extension.getSelectedQueue();
        String assign = extension.Assign().getUrl();
    }
}