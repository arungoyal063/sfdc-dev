// ==================================================================================
//   Object: DodgeConvertController 
//  Company: ManningTon
//   Author: Mohan (Sales Optimizer)
// Comments: Get all the Dodge contacts and convert them to Accounts/Contacts
// ==================================================================================
//  Changes: 2011-12-19 Initial version.
// ==================================================================================
//  Changes: 2012-03-01 First Update.
// Comments: 1. For Matching Contacts search based on Contact Name only.
//			 2. Populating the Dodge Contacts Address & Phone info on Account record during convert.
// ==================================================================================
//  Changes: 2012-05-23 Second Update.
// Comments: 1. Parsing the apostrophe symbole in firm name & contact name values
// ==================================================================================

public with sharing class DodgeConvertController {
	public List<DodgeContact> dodgeContactList {get;set;}
	public String primaryRowIndex {get;set;}
	
	private String dodgeId = '';
	private Map<Id,Dodge_Contact__c> dodgeContactMap = new Map<Id,Dodge_Contact__c>();
	
	public DodgeConvertController(ApexPages.StandardController sc) {
		dodgeContactList = new List<DodgeContact>();
		primaryRowIndex = '';
		dodgeId = Apexpages.currentPage().getParameters().get('id');
		String contractorRole = '%Contractor%';
		String owner = '%Owner%';
		String architect = '%Architect%';
		//Get Dodge Contacts who's Role are Architect or Owner or contains Contractor keyword
		List<Dodge_Contact__c> dContList = [Select d.Zip_Code__c, d.Zip_Code5__c, d.Url__c, d.SystemModstamp, d.State__c, d.Site_Processing_Indicator__c, 
											d.Site_ID__c, d.Role__c, d.Report_ID__c, d.Phone__c, d.Phone_Extension__c, d.Parent_Contact_System_ID__c, 
											d.Notes__c, d.Name, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Id, d.Firm_Name__c, d.Fax__c, 
											d.Factor_Contact_Code__c, d.Factor_Code__c, d.Email__c, d.Dodge_Project__c, d.CreatedDate, d.CreatedById, 
											d.Country__c, d.Contact_Unique_ID__c, d.Contact_Title__c, d.Contact_System_ID__c, d.isConverted__c, 
											d.Contact_Processing_Indicator__c, d.Contact_Name__c, d.Contact_ID__c, d.Company_Site_Url__c, d.City__c, 
											d.Category__c, d.Address_Line_3__c, d.Address_Line_2__c, d.Address_Line_1__c, d.isPrimary__c 
											From Dodge_Contact__c d Where d.Dodge_Project__c =: dodgeId and (d.Role__c like :architect or 
											d.Role__c like :owner or d.Role__c like :contractorRole) order by d.Role__c limit 20];
		dodgeContactMap = new Map<Id,Dodge_Contact__c>(dContList);
		String dodgeFirmNames = '';
		List<String> firmNames = new List<String>();
		//collects all the Firm Names from the Dodge Contact's list
		for(Dodge_Contact__c dc : dContList) {
			if(dc.Firm_Name__c != null && dc.Firm_Name__c != '') {
				if(dodgeFirmNames == '') {
					dodgeFirmNames = ' Name Like \'%' + formatValues(dc.Firm_Name__c) + '%\'';
					firmNames.add(dc.Firm_Name__c);
				}
				else {
					if(!dodgeFirmNames.contains('%' + formatValues(dc.Firm_Name__c) + '%')) {
						dodgeFirmNames += ' OR Name Like \'%' + formatValues(dc.Firm_Name__c) + '%\'';
						firmNames.add(dc.Firm_Name__c);
					}
				}
			}
		}
		List<Account> accountList = new List<Account>();
		Map<String, List<Account>> accountMap = new Map<String, List<Account>>();
		if(dodgeFirmNames != null && dodgeFirmNames != '') {
			System.debug('accoun query: '+'Select Id, Name From Account Where (' + dodgeFirmNames + ')');
			//fetch all the accounts matching with Firm Names from Dodge Contact's list
			accountList = Database.query('Select Id, Name From Account Where (' + dodgeFirmNames + ')');
		}
		//build a map with Firm Name as key and all the matching Accounts as its value
		for(String s : firmNames) {
			for(Account a : accountList) {
				if(a.Name.contains(s)) {
					if(accountMap.containsKey(s)) {
						List<Account> alist = accountMap.get(s);
						alist.add(a);
						accountMap.put(s, alist);
					} else {
						List<Account> alist = new List<Account>();
						alist.add(a);
						accountMap.put(s, alist);
					}
				}
			}
		}
		System.debug('accountMap: '+accountMap);
		for(Dodge_Contact__c dc : dContList) {
			DodgeContact dCont = new DodgeContact();
			dCont.dodgeContact = dc;
			if(dc.isConverted__c) dCont.isConverted = true;
			dCont.rowIndex = dodgeContactList.size();
			dCont.accountOptSelected = '';
			dCont.accountOptions.add(new Selectoption('', '--None--'));
			if(accountMap.containsKey(dc.Firm_Name__c)) {
				List<Account> accList = accountMap.get(dc.Firm_Name__c);
				for(Account acc : accList) {
					dCont.accountOptions.add(new Selectoption(acc.Id, 'Attach to Existing: ' + acc.Name));
				}
			}
			dCont.accountOptions.add(new Selectoption('Create New', 'Create New Account: ' + dc.Firm_Name__c));
			dodgeContactList.add(dCont);
		}
	}
	
	//checks wheather the Contact Name of Dodge Contact is existing within the selected Account else allows to create new Contact
	//Contacts are searched based on 3 fields - Name, Phone and Email
	public void fetchContacts() {
		String rowIndex = System.currentPageReference().getParameters().get('rIndex');
		if(rowIndex != null && rowIndex != '') {
			Integer rIndex = Integer.valueOf(rowIndex);
			String accSelected = dodgeContactList.get(rIndex).accountOptSelected;
			DodgeContact dCont = dodgeContactList.get(rIndex);
			dCont.contactOptions.clear();
			if(accSelected != null && accSelected != ''){
				Boolean newContact = true;
				if(accSelected != 'Create New') {
					String whereCondition = ' Where AccountId =\'' + accSelected + '\'';
					String temp = '';
					if(dCont.dodgeContact.Contact_Name__c != null && dCont.dodgeContact.Contact_Name__c != '') {
						temp = ' Name like \'%' + formatValues(dCont.dodgeContact.Contact_Name__c) + '%\'';
					}
					/*if(dCont.dodgeContact.Phone__c != null && dCont.dodgeContact.Phone__c != '') {
						String formatedPhone = formatPhone(dCont.dodgeContact.Phone__c);
						if(formatedPhone != '') {
							if(temp != '') temp += ' and (Phone = \'' + dCont.dodgeContact.Phone__c + '\' or Phone = \'' + formatedPhone + '\')';
							else temp = ' (Phone = \'' + dCont.dodgeContact.Phone__c + '\' or Phone = \'' + formatedPhone + '\')';
						} else {
							if(temp != '') temp += ' and Phone = \'' + dCont.dodgeContact.Phone__c + '\'';
							else temp = ' Phone = \'' + dCont.dodgeContact.Phone__c + '\'';
						}
					}
					if(dCont.dodgeContact.Email__c != null && dCont.dodgeContact.Email__c != '') {
						if(temp != '') temp += ' and Email = \'' + dCont.dodgeContact.Email__c + '\'';
						else temp = ' Email = \'' + dCont.dodgeContact.Email__c + '\'';
					}*/
					if(temp != '') {
						whereCondition += ' and ( ' + temp + ')';
					}
					System.debug('whereCondition: '+whereCondition);
					dCont.contactSelected = '';
					List<Contact> contList = Database.query('Select Id, Name From Contact ' + whereCondition);
					if(contList != null && contList.size() > 0) {
						newContact = false;
						for(Contact c : contList) {
							if(dCont.contactSelected == '') {
								dCont.contactSelected = c.Id;
							}
							dCont.contactOptions.add(new Selectoption(c.Id, 'Attach to Existing: ' + c.Name));
						}
						dCont.contactOptions.add(new Selectoption('Create New', 'Create New Contact'));
						dCont.contactOptions.add(new Selectoption('', 'Ignore Contact Creation'));
					}
				}
				if(newContact) {
					dCont.contactSelected = 'Create New';
					if(dCont.dodgeContact.Contact_Name__c != null && dCont.dodgeContact.Contact_Name__c != '') {
						dCont.contactOptions.add(new Selectoption('Create New', 'Create New Contact'));
					}
					dCont.contactOptions.add(new Selectoption('', 'Ignore Contact Creation'));
				}
			}
		}
	}
	
	//this method converts the Dodge Contact which is selected as primary into Account, Contact and Opportunity
	public Pagereference convert() {
		List<Dodge_Contact__c> updateDodgeContList = new List<Dodge_Contact__c>();
		String primaryRowIndex = Apexpages.currentPage().getParameters().get('primaryRowIndexValue');
		Integer pRowIndex;
		if(primaryRowIndex == null || primaryRowIndex == '' || primaryRowIndex == ' ') {
			addErrorMsg('Conversion process failed !! Primary contact is not selected');
            return null;
		}
		pRowIndex = Integer.valueOf(primaryRowIndex);
		DodgeContact dcPrimary = dodgeContactList.get(pRowIndex);
		if(dcPrimary.accountOptSelected == null || dcPrimary.accountOptSelected == '') {
			addErrorMsg('Matching Account(s) cannot be null for the primary selection. Please select the Matching Account(s)');
            return null;
		}
		String rTypeId = '';
		List<RecordType> rTypeList = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Account' and r.Name = 'Account'];
		if(rTypeList != null && rTypeList.size() > 0) rTypeId = rTypeList[0].Id;
		String accountId = '';
		String contactId = '';
		String primaryAccount = '';
		Map<String, String> newFirmNameIdMap = new Map<String, String>();
		Map<String, String> newContactNameIdMap = new Map<String, String>();
		Savepoint sp = Database.setSavepoint();
		for(DodgeContact dc : dodgeContactList) {
			System.debug('dc: ' + dc);
			if(dc.accountOptSelected != null && dc.accountOptSelected == 'Create New') {
				if(newFirmNameIdMap.get(dc.dodgeContact.Firm_Name__c) != null) {
					accountId = newFirmNameIdMap.get(dc.dodgeContact.Firm_Name__c);
				} else {
					Account acc = new Account();
					acc.Name = dc.dodgeContact.Firm_Name__c;
					acc.RecordTypeId = rTypeId;
					acc.Type = 'A&D Firm';
					acc.Phone = dc.dodgeContact.Phone__c;
					acc.BillingStreet = prepareAddress(dc);
					acc.BillingCity = dc.dodgeContact.City__c;
					acc.BillingState = dc.dodgeContact.State__c;
					acc.BillingCountry = dc.dodgeContact.Country__c;
					acc.BillingPostalCode = dc.dodgeContact.Zip_Code__c;
					try {
						insert acc;
						accountId = acc.Id;
						newFirmNameIdMap.put(dc.dodgeContact.Firm_Name__c, acc.Id);
					} catch(Exception ex){
						addErrorMsg(ex.getMessage());
						Database.rollback(sp);
						return null;
					}
				}
			} else {
				accountId = dc.accountOptSelected;
			}
			if(dc.contactSelected != null && dc.contactSelected == 'Create New') {
				if(dc.dodgeContact.Contact_Name__c != null && dc.dodgeContact.Contact_Name__c != '') {
					if(newContactNameIdMap.get(dc.dodgeContact.Firm_Name__c + '____' + dc.dodgeContact.Contact_Name__c) != null) {
						contactId = newContactNameIdMap.get(dc.dodgeContact.Firm_Name__c + '____' + dc.dodgeContact.Contact_Name__c);
					} else {
						Contact con = new Contact();
						con.LastName = dc.dodgeContact.Contact_Name__c;
						con.Title = dc.dodgeContact.Contact_Title__c;
						con.Phone = dc.dodgeContact.Phone__c;
						con.Email = dc.dodgeContact.Email__c;
						con.MailingStreet = prepareAddress(dc);
						con.MailingCity = dc.dodgeContact.City__c;
						con.MailingState = dc.dodgeContact.State__c;
						con.MailingCountry = dc.dodgeContact.Country__c;
						con.MailingPostalCode = dc.dodgeContact.Zip_Code__c;
						con.AccountId = accountId;
						try {
							insert con;
							contactId = con.Id;
							newContactNameIdMap.put(dc.dodgeContact.Firm_Name__c + '____' + dc.dodgeContact.Contact_Name__c, con.Id);
						} catch(Exception ex){
							addErrorMsg(ex.getMessage());
							Database.rollback(sp);
							return null;
						}
					}
				}
			} else {
				contactId = dc.contactSelected;
			}
			
			Dodge_Contact__c dodgeCont = dc.dodgeContact;
			dodgeCont.isConverted__c = true;
			//dodgeCont.isPrimary__c = true;
			if(pRowIndex == dc.rowIndex) {
				dodgeCont.isPrimary__c = true;
				primaryAccount = accountId;
			}
			updateDodgeContList.add(dodgeCont);
			//primaryAccount = accountId + '___' + contactId;
			//primaryAccount = accountId;
		}
		if(primaryAccount != '') {
			//List<String> pContlist = primaryAccount.split('___');
			List<Dodge_Project__c> dProjectList = [Select d.ZipCode__c, d.Type__c, d.Title__c, d.SystemModstamp, d.State__c, d.Square_Footage__c, 
													d.Square_Footage_Unit_of_Measure__c, d.Report_ID__c, d.Publisher_of_the_Dodge_Report__c, 
													d.Publish_Date__c, d.Project_Stage_Description__c, d.Prior_Publish_Date__c, d.OwnerId, 
													d.Number_of_buildings__c, d.Number_Of_Stories_Below_Ground__c, d.Number_Of_Stories_Above_Ground__c, 
													d.Notes__c, d.Name, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Id, d.Framing__c, 
													d.First_Publish_Date__c, d.Estimated_Valuation_Low__c, d.Estimated_Valuation_High__c, 
													d.Due_Date__c, d.Dodge_Report_Version_Number__c, d.Dodge_Report_Type__c, d.Dodge_Report_Number__c, 
													d.Dodge_Project_URL__c, d.Delivery_System__c, d.Currency_Type__c, d.Creator__c, d.CreatedDate, 
													d.CreatedById, d.Country__c, d.Copyright__c, d.City__c, d.Bid_Date__c, d.Address_Line_3__c, 
													d.Address_Line_2__c, d.Address_Line_1__c, d.RecordTypeId From Dodge_Project__c d Where d.Id =: dodgeId];
			if(dProjectList != null && dProjectList.size() > 0) {
				String dodgeRTypeId = '';
				List<RecordType> dodgeRTypeList = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Dodge_Project__c' and r.Name = 'Locked'];
				if(dodgeRTypeList != null && dodgeRTypeList.size() > 0) dodgeRTypeId = dodgeRTypeList[0].Id;
				Dodge_Project__c dProject = new Dodge_Project__c();
				dProject = dProjectList[0];
				Opportunity opty = new Opportunity();
				opty.Name = dProject.Title__c;
				opty.Description = dProject.Project_Stage_Description__c;
				opty.StageName = 'Prospective Project';
				opty.OwnerId = Userinfo.getUserId();
				if(dProject.Bid_Date__c != null) {
					opty.CloseDate = dProject.Bid_Date__c.addDays(60);
				} else {
					opty.CloseDate = Date.today().addDays(60);
				}
				//opty.AccountId = pContlist[0];
				opty.AccountId = primaryAccount;
				opty.Dodge_Project__c = dProject.Id;
				opty.Number_Of_Buildings__c = dProject.Number_of_buildings__c;
				opty.Number_Of_Stories_Above_Ground__c = dProject.Number_Of_Stories_Above_Ground__c;
				opty.Number_Of_Stories_Below_Ground__c = dProject.Number_Of_Stories_Below_Ground__c;
				opty.Square_Footage__c = dProject.Square_Footage__c;
				opty.Square_Footage_Unit_of_Measure__c = dProject.Square_Footage_Unit_of_Measure__c;
				opty.Currency_Type__c = dProject.Currency_Type__c;
				opty.Estimated_Valuation_High__c = dProject.Estimated_Valuation_High__c;
				opty.Estimated_Valuation_Low__c = dProject.Estimated_Valuation_Low__c;
				opty.Notes__c = dProject.Notes__c;
				opty.DL_Address_Line_1__c = dProject.Address_Line_1__c;
				opty.DL_Address_Line_2__c = dProject.Address_Line_2__c;
				opty.DL_Address_Line_3__c = dProject.Address_Line_3__c;
				opty.DL_City__c = dProject.City__c;
				opty.DL_Country__c = dProject.Country__c;
				opty.DL_State__c = dProject.State__c;
				opty.DL_ZipCode__c = dProject.ZipCode__c;
				//opty.Dodge_Lead_Last_Modified_Date__c = dProject.LastModifiedDate;
				try {
					insert opty;
					dProject.Status__c = 'Converted';
					dProject.RecordTypeId = dodgeRTypeId;
					update dProject;
				} catch(Exception ex) {
					addErrorMsg(ex.getMessage());
					Database.rollback(sp);
					return null;
				}
			}
		}
		if(updateDodgeContList.size() > 0) {
			try {
				update updateDodgeContList;
			} catch(Exception ex) {
				addErrorMsg(ex.getMessage());
				Database.rollback(sp);
				return null;
			}
		}
		return returnURL(primaryAccount);
	}
	
	public Pagereference cancel() {
		return returnURL(dodgeId);
	}
	
	private Pagereference returnURL(String recId) {
		String hostName = Apexpages.currentPage().getHeaders().get('Host');
        String returnUrl = 'https://' + hostName + '/' + recId;
        PageReference p = new PageReference(returnUrl);
        p.setRedirect(true);
        return p;
	}
	
	//show an error message on the page if any exists
	private void addErrorMsg(String errMsg) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
	}
	
	/*private String formatPhone(String value) {
    	if(value != null && value.length() == 10) {
    		value = '(' + value.substring(0,3) + ') ' + value.substring(3, 6) + '-' + value.substring(6);
    	} else {
    		value = '';
    	}
    	return value;
    }*/
    
    private String prepareAddress(DodgeContact dc) {
    	String address = '';
		if(dc.dodgeContact.Address_Line_1__c != null && dc.dodgeContact.Address_Line_1__c != '') {
			address = dc.dodgeContact.Address_Line_1__c;
		}
		if(dc.dodgeContact.Address_Line_2__c != null && dc.dodgeContact.Address_Line_2__c != '') {
			if(address != '') address += ', ' + dc.dodgeContact.Address_Line_2__c;
			else address = dc.dodgeContact.Address_Line_2__c;
		}
		if(dc.dodgeContact.Address_Line_3__c != null && dc.dodgeContact.Address_Line_3__c != '') {
			if(address != '') address += ', ' + dc.dodgeContact.Address_Line_3__c;
			else address = dc.dodgeContact.Address_Line_3__c;
		}
		return address;
    }
	
    //parsing the apostrophe symbole in firm name & contact name values
    private String formatValues(String val) {
    	if(val != null && val != '') {
        	if(val.contains('\'')) {
        		List<String> tempList = val.split('\'');
        		String temp = '';
        		for(Integer i=0; i<tempList.size(); i++) {
        			if(i == 0) {
        				temp = tempList[i];
        			} else {
        				temp += '\\\'' + tempList[i];
        			}
        		}
        		System.debug('temp: ' + temp);
        		val = temp;
        	}
    	}
    	return val;
    }
    
	public class DodgeContact {
		public Dodge_Contact__c dodgeContact {get;set;}
		public List<Selectoption> accountOptions {get;set;}
		public String accountOptSelected {get;set;}
		public List<Selectoption> contactOptions {get;set;}
		public String contactSelected {get;set;}
		public Boolean isConverted {get;set;}
		public Boolean isPrimary {get;set;}
		public Integer rowIndex {get;set;}
		
		public DodgeContact() {
			dodgeContact = new Dodge_Contact__c();
			accountOptions = new List<Selectoption>();
			contactOptions = new List<Selectoption>();
			isConverted = false;
			isPrimary = false;
		}
	}
}