Public Class Ellu_SFDC_SAP_PrTrigLoopCreateContCls {

    Private Static Boolean BoolVarPrTrigLoopForCreateContract =false;
    
    public static boolean getBoolVarPrTrigLoopForCreateContract () {
        return BoolVarPrTrigLoopForCreateContract;
    }

    // By setting the variable to true, it maintains this  
    
    // new value throughout the duration of the request  
    
    // (or testMethod)  
    
    public static void setBoolVarPrTrigLoopForCreateContract () {
        BoolVarPrTrigLoopForCreateContract = true;
    }
    /*
    public static void setVarLoopMethodSoftFam () {
        BoolVarPreventtrggFirLoopForSoftwareProduct = false;
    }
    */


}