public  class Ellu_SFDC_SAP_ContractLineFilterClass2 {
    
    private Integer pageSize;
    private Integer pageNumber;
    private Integer totalPageNumber;
    public Integer TotalContLineSize {get; set;}
    public Decimal TotalAmount {get; set;}
    public ID ContractId;
    public Boolean VarBoolRollOrNot {get ; set ;} 
    public Boolean VarProFam {get; set;}
    public Boolean renderBillingTerm {get; set;}

    
    Public List<ContractLine__c> LstObjContractLine {get; set;} 
    Public Contract_Billing__c ObjContBilling ;
    Public  Contract_Billing__c VfObjContBilling {get; set;}
    public class applicationException extends Exception {}
    
    Public  Contract_Billing__c getVfObjContBilling(){
        return VfObjContBilling;
    }
    Public  void setVfObjContBilling(Contract_Billing__c ConBill){
        system.debug('ConBill'+ConBill);
        this.VfObjContBilling=ConBill;
    }
    public  Ellu_SFDC_SAP_ContractLineFilterClass2(ApexPages.StandardController controller) {
    System.Debug('Calling constract');
        ContractId = ApexPages.currentPage().getParameters().get('ContractID__c');
        
    ObjContBilling = new Contract_Billing__c();
    VfObjContBilling = new Contract_Billing__c();
    LstObjContractLine = new List<ContractLine__c>();
    
    VfObjContBilling.ContractId__c=ContractId;
    VarBoolRollOrNot=true;
    pageNumber = 0;
    
    totalPageNumber = 0;
    pageSize = 10;
    TotalContLineSize=0;
    TotalAmount=0;
    //renderBillingTerm=false;
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
    /*
    Public void WrapperMethodForContLine ( ){
    
    
        String sortFullExp;
        sortFullExp = sortExpression + ' ' +sortDirection;
        
        String StrBillType = '\''+VfObjContBilling.Billing_Type__c+'\'';
        String StrItemType='\''+VfObjContBilling.Item_Type__c+'\'';
        
        string query = 'SELECT Id , Name ,Item_Type__c , Product_Family__c , TotalPrice__c, Quantity__c ,  FROM ContractLine__c WHERE Product_Family__c ='+StrBillType+' AND Item_Type__c ='+StrItemType+'order by ' + sortFullExp + ' limit 50000';
        //System.debug('======'+query);
        LstObjContractLine = Database.query(query);
        
        ViewData();
    
        
    }
    */
    public Pagereference runAssign()
    {
            System.Debug('runAssign');

        try{
            VarProFam = true;
            renderBillingTerm=false;
            //enterpriseList = new list<Enterprise_Rule__c>();
            //territorylist= new List<Territory_User__c>();
            String sortFullExp;
            
            sortFullExp = sortExpression + ' ' +sortDirection; 
            
            
            //if(VfObjContBilling.Billing_Type__c!=null &&VfObjContBilling.Billing_Type__c!='' )
            if((VfObjContBilling.Billing_Type__c!=null && VfObjContBilling.Billing_Type__c!='') &&  (VfObjContBilling.Item_Type__c ==null || VfObjContBilling.Item_Type__c =='') && (VfObjContBilling.Billing_Terms__c ==null || VfObjContBilling.Billing_Terms__c ==''))
            {
            
                String StrBillType = '\''+VfObjContBilling.Billing_Type__c+'\'';
                //String StrItemType='\''+VfObjContBilling.Item_Type__c+'\'';
                String StrContractId= '\''+VfObjContBilling.ContractId__c+'\'';
                //allenterpriselist= new List<Enterprise_Rule__c>();
                //allterritorylist=new List<Territory_User__c>();
                LstObjContractLine.clear();
                string query = 'SELECT Id , Name ,ProductId__c,Item_Type__c ,BillingTerms__c, Product_Family__c , TotalPrice__c ,Quantity__c FROM ContractLine__c WHERE ContractID__c='+StrContractId+' AND Product_Family__c ='+StrBillType+'limit 50000';
                System.debug('======1'+query);
                VfObjContBilling.Item_Type__c=null;
                
                LstObjContractLine = Database.query(query);
                
                //TotalEnterpriseAssign=allenterpriselist.size();
                ViewData(); 
                RollupDetails ();
           }
           if((VfObjContBilling.Billing_Type__c!=null && VfObjContBilling.Billing_Type__c!='') &&  (VfObjContBilling.Item_Type__c !=null && VfObjContBilling.Item_Type__c !='') && (VfObjContBilling.Billing_Terms__c ==null || VfObjContBilling.Billing_Terms__c ==''))
           {
                  System.Debug('Rajan Billing Term in condition VfObjContBilling.Billing_Type__c='+VfObjContBilling.Billing_Type__c+' and VfObjContBilling.Item_Type__c='+VfObjContBilling.Item_Type__c);
                String StrBillType = '\''+VfObjContBilling.Billing_Type__c+'\'';
                String StrItemType='\''+VfObjContBilling.Item_Type__c+'\'';
                String StrContractId= '\''+VfObjContBilling.ContractId__c+'\'';
                //allenterpriselist= new List<Enterprise_Rule__c>();
                //allterritorylist=new List<Territory_User__c>();
                LstObjContractLine.clear();
                string query = 'SELECT Id , Name ,ProductId__c,Item_Type__c ,BillingTerms__c, Product_Family__c , TotalPrice__c ,Quantity__c FROM ContractLine__c WHERE ContractID__c='+StrContractId+' AND Product_Family__c ='+StrBillType+'AND Item_Type__c = '+ StrItemType+' limit 50000';
                System.debug('======2'+query);
                LstObjContractLine = Database.query(query);
                
                //TotalEnterpriseAssign=allenterpriselist.size();
                ViewData();
                RollupDetails ();
               
           }        
           
            if((VfObjContBilling.Billing_Type__c!=null && VfObjContBilling.Billing_Type__c!='') &&  (VfObjContBilling.Item_Type__c !=null && VfObjContBilling.Item_Type__c !='') && (VfObjContBilling.Billing_Terms__c !=null && VfObjContBilling.Billing_Terms__c !=''))
            {
                LstObjContractLine.clear();
                String StrBillType = '\''+VfObjContBilling.Billing_Type__c+'\'';
                String StrItemType='\''+VfObjContBilling.Item_Type__c+'\'';
                String StrContractId= '\''+VfObjContBilling.ContractId__c+'\'';
                String StrBillTerms= '\''+VfObjContBilling.Billing_Terms__c+'\'';
                //allenterpriselist= new List<Enterprise_Rule__c>();
                //allterritorylist=new List<Territory_User__c>();
                string query = 'SELECT Id , Name ,ProductId__c,Item_Type__c ,BillingTerms__c, Product_Family__c , TotalPrice__c ,Quantity__c FROM ContractLine__c WHERE ContractID__c='+StrContractId+' AND Product_Family__c ='+StrBillType+'AND Item_Type__c = '+ StrItemType+'AND BillingTerms__c = '+ StrBillTerms+' limit 50000';
                System.debug('======'+query);
                LstObjContractLine = Database.query(query);
                
                //TotalEnterpriseAssign=allenterpriselist.size();
               ViewData();
               RollupDetails ();  
               //RollupDetails ();   
          }
           
              /*
           else {
               
                LstObjContractLine.clear();
           }*/
            
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    return null;
    
    }
    
    
     Public PageReference RollupDetails (){
        try{ 
            TotalContLineSize=0;
            TotalContLineSize=LstObjContractLine.size(); 
            
            TotalAmount=0;
            for(ContractLine__c TempObjConLine : LstObjContractLine ){
            
                TotalAmount = TotalAmount+ TempObjConLine.TotalPrice__c;   
            }
            //PageReference RollUpPage = new PageReference('/apex/Ellu_SFDC_SAP_Int_RollUpSummaryPage? ContractId__c='+{!ContractId__c} );
            VarBoolRollOrNot=false; 
            system.debug('Total Amount debug'+TotalAmount);
            //VarProFam = false;
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }  
        return null ; 
         
     }

    
     
     
     Public PageReference ContinueToCreateBillRecords (){
         
         try{
         if(VfObjContBilling.Billing_Type__c==null || VfObjContBilling.Billing_Type__c=='' ){
             throw new applicationException('Please Select Billing Type');
         }
         if(VfObjContBilling.Item_Type__c==null || VfObjContBilling.Item_Type__c==''){
             throw new applicationException('Please select Item Type');
         }
         if(VfObjContBilling.Billing_Terms__c==null || VfObjContBilling.Billing_Terms__c=='' ){
             throw new applicationException('Please select Billing Term');
         }
         if(LstObjContractLine.IsEmpty()==true){
             throw new applicationException('No Contract Line items selected, Billing records cannot be created.');    
         }
        // RollupDetails ();
         if(VfObjContBilling.Item_Type__c=='T&M' ){
         
             VfObjContBilling.Item_Type__c='TandM';    
         }
         system.debug('ContractDebug'+VfObjContBilling.ContractId__c +VfObjContBilling.Billing_Type__c +VfObjContBilling.Item_Type__c+VfObjContBilling.Billing_Terms__c+TotalAmount);
         PageReference ToCreateBillRecords = new PageReference('/apex/Ellu_SFDC_SAP_Int_ContBillEditPage02?ContractId__c='+VfObjContBilling.ContractId__c+'&Billing_Type__c='+VfObjContBilling.Billing_Type__c+'&Item_Type__c='+VfObjContBilling.Item_Type__c+'&Billing_Terms__c='+VfObjContBilling.Billing_Terms__c +'&Total_Amount__c='+TotalAmount);
         //VarBoolRollOrNot=false;   
         return ToCreateBillRecords ; 
         
         }
         catch(exception e){
            VfObjContBilling.adderror(e); 
            return null;
         }
         
     }
    
    
    public List<ContractLine__c> AllAssignConLineRecords  ;
    public List<ContractLine__c> RetAllAssignConLineRecords ;
    
    
    public List<ContractLine__c> getAllAssignConLineRecords ()
    {
        //return altAddresses;
        system.debug('Chinks'+RetAllAssignConLineRecords);
        return RetAllAssignConLineRecords;
    }
    
    public Integer getPageSize()
    {
        return pageSize;
    }
    public Boolean getPreviousButtonEnabled()
    {
        return !(pageNumber > 1);
    }
    public Boolean getNextButtonDisabled()
    {
        if (LstObjContractLine == null ) return true;
        else
        return ((pageNumber * pageSize) >= LstObjContractLine.size());
    }
    public Integer getTotalPageNumber()
    {
        if (totalPageNumber == 0 && LstObjContractLine !=null)
        {
            totalPageNumber = LstObjContractLine.size() / pageSize;
            Integer mod = LstObjContractLine.size() - (totalPageNumber * pageSize);
        if (mod > 0)
            totalPageNumber++;
        }
        return totalPageNumber;
    }
    
    public PageReference ViewData()
    {
        AllAssignConLineRecords = null;
        totalPageNumber = 0;
        BindData(1);
        return null;
    }
    private void BindData(Integer newPageIndex)
    {
        try
        {
        
            if (AllAssignConLineRecords == null)
                AllAssignConLineRecords=LstObjContractLine;
        
            RetAllAssignConLineRecords = new List<ContractLine__c>{};
        
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;
            if (newPageIndex > pageNumber)
            {
                min = pageNumber * pageSize;
                max = newPageIndex * pageSize;
            }
            else
            {
                system.debug('Troodi'+newPageIndex + pageSize);
                max = newPageIndex * pageSize;
                min = max - pageSize;
        
        }
        system.debug('Tinku'+LstObjContractLine);
        
        
        for(ContractLine__c a : LstObjContractLine)
        {
            counter++;
            if (counter > min && counter <= max)
                RetAllAssignConLineRecords.add(a);
        }
        pageNumber = newPageIndex;
        /*   if (RetAllAssignConLineRecords == null || RetAllAssignConLineRecords.size() <= 0)
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Enterprise Assignment  found for the given User.'));*/
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    }
    public PageReference nextBtnClick() {
        system.debug('Inside Next');
        BindData(pageNumber + 1);
        return null;
    }
    public PageReference previousBtnClick() {
        BindData(pageNumber - 1);
        return null;
    }
    
    
    
    private String sortDirection ='ASC';
    private String sortExp='Name';
    
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            //system.debug('*******'+value);
        
            if (value =='Name')
            {
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
                sortExp=value;
            }
        else {
            sortDirection = 'ASC';
            }
        }
    }
    
    
    public String getSortDirection()
    {
        //if not column is selected
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value)
    {
        sortDirection = value;
    } 
    
    
}