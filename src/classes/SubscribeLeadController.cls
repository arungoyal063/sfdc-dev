/*
Copyright (c) 2010 MailChimp / The Rocket Science Group, http://www.mailchimp.com 
All rights reserved.
Author: Mike Epstein, eFactory, Inc., http://efactory.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the copyright holder or author may not be used 
   to endorse or promote products derived from this software 
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


/*
This class serves as the custom controller for 
the Visualforce page "SubscribeLead"
*/

public with sharing class SubscribeLeadController {

	private Dom.Document m_config;
	private Map<String,Object> m_map;
	
	private static final String NOT_PROVIDED = '[Not provided]';


	/**
	* Action method called by the Visualforce page
	*/
	public PageReference handleSubscribeLead() {
		
		System.debug(toDebugString('Starting handleSubscribeLead()'));
        
        // Validate "secret" code
        if (!isValidRequestCode()) {
        	// Don't tell the caller anything...
        	return null;
        }
        
        // Make sure we got an email address in the posted data
        String requestEmail = ApexPages.currentPage().getParameters().get('data[email]');
        if (!hasValue(requestEmail)) {
        	// No email in posted data - maybe request is not from
        	// MailChimp WebHook? Just exit silently - don't give any clues...
        	System.debug(toDebugString('Email missing'));
        	return null;
        }
        
        // Make sure we don't already have a lead with the same email address
        try {
        	Lead existingLead = [ SELECT Id, Name, Email FROM Lead WHERE Email = :requestEmail LIMIT 1 ];
        	if (existingLead != null) {
        		// Found existing lead
        		System.debug(toDebugString('Found existing lead: ' + existingLead));
        		return null;
        	}
        }
        catch (Exception ex) {
        	// No existing lead, keep going
        	System.debug(toDebugString('No existing leads found with email: ' + requestEmail));
        }
        
        // Create and populate new lead
        Lead newLead = populateLead(new Lead());
        
        // Set options
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = this.allowFieldTruncation();
        dmo.assignmentRuleHeader.useDefaultRule = this.useDefaultAssignmentRule();
        newLead.setOptions(dmo);
        
        // Insert new lead
        try {
        	Database.Saveresult saveResult = Database.insert(newLead);
        	System.debug(toDebugString('Successfully inserted lead: ' + saveResult));
        }
        catch (Exception ex) {
        	System.debug(toDebugString('Error inserting lead: ' + ex));
        }
        
  		// Display current page
		return null;
	}
	
	/**
	* Sets the lead fields according to the mapping defined in the
	* XML configuration document
	*/
	private Lead populateLead(Lead myLead) {
		
		SObject sobj = (SObject)myLead;
		
        Map<String,Object> myMap = getMap();
        for (String fieldName : myMap.keySet()) {
        	try {
        		sobj.put(fieldName, myMap.get(fieldName));
        	}
        	catch (Exception ex) {
        		// Just keep going...
        		System.debug(toDebugString('Unable to populate lead field: ' + fieldName + '\n' + ex));
        	}
        }
        
        // Make sure required fields are set
        if (!hasValue(String.valueOf(sobj.get('LastName')))) {
        	sobj.put('LastName', NOT_PROVIDED);
        }
        if (!hasValue(String.valueOf(sobj.get('Company')))) {
        	if (!Schema.sObjectType.Lead.fields.Company.isNillable()) {
        		// PersonAccounts are not enabled - Company is required...
        		sobj.put('Company', NOT_PROVIDED);
        	}
        }
		
		return myLead;
	}
	
	/**
	* Used by test methods to create test configurations
	*/
	private void setConfig(Dom.Document config) {
		this.m_config = config;
	}
	
	/**
	* Loads the XML configuration static resource
	*/
	public Dom.Document getConfig() {
		// Exceptions not caught here - failure to load
		// configuration file is a fatal error
		if (this.m_config == null) {
			StaticResource sr = [ SELECT Body, Name FROM StaticResource WHERE Name = 'SubscribeLeadConfig' LIMIT 1 ];
			String xml = sr.Body.toString();
			this.m_config = new Dom.Document();
			this.m_config.load(xml);
		}
		return this.m_config;
	}
	
	/**
	* Validates the "secret" code in the HTTP request against the "secret"
	* code defined in the configuration
	*/
	private Boolean isValidRequestCode() {
		String requestCode = ApexPages.currentPage().getParameters().get('code');
        String configCode = getConfig().getRootElement().getAttribute('code', null);
        if (configCode.equals(requestCode)) {
        	return true;
        }
        else {
        	System.debug(toDebugString('Invalid code: ' + requestCode));
        	return false;
        }
	}
	
	public Boolean useDefaultAssignmentRule() {
		Dom.Xmlnode optionsNode = getConfig().getRootElement().getChildElement('options', null);
		return (optionsNode != null && isTrue(optionsNode.getAttribute('useDefaultAssignmentRule', 'salesforce')));
	}
	
	public Boolean allowFieldTruncation() {
		// Default is false
		Dom.Xmlnode optionsNode = getConfig().getRootElement().getChildElement('options', null);
		return (optionsNode != null && isTrue(optionsNode.getAttribute('allowFieldTruncation', 'salesforce')));
	}
	
	//private void setMap(Map<String,Object> value) {
	//	this.m_map = value;
	//}
	
	public Map<String,Object> getMap() {
		
		if (m_map == null) {
		
			// Map of Salesforce Lead field names to field values
			m_map = new Map<String,Object>();
			
			// Request parameters posted by WebHook
			Map<String,String> requestParams = ApexPages.currentPage().getParameters();
			
			// Mapping node from XML configurtion file
			Dom.XmlNode mappingsNode = getConfig().getRootElement().getChildElement('mappings', null);
			
			// Email
			String email = requestParams.get('data[email]');
			if (hasValue(email)) {
				m_map.put('Email', email);
			}
			
			// List member ID mapped to the external ID field specified in configuration file
			String idFieldName = mappingsNode.getAttribute('idField', 'salesforce');
			if (hasValue(idFieldName)) {
				String idFieldValue = requestParams.get('data[id]');
				if (hasValue(idFieldValue)) {
					m_map.put(idFieldName, idFieldValue);
				}
			}
			
			// Lead source set to text specified in configuration file
			String leadSource = mappingsNode.getAttribute('leadSource', 'salesforce');
			if (hasValue(leadSource)) {
				m_map.put('LeadSource', leadSource);
			}
			
			// Lead status set to text specified in configuration file
			String leadStatus = mappingsNode.getAttribute('status', 'salesforce');
			if (hasValue(leadStatus)) {
				m_map.put('Status', leadStatus);
			}
			
			for (Dom.Xmlnode myNode : mappingsNode.getChildElements()) {
				
				if ('mapping'.equalsIgnoreCase(myNode.getName())) {
					
					// Process XML node attributes
					String mergeTag = myNode.getAttribute('mergeTag', 'mailchimp');
					String fieldName = myNode.getAttribute('field', 'salesforce');
					
					// Does this node map an address-type merge tag to the lead address?
					String attr = myNode.getAttribute('isLeadAddress', 'salesforce');
					Boolean isLeadAddress = hasValue(attr) && attr.equalsIgnoreCase('true');				
					
					// "Source" is merge tag or 'system' variable
					if (hasValue(mergeTag)) {
						
						// Merge tag -> single Lead field
						if (hasValue(fieldName)) {
													
							// Get field value as string, from the WebHook data
							String valueStr = requestParams.get('data[merges][' + mergeTag + ']');
								
							// Use field value if it exists in the WebHook data
							if (hasValue(valueStr)) {
							
								// Convert the value to another type if Lead field won't take a String
								if (fieldName.equalsIgnoreCase('NumberOfEmployees')) {
									try {
										m_map.put(fieldName, Integer.valueOf(valueStr));
									}
									catch (Exception ex) {
										// Invalid type conversion
										System.debug(toDebugString('ERROR: ' + ex));
									}
								}
								else if (fieldName.equalsIgnoreCase('AnnualRevenue')) {
									try {
										m_map.put(fieldName, Double.valueOf(valueStr));
									}
									catch (Exception ex) {
										// Invalid type conversion
										System.debug(toDebugString('ERROR: ' + ex));
									}
								}
								else if (fieldName.endsWith('__c')) {
									// TODO Handle custom fields with types other than text/String - 
									// TODO describe field type and convert string value, if necessary
									m_map.put(fieldName, valueStr);
								}
								else {
									m_map.put(fieldName, valueStr);
								}
							}
						}
						
						// Address-type merge tag to multiple, related Lead fields
						else if (isLeadAddress) {
							
							// "addr1" and "addr2" are combined in Lead.Street
							String addr1 = requestParams.get('data[merges][' + mergeTag + '][addr1]');
							String addr2 = requestParams.get('data[merges][' + mergeTag + '][addr2]');
							String street = '{0}{1}{2}'
								.replace('{0}', hasValue(addr1) ? addr1 : '')
								.replace('{1}', hasValue(addr1) && hasValue(addr2) ? '\n' : '')
								.replace('{2}', hasValue(addr2) ? addr2 : '');							
							if (hasValue(street) ) {
								m_map.put('Street', street);
							}
							
							// "city"
							String city = requestParams.get('data[merges][' + mergeTag + '][city]');
							if (hasValue(city)) {
								m_map.put('City', city);
							}
							
							// "state"
							String state = requestParams.get('data[merges][' + mergeTag + '][state]');
							if (hasValue(state)) {
								m_map.put('State', state);
							}
							
							// "zip"
							String zip = requestParams.get('data[merges][' + mergeTag + '][zip]');
							if (hasValue(zip)) {
								m_map.put('PostalCode', zip);
							}
							
							// "country"
							String country = requestParams.get('data[merges][' + mergeTag + '][country]');
							if (hasValue(country)) {
								m_map.put('Country', country);
							}
						}
						
						// Shouldn't get here
						else {
							System.debug(toDebugString('Invalid mapping node: ' + myNode));						
						}	
					}
					
					// Shouldn't get here
					else {
						System.debug(toDebugString('Invalid mapping node: ' + myNode));				
					}
				}
			}
		}
		
		return m_map;
	}
	
	/**
	* Utility method
	*/
	public Boolean hasValue(String s) {
		return s != null && s.trim().length() > 0;
	}

	/**
	* Utility method
	*/
	public String toDebugString(String s) {
		return ('\n\n*** ' + s + '\n');
	}
	
	/**
	* Utility method
	*/
	public Boolean isTrue(String s) {
		return (hasValue(s) && ('true'.equalsIgnoreCase(s)));
	}
	
	
	
	/**
	---------------------------------------------------------
	TEST METHODS
	---------------------------------------------------------
	*/
	
	public static testMethod void test_StringUtils() {
		
		SubscribeLeadController c = new SubscribeLeadController();
		
		String s = '';
		System.assert(!c.hasValue(s));
		
		s = null;
		System.assert(!c.hasValue(s));
				
		s = '    ';
		System.assert(!c.hasValue(s));
		
		s = 'Hello World!';
		System.assert(c.hasValue(s));
		
		String msg = c.toDebugString('Hello');
		System.assert(msg.startsWith('\n\n***'));
		System.assert(msg.endsWith('Hello\n'));
		
		System.assert(c.isTrue('TRUE'));
		System.assert(c.isTrue('TrUe'));
		System.assert(!c.isTrue('t'));
	}
	
	public static testMethod void test_getConfig() {
		
		SubscribeLeadController controller = new SubscribeLeadController();
		
		// Assert presence of config file
		Dom.Document doc = controller.getConfig();
		System.assert(doc != null);
	}
	
	public static testMethod void test_isValidRequestCode() {
		
		// Instantiate controller
		SubscribeLeadController controller = new SubscribeLeadController();

	 	// Set up page context and parameters
        PageReference pageRef = Page.SubscribeLead;
        Test.setCurrentPage(pageRef);   
        
        // Test valid code
       	String configCode = controller.getConfig().getRootElement().getAttribute('code', null);
       	ApexPages.currentPage().getParameters().put('code', configCode);
       	System.assert(controller.isValidRequestCode());
       	
       	// Test invalid code
       	ApexPages.currentPage().getParameters().put('code', configCode + '_hello_world_');
		System.assert(!controller.isValidRequestCode());
        
	}
	
	public static testMethod void test_allowFieldTruncation() {
		
		SubscribeLeadController controller = new SubscribeLeadController();
		
		String xml1 =  '<config id="subscribeLead" xmlns:mc="mailchimp" xmlns:sf="salesforce" code="_I_Love_MailChimp_">';
		String xml2 =  '<options sf:useDefaultAssignmentRule="false" sf:allowFieldTruncation="true" />';
		String xml2a = '<options sf:useDefaultAssignmentRule="false" sf:allowFieldTruncation="f" />';
		String xml3 =  '</config>';
		
		// Attribute is true
		Dom.Document config1 = new Dom.Document();
		config1.load(xml1 + xml2 + xml3);
		controller.setConfig(config1);
		System.assert(controller.allowFieldTruncation());
		
		// No options element
		Dom.Document config2 = new Dom.Document();
		config2.load(xml1 + xml3);
		controller.setConfig(config2);
		System.assert(!controller.allowFieldTruncation());
		
		// Attribute is not true
		Dom.Document config3 = new Dom.Document();
		config3.load(xml1 + xml2a + xml3);
		controller.setConfig(config3);
		System.assert(!controller.allowFieldTruncation());
	}
	
	public static testMethod void test_useDefaultAssignmentRule() {
		
		SubscribeLeadController controller = new SubscribeLeadController();
		
		String xml1 =  '<config id="subscribeLead" xmlns:mc="mailchimp" xmlns:sf="salesforce" code="_I_Love_MailChimp_">';
		String xml2 =  '<options sf:useDefaultAssignmentRule="true"  />';
		String xml2a = '<options sf:useDefaultAssignmentRule="false" />';
		String xml3 =  '</config>';
		
		// Attribute is true
		Dom.Document config1 = new Dom.Document();
		config1.load(xml1 + xml2 + xml3);
		controller.setConfig(config1);
		System.assert(controller.useDefaultAssignmentRule());
		
		// No options element
		Dom.Document config2 = new Dom.Document();
		config2.load(xml1 + xml3);
		controller.setConfig(config2);
		System.assert(!controller.useDefaultAssignmentRule());
		
		// Attribute is false
		Dom.Document config3 = new Dom.Document();
		config3.load(xml1 + xml2a + xml3);
		controller.setConfig(config3);
		System.assert(!controller.useDefaultAssignmentRule());
	}
	
	public static testMethod void test_getMap_populateLead() {

		Test.startTest();

		SubscribeLeadController controller = new SubscribeLeadController();

		// Build configuration for testing
		String xml =  	
			'<config id="subscribeLead" xmlns:mc="mailchimp" xmlns:sf="salesforce" code="_I_Love_MailChimp_">' +
			'	<mappings sf:idField="MailChimp_ID" sf:leadSource="My Lead Source">' +
			'		<mapping mc:mergeTag="EMPCOUNT"  sf:field="NumberOfEmployees" />' +
			'		<mapping mc:mergeTag="REVENUE"  sf:field="AnnualRevenue" />' +
			'		<mapping mc:mergeTag="FNAME"   sf:field="FirstName" />' +
			'		<mapping mc:mergeTag="LNAME"   sf:field="LastName" />' +
			'		<mapping mc:mergeTag="FAV_FISH" sf:field="FavoriteFish__c" />' +
			'		<mapping mc:mergeTag="ADDR" sf:isLeadAddress="true" />' +
			'	</mappings>' +
			'<options sf:useDefaultAssignmentRule="false" sf:allowFieldTruncation="true" />' +
			'</config>';
		Dom.Document config = new Dom.Document();
		config.load(xml);
		controller.setConfig(config);
		
		// Create request params
		PageReference pageRef = Page.SubscribeLead;
        Test.setCurrentPage(pageRef); 
        Map<String,String> params = ApexPages.currentPage().getParameters();
        params.put('code', '_I_Love_MailChimp_');
        params.put('data[id]', 'abc1234567');
        params.put('data[email]', 'smith@corp.com');
        params.put('data[merges][LNAME]', 'Smith');
        params.put('data[merges][EMPCOUNT]', '123');
        params.put('data[merges][REVENUE]', '456.78');
        params.put('data[merges][FAV_FISH]', 'Trout');
		
		// Make sure they're mapped properly
		Map<String,Object> myMap = controller.getMap();
		System.assert(myMap != null, 'Map cannot be null');
		System.assert(myMap.get('MailChimp_ID') == 'abc1234567');
		System.assert(myMap.get('LastName') == 'Smith');
		System.assert(myMap.get('NumberOfEmployees') == 123);
		System.assert(myMap.get('AnnualRevenue') == 456.78);
		System.assert(myMap.get('FavoriteFish__c') == 'Trout');
		System.assert(myMap.get('Email') == 'smith@corp.com');
		System.assert(!myMap.containsKey('FirstName'));
		System.assert(!myMap.containsKey('Street'));
		System.assert(!myMap.containsKey('City'));
		
		// Create and test lead
		Lead L = controller.populateLead(new Lead());
		Database.Saveresult dsr = Database.insert(L);
		System.assert(dsr != null && dsr.isSuccess());
		System.assert(L.LastName == 'Smith');
		System.assert(L.AnnualRevenue == 456.78);
		
		// Change request params to include 'bad' numeric data,
		// no last name, and new address fields
		controller = new SubscribeLeadController();
		controller.setConfig(config);
        params.put('data[merges][EMPCOUNT]', '_123_');
        params.put('data[merges][REVENUE]', '_456.78_');
        params.remove('data[merges][LNAME]');
        params.put('data[merges][ADDR][addr1]', '100 E. Main St.');
        params.put('data[merges][ADDR][addr2]', 'Suite 1');
        params.put('data[merges][ADDR][city]', 'Chicago');
        params.put('data[merges][ADDR][state]', 'IL');
        params.put('data[merges][ADDR][zip]', '60601');
        params.put('data[merges][ADDR][country]', 'USA');        
        myMap = controller.getMap();
        System.assert(!myMap.containsKey('NumberOfEmployees'));
        System.assert(!myMap.containsKey('AnnualRevenue'));
        System.assert(!myMap.containsKey('LastName'));
        System.assert(myMap.get('Street') == '100 E. Main St.\nSuite 1');
        System.assert(myMap.get('City') == 'Chicago');
        System.assert(myMap.get('City') == 'Chicago');
        System.assert(myMap.get('State') == 'IL');
        System.assert(myMap.get('PostalCode') == '60601');
        System.assert(myMap.get('Country') == 'USA');
        
        L = controller.populateLead(new Lead());
        System.assert(NOT_PROVIDED.equals(L.LastName));
        
        Test.stopTest();
	}
	
	public static testMethod void test_handleSubscribeLead() {
				
		SubscribeLeadController controller = new SubscribeLeadController();		
		
		System.debug(controller.toDebugString('Staring test_handleSubscribeLead'));
		
		Test.startTest();

		// Build configuration for testing
		String xml =  	
			'<config id="subscribeLead" xmlns:mc="mailchimp" xmlns:sf="salesforce" code="_I_Love_MailChimp_">' +
			'	<mappings sf:idField="MailChimp_ID" sf:leadSource="My Lead Source" sf:status="Subscribed to MailChimp list">' +
			'		<mapping mc:mergeTag="EMPCOUNT"  sf:field="NumberOfEmployees" />' +
			'		<mapping mc:mergeTag="REVENUE"  sf:field="AnnualRevenue" />' +
			'		<mapping mc:mergeTag="FNAME"   sf:field="FirstName" />' +
			'		<mapping mc:mergeTag="LNAME"   sf:field="LastName" />' +
			'		<mapping mc:mergeTag="FAV_FISH" sf:field="FavoriteFish__c" />' +
			'		<mapping mc:mergeTag="ADDR" sf:isLeadAddress="true" />' +
			'	</mappings>' +
			'<options sf:useDefaultAssignmentRule="false" sf:allowFieldTruncation="true" />' +
			'</config>';
		Dom.Document config = new Dom.Document();
		config.load(xml);
		controller.setConfig(config);
		
		// Create request params
		PageReference pageRef = Page.SubscribeLead;
        Test.setCurrentPage(pageRef); 
        Map<String,String> params = ApexPages.currentPage().getParameters();
        params.put('code', '_I_Love_MailChimp_');
        params.put('data[id]', 'abc1234567');
        params.put('data[email]', 'smith@corp.com');
        params.put('data[merges][FNAME]', 'John');
        params.put('data[merges][LNAME]', 'Smith');
        params.put('data[merges][EMPCOUNT]', '123');
        params.put('data[merges][REVENUE]', '456.78');
        params.put('data[merges][FAV_FISH]', 'Trout');
		
		// Verify that we've inserted a lead
		controller.handleSubscribeLead();
		Lead myLead = [ SELECT Id, FirstName, LastName, NumberOfEmployees, LeadSource, Status FROM Lead WHERE Email = 'smith@corp.com' ];
		System.assert('John'.equals(myLead.FirstName));
		System.assert(myLead.NumberOfEmployees == 123);
		System.assert('My Lead Source'.equals(myLead.LeadSource));
		System.assert('Subscribed to MailChimp list'.equals(myLead.Status));
		
		// Try without email in posted data
		controller = new SubscribeLeadController();
		controller.setConfig(config);
		params.remove('data[email]');
		controller.handleSubscribeLead();
		
		// Try with duplicate lead
		controller = new SubscribeLeadController();
		controller.setConfig(config);
        params.put('data[email]', 'smith@corp.com');
		controller.handleSubscribeLead();

		// Try with bad "secret" code
		controller = new SubscribeLeadController();
		controller.setConfig(config);
        params.put('data[email]', 'smith@corp.com');
		params.remove('code');
		controller.handleSubscribeLead();
		
		Test.stopTest();
	}
}