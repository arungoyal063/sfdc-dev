<?xml version="1.0" encoding="UTF-8"?>

<!-- 

This file is used by the Apex class "SubscribeLead,"
which serves as the custom controller for the Visualforce page "SubscribeLead"
	
CUSTOMIZATION INSTRUCTIONS: Edit the attributes below to match
the names of merge tags in your MailChimp list and lead fields
in your Salesforce CRM org.

* code = "Secret" code that must be sent along with the WebHook data

* sf:idField = Name of external ID field in Salesforce which will be set to the MailChimp list member ID
* sf:leadSource = Value of Lead Source set for the new lead record
* sf:status = Value of Lead Status set for the new lead record

* mc:mergeTag = Name of the MailChimp merge tag
* sf:field = The API name of the Salesforce CRM lead field to which the merge tag value should be mapped.

* sf:isLeadAddress = true or false, indicates whether the named MailChimp merge tag
  is to be used as the lead address

-->
	
<config id="subscribeLead" xmlns:mc="mailchimp" xmlns:sf="salesforce" code="_I_Love_MailChimp_">
		
	<mappings sf:idField="MailChimp_ID__c" sf:leadSource="MailChimp List" sf:status="Subscribed to MailChimp list" >	
		
		<!-- Simple mapping of MailChimp merge tags to standard Salesforce lead fields -->
		<mapping mc:mergeTag="PREFIX"  sf:field="Salutation" />
		<mapping mc:mergeTag="FNAME"   sf:field="FirstName" />
		<mapping mc:mergeTag="LNAME"   sf:field="LastName" />
		<mapping mc:mergeTag="TITLE"   sf:field="Title" />
		<mapping mc:mergeTag="COMPANY" sf:field="Company" />
		<mapping mc:mergeTag="URL"     sf:field="Website" />
		<mapping mc:mergeTag="MOBILE"  sf:field="MobilePhone" />
		<mapping mc:mergeTag="PHONE"   sf:field="Phone" />
		<mapping mc:mergeTag="FAX"     sf:field="Fax" />
		<mapping mc:mergeTag="EMPLOYEES" sf:field="NumberOfEmployees" />
		<mapping mc:mergeTag="LOCATIONS" sf:field="NumberOfLocations" />
		
		<!-- MailChimp address merge tag to Salesforce Lead address-related fields -->
		<mapping mc:mergeTag="ADDRESS" sf:isLeadAddress="true" />
		
		<!-- MailChimp interest groups 
		(Note: this is the first "non-hidden" interest group in your list; you'll need
		to change the sf:field name to the name of your custom Salesforce lead field that holds this data) -->
		<mapping mc:mergeTag="INTERESTS" sf:field="Interest_Groups__c" />	
				
	</mappings>
	
	<options sf:useDefaultAssignmentRule="false" sf:allowFieldTruncation="true" />
	
</config>
