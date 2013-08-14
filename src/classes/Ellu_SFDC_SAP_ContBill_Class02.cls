Public Class Ellu_SFDC_SAP_ContBill_Class02{
    
    Public Contract_Billing__c ObjContBilling ;
    Public  Contract_Billing__c VfObjContBilling ;
    Public Contract ObjContract;
    Public List<Contract_Billing__c> LstObjExistConBilling = new List<Contract_Billing__c>();
    
    Public  Contract_Billing__c getVfObjContBilling(){
        return VfObjContBilling;
    }
    Public  void setVfObjContBilling(Contract_Billing__c ConBill){
        system.debug('ConBill'+ConBill);
        this.VfObjContBilling=ConBill;
    }   
    public  Ellu_Software_Billing__c ObjCustSettSoftBill = new   Ellu_Software_Billing__c();                         
    
    Public   Integer VfVarNum {get; set;}
    Public Decimal VarNoPayments; 
    public    Boolean BoolVarContName {get; set;}
    public   Boolean BoolPaymentAm {get; set;}
    public   Boolean BoolPercentage {get; set;}
    public Id ConId;
    public String VarStrBillType;
    public Boolean BoolShowCrServBut {get; set;}
    public Boolean BoolShowCrServBut01 {get; set;}
    public Boolean VarSaCreateBillSer;
    public Boolean BoolVarReadOnly {get; set;}
    public Boolean BoolVarBillTypeReadOnly {get; set;}
    public decimal VarHnPercent;
    public class applicationException extends Exception {}
    public decimal VarHnAmount;
    public Boolean PayPAndPayAmoNull ;
    public Boolean ExectDateVald {get; set;}
    public Boolean VarBoolSoftware {get; set;}
    public Boolean VarBoolPayTimOnExec {get; set;}
    public String VarStrPayTiming {get; set;}
    Date ObjCurrentDate=Date.Today();
    Date ObjTemDate;
    Decimal PerFinalRec = 0;
    Decimal AmoFinalRec = 0;
    
    public Map<Integer , Contract_Billing__c> MapScreenConBilling=new Map<Integer , Contract_Billing__c>();
    
    public Ellu_SFDC_SAP_ContBill_Class02(ApexPages.StandardController controller) {
        
        ConId=ApexPages.currentPage().getParameters().get('ContractId__c');
        
        //VarStrBillType=ApexPages.currentPage().getParameters().get('Billing_Type__c');
        system.debug('TestEnh'+ ApexPages.currentPage().getParameters().get('Billing_Type__c'));
        
        system.debug('ConID'+ConId);
        ObjContBilling = new Contract_Billing__c();
        ExectDateVald=true;
        ObjContract=[SELECT Id , ContractExecutionDate__c ,StartDate FROM Contract WHERE Id=:ConId ];
        try{
            if(ObjContract.ContractExecutionDate__c == null){
                ExectDateVald=false;
                throw new applicationException('Without Execution Date on the Contract , Billing Records cannot be created'); 
            
            }
        }
        catch(exception e){
        
            ObjContBilling.adderror(e);    
        }
        
        VfObjContBilling = new Contract_Billing__c();
        VfObjContBilling.ContractId__c=ConId;
        VfObjContBilling.Billing_Type__c=ApexPages.currentPage().getParameters().get('Billing_Type__c');
        VfObjContBilling.Item_Type__c=ApexPages.currentPage().getParameters().get('Item_Type__c');
        if(VfObjContBilling.Item_Type__c=='TandM'){
        
            VfObjContBilling.Item_Type__c='T&M';       
        }
        //VfObjContBilling.Grouping_Type__c = ApexPages.currentPage().getParameters().get('Grouping_Type__c');
        VfObjContBilling.Total_Amount__c =  decimal.ValueOf(ApexPages.currentPage().getParameters().get('Total_Amount__c'));
        //VfObjContBilling.Payment_Timing__c = ApexPages.currentPage().getParameters().get('Payment_Timing__c');
        VfObjContBilling.Billing_Terms__c = ApexPages.currentPage().getParameters().get('Billing_Terms__c');
        VfObjContBilling.BillingDate__c=ObjContract.ContractExecutionDate__c;
        VfVarNum=1;
        VarSaCreateBillSer=false;
        //BoolPaymentAm=false;
        //BoolPercentage= false;
        BoolVarContName=true;
        VarNoPayments=0;
        BoolVarReadOnly=true;
        BoolVarBillTypeReadOnly=true;
        VarHnPercent=0;
        VarHnAmount=0;
        PayPAndPayAmoNull=false;
        VarBoolSoftware=false;
        VarBoolPayTimOnExec=true;
        //VfObjContBilling.Payment_Timing__c=VarStrPayTiming=VfObjContBilling.Payment_Timing__c;;
        
        if(VfObjContBilling.Billing_Type__c=='Software'){
            ObjCustSettSoftBill=[SELECT Name ,Payment_Percentage__c,Payment_Timing__c,Number_Of_Payment__c FROM Ellu_Software_Billing__c WHERE Name=:VfObjContBilling.Billing_Type__c Limit 1];
            VfObjContBilling.Payment_Timing__c=ObjCustSettSoftBill.Payment_Timing__c;
            VfObjContBilling.NumberofPayments__c=ObjCustSettSoftBill.Number_Of_Payment__c;
            //VfObjContBilling.PaymentPercentage__c=ObjCustSettSoftBill.Payment_Percentage__c;
            //BoolShowCrServBut01=true;
            VarBoolSoftware=true; 
            //BoolVarReadOnly=false;
            //VfObjContBilling. ='On Execution';
        
        }
        //VfVarNum++;
    }
    Public PageReference DependencyPick (){
        system.debug('DepenPick01');
        if(VfObjContBilling.Billing_Type__c=='Licen,AL & Maintenance'){
            VfObjContBilling.Item_Type__c='Licen , Al & Maintenance';
            system.debug('DepenPick02');
        }
        return null;
    }
    
    Public List<Contract_Billing__c> CheckForExistingBillRec (String TempObjBillType , String TempStrItemType , String TempStrBillingTerms){
        try{
        
            LstObjExistConBilling=[SELECT Id FROM Contract_Billing__c WHERE ContractId__c=:ConId AND Billing_Type__c=:TempObjBillType AND Item_Type__c=:TempStrItemType AND Billing_Terms__c=:TempStrBillingTerms];
        }
        catch(System.NullPointerException e){
        
        
        }
        system.debug('inside the Check method'+ LstObjExistConBilling);
        return LstObjExistConBilling;
    }
    
    
    Public void PayPerAndPayAmountNotEntered(decimal TempPercent, decimal TempAmount  ) {
    
        if(TempPercent==null && TempAmount==null){
        
            PayPAndPayAmoNull=true; 
        }
    
    }
    
    Public PageReference MethPayTiming (){
        //system.debug('DepenPick01');
        if(VfObjContBilling.Payment_Timing__c=='On Execution'){
            VarBoolPayTimOnExec=true;
            VfObjContBilling.BillingDate__c=ObjContract.StartDate;
        }
        else{
            VarBoolPayTimOnExec=false;        
        }
        if(VfObjContBilling.Payment_Timing__c=='As delivered'){
        
            VfObjContBilling.BillingDate__c=ObjContract.StartDate;
        }
        
        return null;
    }
    
    /*
    Public PageReference SaveAndCreateServiceBilling(){
    
    
    ObjContBilling = new Contract_Billing__c();
    
    try{
    if(VfVarNum == 1){
    VarHnPercent=0; 
    VarHnAmount=0;   
    }
    PayPerAndPayAmountNotEntered(VfObjContBilling.PaymentPercentage__c, VfObjContBilling.Payment_Amount__c  );
    if(PayPAndPayAmoNull==true){
    
    throw new applicationException('Payment percentage and Payment Amount cannot be blank at the same time. If finding difficult to enter value,Please try to change the '+'\'Percentage OR Amount\''+' picklist value to enable one of the fields');    
    }
    if( BoolPercentage== true){
    VarHnPercent=VarHnPercent+VfObjContBilling.PaymentPercentage__c;
    
    if(VarHnPercent>100){
    
    throw new applicationException('Payment Percentage for the Billing type exceeds 100% : Total input percentage '+' '+VarHnPercent+'%');   
    }
    if(VarHnPercent<100){
    
    throw new applicationException('Payment Percentage for the Billing type is below 100%  : Total input percentage'+' '+VarHnPercent+'%');   
    }
    }   
    
    
    if( BoolPaymentAm== true){
    VarHnAmount=VarHnAmount+VfObjContBilling.Payment_Amount__c;
    
    if(VarHnAmount>VfObjContBilling.Total_Amount__c){
    
    throw new applicationException('Payment Amount for the Billing type exceeds the Total Amount : Total input Payment Amount '+' '+VarHnAmount +'$');   
    }
    if(VarHnAmount<VfObjContBilling.Total_Amount__c){
    
    throw new applicationException('Payment Amount for the Billing type is below Total Amount  : Total input Payment Amount'+' '+VarHnAmount+'$');   
    }
    }   
    
    
    VarNoPayments=VfObjContBilling.NumberofPayments__c;
    //if(VfVarNum <=VarNoPayments){
    
    if( BoolPercentage== true){
    
    VfObjContBilling.Payment_Amount__c=VfObjContBilling.PaymentPercentage__c*VfObjContBilling.Total_Amount__c/100;
    }
    if(BoolPaymentAm==true){
    
    VfObjContBilling.PaymentPercentage__c=(VfObjContBilling.Payment_Amount__c*100/VfObjContBilling.Total_Amount__c);
    system.debug('Printin payemnt percentage cal from payment amount' +VfObjContBilling.PaymentPercentage__c);
    system.debug('Printin payemnt percentage cal from payment amount' +(VfObjContBilling.Payment_Amount__c*100/VfObjContBilling.Total_Amount__c));
    }
    system.debug('Printin payemnt percentage cal from payment amount' +VfObjContBilling.PaymentPercentage__c);
    system.debug('Printin payemnt percentage cal from payment amount' +(VfObjContBilling.Payment_Amount__c*100/VfObjContBilling.Total_Amount__c));
    
    ObjContBilling.ContractId__c=VfObjContBilling.ContractId__c;
    //ObjContBilling.CurrencyIsoCode=VfObjContBilling.CurrencyIsoCode;
    ObjContBilling.Comments__c=VfObjContBilling.Comments__c;
    ObjContBilling.NumberofPayments__c=VfObjContBilling.NumberofPayments__c;
    ObjContBilling.DaysfromEvent__c=VfObjContBilling.DaysfromEvent__c;
    ObjContBilling.Percentage_OR_Amount__c=VfObjContBilling.Percentage_OR_Amount__c;
    ObjContBilling.Billing_Terms__c=VfObjContBilling.Billing_Terms__c;
    ObjContBilling.Item_Type__c=VfObjContBilling.Item_Type__c;
    ObjContBilling.PaymentPercentage__c=VfObjContBilling.PaymentPercentage__c;
    ObjContBilling.BillingDate__c=VfObjContBilling.BillingDate__c;
    ObjContBilling.Payment_Amount__c=VfObjContBilling.Payment_Amount__c;
    ObjContBilling.Payment_Timing__c=VfObjContBilling.Payment_Timing__c;
    ObjContBilling.Total_Amount__c=VfObjContBilling.Total_Amount__c;
    ObjContBilling.Billing_Type__c=VfObjContBilling.Billing_Type__c;
    
    //insert ObjContBilling;
    
    MapScreenConBilling.put(VfVarNum,ObjContBilling);
    
    insert MapScreenConBilling.values();
    
    //VfObjContBilling.Billing_Type__c='Services';
    VfObjContBilling.Item_Type__c=null;
    BoolShowCrServBut=false;
    BoolShowCrServBut01=false;
    VfVarNum=1;
    VarSaCreateBillSer=true;
    BoolVarReadOnly=true;
    BoolVarBillTypeReadOnly=true;
    
    
    //PageReference ApexPage = new PageReference('/'+'apex/Ellu_SFDC_SAP_Int_ContBillEditPage');   
    // VfVarNum++;
    //}
    return null ; 
    }
    catch(exception e){
    
    ObjContBilling.adderror(e);
    try{
    if( BoolPercentage== true){    
    VarHnPercent=VarHnPercent-VfObjContBilling.PaymentPercentage__c;
    }
    if( BoolPaymentAm== true){
    VarHnAmount=VarHnAmount-VfObjContBilling.Payment_Amount__c;
    }
    }
    catch (exception e1){
    }
    PayPAndPayAmoNull=false;
    return null;       
    } 
    
    //return null ; 
    
    }
    */
    public void Validation () {
            if((String.valueOf(VfObjContBilling.PaymentPercentage__c)=='' ||VfObjContBilling.PaymentPercentage__c ==null) && (String.valueOf(VfObjContBilling.Payment_Amount__c)=='' ||VfObjContBilling.Payment_Amount__c ==null ) ){
        
                //PayPAndPayAmoNull=true;
                throw new applicationException('Please enter a value in Payment percentage or Payment Amount field. If finding difficult to enter value,Please try to change the '+'\'Percentage OR Amount\''+' picklist value to enable one of the field');
                 
            }
            if(VfObjContBilling.Payment_Timing__c==null || VfObjContBilling.Payment_Timing__c==''){
            
                throw new applicationException('Please select a Payment Timing');
            }
            if(VfObjContBilling.NumberofPayments__c==null ){
            
                throw new applicationException('Number Of Payments field cannot be blank. Please enter a valid number');
            }
            if(VfObjContBilling.BillingDate__c==null ){
            
                throw new applicationException('Number Of Payments field cannot be blank. Please enter a valid date');
            }
            if(VfObjContBilling.Payment_Timing__c<>'Monthly'&& VfObjContBilling.Payment_Timing__c<>'Quarterly' && VfObjContBilling.NumberofPayments__c<>1 ){
            
                throw new applicationException('Number of Payment should be equal to 1 for the selected Payment Timing.');
            }
            if(VfObjContBilling.Payment_Timing__c=='Quarterly' && VfObjContBilling.NumberofPayments__c<>4 ){
            
                throw new applicationException('Number of Payment should be equal to 4 for the selected Payment Timing.');
            }
}
    
    public PageReference Save (){
    
    
        ObjContBilling = new Contract_Billing__c();
        
        try{
    
            if(VfVarNum == 1){
                VarHnPercent=0; 
                VarHnAmount=0;
            }
            /*
            if((String.valueOf(VfObjContBilling.PaymentPercentage__c)=='' ||VfObjContBilling.PaymentPercentage__c ==null) && (String.valueOf(VfObjContBilling.Payment_Amount__c)=='' ||VfObjContBilling.Payment_Amount__c ==null ) ){
        
                //PayPAndPayAmoNull=true;
                throw new applicationException('Please enter a value in Payment percentage or Payment Amount field. If finding difficult to enter value,Please try to change the '+'\'Percentage OR Amount\''+' picklist value to enable one of the field');
                 
            }
            */
            if( BoolPercentage== true){
                system.debug('Test'+ VarHnPercent);
                //PerFinalRec=100-PerFinalRec;
                //AmoFinalRec=VfObjContBilling.Total_Amount__c-AmoFinalRec;
                VarHnPercent=VarHnPercent+VfObjContBilling.PaymentPercentage__c; 
            }
            if( BoolPaymentAm== true){
                //AmoFinalRec=VfObjContBilling.Total_Amount__c-AmoFinalRec;
                //PerFinalRec=100-PerFinalRec;
                VarHnAmount=VarHnAmount+VfObjContBilling.Payment_Amount__c;
            } 
        Validation ();  
        /*     
            if(VfObjContBilling.Payment_Timing__c==null || VfObjContBilling.Payment_Timing__c==''){
            
                throw new applicationException('Please select a Payment Timing');
            }
            if(VfObjContBilling.NumberofPayments__c==null){
            
                throw new applicationException('Number Of Payments field cannot be blank. Please enter a valid number');
            }
            if(VfObjContBilling.BillingDate__c==null ){
            
                throw new applicationException('Number Of Payments field cannot be blank. Please enter a valid date');
            } */
            if(VfObjContBilling.BillingDate__c<ObjContract.StartDate ){
            
                throw new applicationException('Payment Date needs to be greater than Contract Start date. Please enter a valid date');
            }
        /*  
            if(VfObjContBilling.Payment_Timing__c<>'Monthly'&& VfObjContBilling.Payment_Timing__c<>'Quarterly' && VfObjContBilling.NumberofPayments__c<>1 ){
            
                throw new applicationException('Number of Payment should be equal to 1 for the selected Payment Timing.');
            }
            if(VfObjContBilling.Payment_Timing__c=='Quarterly' && VfObjContBilling.NumberofPayments__c<>4 ){
            
                throw new applicationException('Number of Payment should be equal to 4 for the selected Payment Timing.');
            }
        */  
            if(VfVarNum == 1){
                //VarHnPercent=0; 
                //VarHnAmount=0;
                
                if(VfObjContBilling.Payment_Timing__c=='Monthly' && VfObjContBilling.BillingDate__c>(ObjCurrentDate.addMonths(1))){
                
                    throw new applicationException('For monthly payment timing the payment date is invalid.The difference between Payment date for this record and current date should not be greater than 1 month');
                }
                
                if(VfObjContBilling.Payment_Timing__c=='Quarterly' && VfObjContBilling.BillingDate__c>(ObjCurrentDate.addMonths(3))){
                
                    throw new applicationException('For Quarterly payment timing the payment date is invalid.The difference between Payment date for this record and current date should not be greater than 3 months');
                }
                if(VfObjContBilling.Payment_Timing__c=='Yearly' && VfObjContBilling.BillingDate__c>(ObjCurrentDate.addYears(1))){
                
                    throw new applicationException('For Yearly payment timing the payment date is invalid.The difference between Payment date for this record and current date should not be greater than 1 Year');
                }
                //VfObjContBilling.PaymentPercentage__c=0;   
            }
            else{
            
                if(VfObjContBilling.Payment_Timing__c=='Monthly' && VfObjContBilling.BillingDate__c>(ObjTemDate.addMonths(1))){
                
                    throw new applicationException('For monthly payment timing the payment date is invalid. The difference between Payment date for this record and previous record should not be greater than 1 month ');
                }
                if(VfObjContBilling.Payment_Timing__c=='Quarterly' && VfObjContBilling.BillingDate__c>(ObjTemDate.addMonths(3))){
                
                    throw new applicationException('For Quarterly payment timing the payment date is invalid. The difference between Payment date for this record and previous record should not be greater than 3 months ');
                }
                if(VfObjContBilling.Payment_Timing__c=='Yearly' && VfObjContBilling.BillingDate__c>(ObjTemDate.addYears(1))){
                
                    throw new applicationException('For Yearly payment timing the payment date is invalid. The difference between Payment date for this record and previous record should not be greater than 1 Year ');
                }
            
            }
    
    
    
    
    
    
    
            //try {
                PayPerAndPayAmountNotEntered(VfObjContBilling.PaymentPercentage__c, VfObjContBilling.Payment_Amount__c  );
            //}
            //catch(exception e ){
                
            //     throw new applicationException('Payment percentag');    
            //}
            if(PayPAndPayAmoNull==true){
            
                throw new applicationException('Payment percentage and Payment Amount cannot be blank at the same time. If finding difficult to enter value,Please try to change the '+'\'Percentage OR Amount\''+' picklist value to enable one of the fields');    
            }
            VarNoPayments=VfObjContBilling.NumberofPayments__c;
            /*
            if(VfVarNum <> VarNoPayments ){
            
                throw new applicationException('You are not allowed to save the Billing records as the Payment Number is greater than than screens for which you have provided input. Please click on the "Save and New" button to continue');
            }
            */
    
    
    
            if( BoolPercentage== true){
                system.debug('Test'+ VarHnPercent);
                //VarHnPercent=VarHnPercent+VfObjContBilling.PaymentPercentage__c;
                
                if(VarHnPercent>100){
                
                    throw new applicationException('Payment Percentage for the Billing type exceeds 100%: Current input percentage'+' '+VarHnPercent+'%');   
                }
                if(VarHnPercent<100){
                
                    throw new applicationException('Payment Percentage for the Billing type is below 100%  : Current input percentage'+' '+VarHnPercent+'%');   
                }
            }
            if( BoolPaymentAm== true){
                //VarHnAmount=VarHnAmount+VfObjContBilling.Payment_Amount__c;
                
                if(VarHnAmount>VfObjContBilling.Total_Amount__c){
                
                    throw new applicationException('Payment Amount for the Billing type exceeds the Total Amount : Total input Payment Amount '+' '+VarHnAmount +'$');   
                }
                if(VarHnAmount<VfObjContBilling.Total_Amount__c){
                
                    throw new applicationException('Payment Amount for the Billing type is below Total Amount  : Total input Payment Amount'+' '+VarHnAmount+'$');   
                }
            }  
    
    
            try{
                List<Contract_Billing__c> LstTempConExisting =CheckForExistingBillRec(VfObjContBilling.Billing_Type__c ,VfObjContBilling.Item_Type__c,VfObjContBilling.Billing_Terms__c );
                if(LstTempConExisting.isEmpty() == false  ){
                
                    delete LstTempConExisting;
                    //throw new applicationException('You cannot create Contract Billing records as valid records already exist for this Contract');
                }
            }
            catch(System.NullPointerException e){
            
            
            }
    
            if( BoolPercentage== true){
            
                VfObjContBilling.Payment_Amount__c=VfObjContBilling.PaymentPercentage__c*VfObjContBilling.Total_Amount__c/100;
                AmoFinalRec=VfObjContBilling.Total_Amount__c-AmoFinalRec;
                PerFinalRec=100-PerFinalRec;
            }
            if(BoolPaymentAm==true){
            
                VfObjContBilling.PaymentPercentage__c=VfObjContBilling.Payment_Amount__c*100/VfObjContBilling.Total_Amount__c;
                PerFinalRec=100-PerFinalRec;
                AmoFinalRec=VfObjContBilling.Total_Amount__c-AmoFinalRec;
            }  
            
            system.debug('Lookup'+VfObjContBilling.ContractId__c);
            ObjContBilling = new Contract_Billing__c();
            ObjContBilling.ContractId__c=VfObjContBilling.ContractId__c;
            //ObjContBilling.CurrencyIsoCode=VfObjContBilling.CurrencyIsoCode;
            ObjContBilling.Comments__c=VfObjContBilling.Comments__c;
            //ObjContBilling.NumberofPayments__c=1;
            ObjContBilling.NumberofPayments__c=VfObjContBilling.NumberofPayments__c;
            //ObjContBilling.DaysfromEvent__c=VfObjContBilling.DaysfromEvent__c;
            ObjContBilling.Percentage_OR_Amount__c=VfObjContBilling.Percentage_OR_Amount__c;
            ObjContBilling.Billing_Terms__c=VfObjContBilling.Billing_Terms__c;
            //ObjContBilling.PaymentPercentage__c=VfObjContBilling.PaymentPercentage__c;
            ObjContBilling.PaymentPercentage__c=PerFinalRec;
            
            ObjContBilling.BillingDate__c=VfObjContBilling.BillingDate__c;
            //ObjContBilling.Payment_Amount__c=VfObjContBilling.Payment_Amount__c;
            ObjContBilling.Payment_Amount__c=AmoFinalRec;
            
            ObjContBilling.Payment_Timing__c=VfObjContBilling.Payment_Timing__c;
            ObjContBilling.Total_Amount__c=VfObjContBilling.Total_Amount__c;
            ObjContBilling.Billing_Type__c=VfObjContBilling.Billing_Type__c;
            ObjContBilling.Item_Type__c=VfObjContBilling.Item_Type__c;
            //ObjContBilling.Grouping_Type__c=VfObjContBilling.Grouping_Type__c;
            
            //insert ObjContBilling;
            MapScreenConBilling.put(VfVarNum,ObjContBilling);
            
            insert MapScreenConBilling.values();
            
            PageReference DetailedPage = new PageReference('/'+ObjContBilling.ContractId__c);   
            return DetailedPage ; 
        }
        catch(exception e){
            system.debug('inside the catch of Save method'+e);
        
            ObjContBilling.adderror(e); 
            //VarHnPercent=VarHnPercent-VfObjContBilling.PaymentPercentage__c;
            try{
                if( BoolPercentage== true){    
                VarHnPercent=VarHnPercent-VfObjContBilling.PaymentPercentage__c;
            }
            if( BoolPaymentAm== true){
                VarHnAmount=VarHnAmount-VfObjContBilling.Payment_Amount__c;
            }
            }
            catch (exception e1){
            }
        
            PayPAndPayAmoNull=false;
            return null;       
        }  
    } 
    
    Public PageReference PerOrAmount (){
        if(VfObjContBilling.Percentage_OR_Amount__c=='Payment Percentage'){
        
            //BoolPaymentAm=false;
            BoolPercentage= true;
            VfObjContBilling.Payment_Amount__c=null;
            
            if(VfObjContBilling.Billing_Type__c=='Software'){
            //ObjCustSettSoftBill=[SELECT Name ,Payment_Percentage__c,Payment_Timing__c FROM Ellu_Software_Billing__c WHERE Name=:VfObjContBilling.Billing_Type__c Limit 1];
            //VfObjContBilling.Payment_Timing__c=ObjCustSettSoftBill.Payment_Timing__c;
            VfObjContBilling.PaymentPercentage__c=ObjCustSettSoftBill.Payment_Percentage__c;
            // VarBoolSoftware=true; 
            //VfObjContBilling. ='On Execution';
            
            }
            //return null;    
        }
        else {
            BoolPercentage=false;
        }
        if(VfObjContBilling.Percentage_OR_Amount__c=='Payment Amount'){
        
            BoolPaymentAm=true;
            VfObjContBilling.PaymentPercentage__c=null;
            
            if(VfObjContBilling.Billing_Type__c=='Software'){
                //ObjCustSettSoftBill=[SELECT Name ,Payment_Percentage__c,Payment_Timing__c FROM Ellu_Software_Billing__c WHERE Name=:VfObjContBilling.Billing_Type__c Limit 1];
                //VfObjContBilling.Payment_Timing__c=ObjCustSettSoftBill.Payment_Timing__c;
                VfObjContBilling.Payment_Amount__c=VfObjContBilling.Total_Amount__c;
                // VarBoolSoftware=true; 
                //VfObjContBilling. ='On Execution';
            
            }
            
            //return null;
            //BoolPercentage= false;    
        }
        else{
        
            BoolPaymentAm=false;
        }
        return null;
    }
    
    public PageReference SaveAndNew (){
    
        
        ObjContBilling = new Contract_Billing__c();
        try{
        
            
            if(VfVarNum == 1){
                VarHnPercent=0; 
                VarHnAmount=0;
            }
            /*
            if((String.valueOf(VfObjContBilling.PaymentPercentage__c)=='' ||VfObjContBilling.PaymentPercentage__c ==null) && (String.valueOf(VfObjContBilling.Payment_Amount__c)=='' ||VfObjContBilling.Payment_Amount__c ==null ) ){
        
                //PayPAndPayAmoNull=true;
                throw new applicationException('Please enter a value in Payment percentage or Payment Amount field. If finding difficult to enter value,Please try to change the '+'\'Percentage OR Amount\''+' picklist value to enable one of the field');
                 
            }
            */
            if( BoolPercentage== true){
                system.debug('Test'+ VarHnPercent);
                VarHnPercent=VarHnPercent+VfObjContBilling.PaymentPercentage__c;
                //AmoFinalRec= AmoFinalRec+VfObjContBilling.Payment_Amount__c;
            }
            if( BoolPaymentAm== true){
                VarHnAmount=VarHnAmount+VfObjContBilling.Payment_Amount__c;
                //PerFinalRec=PerFinalRec+VfObjContBilling.PaymentPercentage__c;
                
            }
        Validation ();  
        /*      
            if(VfObjContBilling.Payment_Timing__c==null || VfObjContBilling.Payment_Timing__c==''){
            
                throw new applicationException('Please select a Payment Timing');
            }
            if(VfObjContBilling.NumberofPayments__c==null ){
            
                throw new applicationException('Number Of Payments field cannot be blank. Please enter a valid number');
            }
            if(VfObjContBilling.BillingDate__c==null ){
            
                throw new applicationException('Number Of Payments field cannot be blank. Please enter a valid date');
            }
            if(VfObjContBilling.Payment_Timing__c<>'Monthly'&& VfObjContBilling.Payment_Timing__c<>'Quarterly' && VfObjContBilling.NumberofPayments__c<>1 ){
            
                throw new applicationException('Number of Payment should be equal to 1 for the selected Payment Timing.');
            }
            if(VfObjContBilling.Payment_Timing__c=='Quarterly' && VfObjContBilling.NumberofPayments__c<>4 ){
            
                throw new applicationException('Number of Payment should be equal to 4 for the selected Payment Timing.');
            }
        */  
            if(VfVarNum == 1){
                //VarHnPercent=0;
                //VarHnAmount=0; 
                
                if(VfObjContBilling.Payment_Timing__c=='Monthly' && VfObjContBilling.BillingDate__c>(ObjCurrentDate.addMonths(1))){
                
                    throw new applicationException('For monthly payment timing the payment date is invalid.The difference between Payment date for this record and current date should not be greater than 1 month');
                }
                if(VfObjContBilling.Payment_Timing__c=='Quarterly' && VfObjContBilling.BillingDate__c>(ObjCurrentDate.addMonths(3))){
                
                    throw new applicationException('For Quarterly payment timing the payment date is invalid.The difference between Payment date for this record and current date should not be greater than 3 months');
                }
                if(VfObjContBilling.Payment_Timing__c=='Yearly' && VfObjContBilling.BillingDate__c>(ObjCurrentDate.addYears(1))){
                
                    throw new applicationException('For Yearly payment timing the payment date is invalid.The difference between Payment date for this record and current date should not be greater than 1 Year');
                }
                if(VfObjContBilling.Payment_Timing__c=='On Execution' ){
                
                    throw new applicationException('For Payment Timing "On Execution" no more than one records can be created ');       
                }
                /*
                if(VarSaCreateBillSer==true && VfObjContBilling.Billing_Type__c <> 'Services'){
                
                throw new applicationException('You cannot select this Billing type. Please select the '+'Services'+' type');    
                }  
                */
                //VfObjContBilling.PaymentPercentage__c=0;
            }
            else{
            
                
                if(VfObjContBilling.Payment_Timing__c=='Monthly' && VfObjContBilling.BillingDate__c>(ObjTemDate.addMonths(1))){
                
                    throw new applicationException('For monthly payment timing the payment date is invalid. The difference between Payment date for this record and previous record should not be greater than 1 month ');
                }
                if(VfObjContBilling.Payment_Timing__c=='Quarterly' && VfObjContBilling.BillingDate__c>(ObjTemDate.addMonths(3))){
                
                    throw new applicationException('For Quarterly payment timing the payment date is invalid. The difference between Payment date for this record and previous record should not be greater than 3 months ');
                }
                if(VfObjContBilling.Payment_Timing__c=='Yearly' && VfObjContBilling.BillingDate__c>(ObjTemDate.addYears(1))){
                
                    throw new applicationException('For Yearly payment timing the payment date is invalid. The difference between Payment date for this record and previous record should not be greater than 1 Year ');
                }
                if(VfObjContBilling.Payment_Timing__c=='On Execution' ){
                
                    throw new applicationException('You cannot select this payment timing . "On execution" can to be selected in the screen no. 1 only');       
                }
            
            }
            try{
                List<Contract_Billing__c> LstTempConExisting =CheckForExistingBillRec(VfObjContBilling.Billing_Type__c , VfObjContBilling.Item_Type__c,VfObjContBilling.Billing_Terms__c );
                if(LstTempConExisting.isEmpty() <> true ){
                    //Delete LstTempConExisting;
                    //throw new applicationException('You cannot create Contract Billing records as valid records already exist for this Contract');
                }
            }
            catch(System.NullPointerException e){
            
            
            }
            PayPerAndPayAmountNotEntered(VfObjContBilling.PaymentPercentage__c, VfObjContBilling.Payment_Amount__c  );
            if(PayPAndPayAmoNull==true){
            
                throw new applicationException('Payment percentage and Payment Amount cannot be blank at the same time. If finding difficult to enter value,Please try to change the '+'\'Percentage OR Amount\''+' picklist value to enable one of the fields');    
            }
            
            VarNoPayments=VfObjContBilling.NumberofPayments__c;
            /*
            if( VarNoPayments == VfVarNum ){
                //BoolShowCrServBut01=true;
                
                
                //if(VarSaCreateBillSer==false){
                //BoolShowCrServBut=true;
                
                
                
                throw new applicationException('You are not supposed to hit this button. Please use Save buttons to continue with your transaction');       
            }
            */
            
            
            if( BoolPercentage== true){
                //VarHnPercent=VarHnPercent+VfObjContBilling.PaymentPercentage__c;
                
                if(VarHnPercent>100){
                
                    throw new applicationException('Payment Percentage for the Billing type exceeds 100%');   
                }
                /*  if(VarHnPercent<100){
                
                throw new applicationException('Payment Percentage for the Billing type is below 100%  : Current input percentage'+' '+VarHnPercent+'%');   
                }*/
            
            }
            if( BoolPaymentAm== true){
                //VarHnAmount=VarHnAmount+VfObjContBilling.Payment_Amount__c;
                
                if(VarHnAmount>VfObjContBilling.Total_Amount__c){
                
                    throw new applicationException('Payment Amount for the Billing type exceeds the Total Amount : Total input Payment Amount '+' '+VarHnAmount +'$');   
                }
                /*  if(VarHnAmount<VfObjContBilling.Payment_Amount__c){
                
                throw new applicationException('Payment Amount for the Billing type is below Total Amount  : Total input Payment Amount'+' '+VarHnAmount+'$');   
                }*/
            }   
            
            if(VfVarNum > 0){
            
                BoolVarReadOnly=false;
                BoolVarBillTypeReadOnly=false;    
            }
            
            
            if(VfVarNum ==(VarNoPayments-1)){
                BoolShowCrServBut01=true;
                if(VarSaCreateBillSer==false){
                    if(VfObjContBilling.Billing_Type__c <> 'Services'){
                        BoolShowCrServBut=true;
                    }
                }
            }
            //if(VfVarNum <=VarNoPayments){
                
                if( BoolPercentage== true){
                
                    VfObjContBilling.Payment_Amount__c=VfObjContBilling.PaymentPercentage__c*VfObjContBilling.Total_Amount__c/100;
                    VfObjContBilling.Payment_Amount__c=(Decimal)(VfObjContBilling.Payment_Amount__c).setScale(2 , system.roundingmode.HALF_UP);
                    AmoFinalRec= AmoFinalRec+(Decimal)(VfObjContBilling.Payment_Amount__c).setScale(2 , system.roundingmode.HALF_UP);
                    PerFinalRec=PerFinalRec+(Decimal)(VfObjContBilling.PaymentPercentage__c).setScale(2 , system.roundingmode.HALF_UP);
                }
                if(BoolPaymentAm==true){
                
                    VfObjContBilling.PaymentPercentage__c=(VfObjContBilling.Payment_Amount__c*100/VfObjContBilling.Total_Amount__c);
                    VfObjContBilling.PaymentPercentage__c=(Decimal)(VfObjContBilling.PaymentPercentage__c).setScale(2 , system.roundingmode.HALF_UP);
                    PerFinalRec=PerFinalRec+(Decimal)(VfObjContBilling.PaymentPercentage__c).setScale(2 , system.roundingmode.HALF_UP);
                    AmoFinalRec= AmoFinalRec+(Decimal)(VfObjContBilling.Payment_Amount__c).setScale(2 , system.roundingmode.HALF_UP);
                }
                
                
                ObjContBilling.ContractId__c=VfObjContBilling.ContractId__c;
                //ObjContBilling.CurrencyIsoCode=VfObjContBilling.CurrencyIsoCode;
                ObjContBilling.Comments__c=VfObjContBilling.Comments__c;
                //ObjContBilling.NumberofPayments__c=1;
                ObjContBilling.NumberofPayments__c=VfObjContBilling.NumberofPayments__c;
                //ObjContBilling.DaysfromEvent__c=VfObjContBilling.DaysfromEvent__c;
                ObjContBilling.Percentage_OR_Amount__c=VfObjContBilling.Percentage_OR_Amount__c;
                ObjContBilling.Billing_Terms__c=VfObjContBilling.Billing_Terms__c;
                
                ObjContBilling.Item_Type__c=VfObjContBilling.Item_Type__c;
                
                ObjContBilling.PaymentPercentage__c=VfObjContBilling.PaymentPercentage__c;
                ObjContBilling.BillingDate__c=VfObjContBilling.BillingDate__c;
                ObjContBilling.Payment_Amount__c=VfObjContBilling.Payment_Amount__c;
                ObjContBilling.Payment_Timing__c=VfObjContBilling.Payment_Timing__c;
                ObjContBilling.Total_Amount__c=VfObjContBilling.Total_Amount__c;
                ObjContBilling.Billing_Type__c=VfObjContBilling.Billing_Type__c;
                
                ObjTemDate=ObjContBilling.BillingDate__c;
                //insert ObjContBilling;
                
                MapScreenConBilling.put(VfVarNum,ObjContBilling);
                
                
                //PageReference ApexPage = new PageReference('/'+'apex/Ellu_SFDC_SAP_Int_ContBillEditPage');   
                VfVarNum++;
            //}
            return null ; 
        }
        catch(exception e){
        
            ObjContBilling.adderror(e); 
            try{
                if( BoolPercentage== true){    
                    VarHnPercent=VarHnPercent-VfObjContBilling.PaymentPercentage__c;
                    system.debug('ErrPer'+VarHnPercent );    
                }
                if( BoolPaymentAm== true){
                    VarHnAmount=VarHnAmount-VfObjContBilling.Payment_Amount__c;
                }
            }
            catch (exception e1){
                system.debug('ErrPer02'+VarHnPercent ); 
            }
            
            PayPAndPayAmoNull=false;
            return null;       
        }  
        
        //return null ; 
    
    }
    Public Pagereference GoToOpportunity (){
    
        Contract ObjContract = new Contract();
        try{
            ObjContract=[SELECT OpportunityId__c FROM Contract WHERE Id = : VfObjContBilling.ContractId__c ];
            
            PageReference ToOppRecord = new PageReference('/'+ObjContract.OpportunityId__c);
            return ToOppRecord;
        }
        catch(exception e){
            return null;
        }
    }
}