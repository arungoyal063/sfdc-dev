/*********************************************************************************************************************
* Module Name   :  SampleOrderClass
* Description   :  SampleOrderClass
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    : <Test_AccountExtension>
* 
* Organization  : Rainmaker Associates LLC
*
* Revision History:-
* Version  Date            Author        WO#         Description of Action
* 1.0      4/2/2013       Algoworks     1255     Initial Version
*******************************************************************************************************************/
global with sharing class SampleOrderClass
{    
    List<Sample_Product__c> sampleProducts;
    public Sample_Order__c so{get;set;}
    public string productSelected{get;set;}
    public string productQuantity{get;set;}

    public string ShippingStreet{get;set;}
    public string ShippingCity{get;set;}
    public string ShippingCountry{get;set;}
    public string ShippingState{get;set;}
    public string ShippingPostalCode{get;set;}  
    public string ShippingPhone{get;set;}
    public string ShippingPhoneExt{get;set;}
    public string ShippingEmail{get;set;}
    public string SalesOfficeId{get;set;}
    public string SalesGroupId{get;set;}  
    
    public SampleOrderClass(ApexPages.StandardController controller) 
    {
        //so = new Sample_Order__c();
        so = (Sample_Order__c)controller.getRecord();
       // sampleProducts = [Select Active__c, Product_Category__c,style_desc__c,color_desc__c,size__c from Sample_Product__c WHERE Active__c = true];       

        if(so.Opportunity__c != null )
        {
            Opportunity opp =  [Select AccountId from Opportunity where Id =: so.Opportunity__c];
            so.Account__c = opp.AccountId;
        }
        
        if(so.Contact__c != null)
        {
            string conId = so.Contact__c;
            Contact con = [Select MailingStreet,Name, MailingCity,MailingState,MailingPostalCode,MailingCountry, Phone, Phone_Ext__c, Email,OwnerId  from Contact where id =: conId];
            try
            {
                String userId = con.OwnerId;
                User activeUser = [Select Email, Phone, Extension,Sales_Office_Id__c,Sales_Group_Id__c From User where Id = : userId limit 1];
                ShippingStreet = con.MailingStreet;
                ShippingCity = con.MailingCity;
                ShippingState = con.MailingState;
                ShippingPostalCode = con.MailingPostalCode;
                ShippingCountry = con.MailingCountry;
                SalesOfficeId = activeUser.Sales_Office_Id__c;
                SalesGroupId = activeUser.Sales_Group_Id__c;
                ShippingPhone =  con.Phone;
                ShippingPhoneExt = '';
                ShippingEmail = activeUser.Email;
            } 
            catch(Exception e)
            {
                System.Debug('Error loading Contact address!');
            }
        }
        String cId = so.Contact__c;//Apexpages.currentPage().getParameters().get('CF00N30000007vdbQ_lkid');
        if(cId != null && cId != '') {
            List<Contact> conList = [Select Id, AccountId From Contact Where Id =: cId];
            if(conList != null && conList.size() > 0) {
                so.Account__c = conList[0].AccountId; 
            }
        } 
    }
    
    
    webService static List<sObject> getProdCategories() {
        
        List<sObject> b = [Select Product_Category__c, COUNT(size__c) from Sample_Product__c WHERE Active__c = true GROUP BY Product_Category__c ORDER BY Product_Category__c];
        return b;
    } 
    
    /*webService static List<sObject> getProducts(String cat) {
        
        List<sObject> b = [Select Product__c, COUNT(size__c) from Sample_Product__c WHERE (Product_Category__c = :cat AND Active__c = true) GROUP BY Product__c ORDER BY Product__c ];
        return b;
    } */
    
    webService static List<sObject> getStyles(String cat ) {
        
        List<sObject> b = [Select style_desc__c, COUNT(size__c) from Sample_Product__c WHERE Active__c = true AND (Product_Category__c = :cat ) GROUP BY style_desc__c  ORDER BY style_desc__c];
        return b;
    } 
    
    webService static List<sObject> getColors(String cat, String style ) {
        
        List<sObject> b = [Select color_desc__c, COUNT(size__c) from Sample_Product__c WHERE Active__c = true AND (Product_Category__c = :cat AND style_desc__c =: style) GROUP BY color_desc__c  ORDER BY color_desc__c];
        return b;
    }     
    
    webService static List<sObject> getSizes(String cat, String style, String color ) {
        
        List<sObject> b = [Select Id, Name, SKU__c, size__c, Backorder__c, Expected_Ship_Date__c from Sample_Product__c WHERE Active__c = true AND (Product_Category__c = :cat AND style_desc__c =: style AND color_desc__c =:color) ORDER BY size__c];
        System.debug('---cat---'+cat+'----style----'+style+'----color----'+color+'>>>>>>'+b);
        return b;
    } 
    
    //JGP WO1255 web service addition to return Product information to the VF page for auto populating Search result
    //drop downs
    webService static List<sObject> getSelectedProduct(String id)
    {
        List<sObject> retval = [SELECT Product_Category__c, style_desc__c, color_desc__c, size__c FROM Sample_Product__c WHERE Active__c = true AND Id=:id];
        return retval;
    }
    
    
    public void ReloadContactAddress()
    {
        System.debug('Entering here to get the address');
        string conId = so.Contact__c;
        system.debug('>>>>>>>>>>>>>>>>>'+conId);        
        try{        
            Contact con = [Select MailingStreet,Name, MailingCity,MailingState,MailingPostalCode,MailingCountry, Phone, Phone_Ext__c, Email,OwnerId from Contact where id =: conId];
           
            String userId = con.OwnerId;
            User activeUser = [Select Email, Phone, Extension,Sales_Office_Id__c,Sales_Group_Id__c From User where Id = : userId limit 1];
            ShippingEmail = activeUser.Email;
            ShippingStreet = con.MailingStreet;
            ShippingCity = con.MailingCity;
            ShippingState = con.MailingState;
            ShippingPostalCode = con.MailingPostalCode;
            ShippingCountry = con.MailingCountry;
            SalesOfficeId = activeUser.Sales_Office_Id__c;
            SalesGroupId = activeUser.Sales_Group_Id__c;
            ShippingPhone = con.Phone;
            ShippingPhoneExt = ''; 
        }   
        catch(Exception e)
        {
            System.debug('Error fetching the Contact Address/Contact Owner Information' + e.getMessage());
        }  
               
    }
    
    public PageReference submitOrder() // send quantity
    {
        System.debug('Submitting order');
        Boolean validationFailed = false;
        if(productSelected == '' || productSelected == null) 
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one product to create order!');
            ApexPages.addMessage(myMsg);
            validationFailed = true;
            //return null;        
        }    
           
        string conId = so.Contact__c;        
        Contact con = [Select MailingStreet,Name, MailingCity,MailingState,MailingPostalCode,MailingCountry, Phone, Phone_Ext__c, Email from Contact where id =: conId];
        try
        {
            so.Shipping_Street__c = ShippingStreet;
            so.Shipping_Country__c = ShippingCountry;
            so.Shipping_City__c = ShippingCity;
            so.Shipping_Postal_Code__c = ShippingPostalCode ;
            so.Shipping_State__c = ShippingState;
            so.Shipping_Name__c = con.Name;
            so.Sales_Office_Id__c = SalesOfficeId;
            so.Sales_Group_Id__c = SalesGroupId;
            //so.Shipping_Last_Name__c = con.LastName; jS
          
            so.Shipping_Phone__c = ShippingPhone;
            so.Shipping_Phone_Ext__c = ShippingPhoneExt;
            so.Shipping_Email__c = ShippingEmail;
            
            if(so.Account__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account cannot be null'));
                validationFailed = true;
            }
            if(so.Shipping_Street__c == null || so.Shipping_Street__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Street cannot be null'));
                validationFailed = true;
            }
            if(so.Shipping_Country__c == null || so.Shipping_Country__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Country cannot be null'));
                validationFailed = true;
            }
            if(so.Shipping_City__c == null || so.Shipping_City__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'City cannot be null'));
                validationFailed = true;
            }
            if(so.Shipping_State__c == null || so.Shipping_State__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'State cannot be null'));
                validationFailed = true;
            }
            if(so.Shipping_Postal_Code__c == null || so.Shipping_Postal_Code__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Postal Code cannot be null'));
                validationFailed = true;
            }
            
            if(validationFailed) return null;

          upsert so;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        
        //create products - 
        List<SampleOrderProduct__c> spList = new List<SampleOrderProduct__c>();
        //create products - 
        List<string> arrProduct = new List<string>();
        List<string> arrQty = new List<string>();
        List<string> skuNmbrs = new List<string>();

        System.debug('product  Selected 123 ' + productSelected);
        arrProduct = productSelected.split('~');
        arrQty = productQuantity.split('~');
        
        Integer i = 0;
        for(string s: arrProduct)
        {
            SampleOrderProduct__c sp = new SampleOrderProduct__c();
            sp.Sample_Order__c = so.Id;
            sp.Sample_Product__c = s;
            sp.Quantity__c = Double.valueOf(arrQty[i]);
            System.debug('Quantity ' + (sp.Quantity__c < 4));
            spList.add(sp);
            i++;
        }
        try
        { upsert spList;}
        catch(Exception e)
        {
            if (so != null && so.Id != null) {
                delete so;
            }
            String errorMsg;
            //SM Changes 03/26/2013 change to eliminate Quantity > 4
            //if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            //    errorMsg = 'Quantity may not be greater than 4.';
            //} else {
                errorMsg = e.getMessage();
           // }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return null;
        }
        PageReference pg =  new PageReference('/' + so.Id); 
        return pg;
    } 
    static testMethod void MyTest()
    {
        RecordType rt = [SELECT IsActive, Name, Id FROM RecordType WHERE SobjectType = 'Account' AND IsActive = True LIMIT 1];
        
        Sample_Product__c sp = new Sample_Product__c(SKU__c = '1122', Active__c = True, Backorder__c = False, Product_Category__c = 'prodcat', size__c = '10', style_desc__c = 'aa', color_desc__c = 'bb');
        insert sp;

        Account acc = new Account(Name='aa', RecordTypeId = rt.Id);
        insert acc;
        
        Contact ctc = new Contact(FirstName='aa', LastName='bb');
        insert ctc;
        
        Opportunity opp = new Opportunity(Name='testopp', Accountid = acc.Id, StageName = 'Closed Won', CloseDate = System.Today());
        insert opp;

        Sample_Order__c newSO = new Sample_Order__c(Opportunity__c = opp.id, Account__c = acc.id, Contact__c = ctc.id);
        insert newSO;
        PageReference pageRef = Page.SampleOrdersPage;
        pageRef.getParameters().put('Id',newSO.id);
        Test.setCurrentPageReference(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(newSO);
        // create an instance of the controller
        SampleOrderClass myPageCon = new SampleOrderClass(sc);
        
        List<AggregateResult> cat = SampleOrderClass.getProdCategories();
        List<AggregateResult> style = SampleOrderClass.getStyles((String)cat[0].get('Product_Category__c') );
        List<AggregateResult> color = SampleOrderClass.getColors((String)cat[0].get('Product_Category__c'), (String)style[0].get('style_desc__c'));
        List<Sample_Product__c> sizes = SampleOrderClass.getSizes((String)cat[0].get('Product_Category__c'), (String)style[0].get('style_desc__c'), (String)color[0].get('color_desc__c'));
        
        myPageCon.ReloadContactAddress();

            myPageCon.productSelected = sp.id;
            myPageCon.productQuantity = '1';
            myPageCon.submitOrder();    

    }

    
}