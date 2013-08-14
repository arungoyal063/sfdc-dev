Public Class Ellu_SFDC_SAP_PrTrigLoopForSoftProdFam {

    Private Static Boolean BoolVarPreventtrggFirLoopForSoftwareProduct =false;
    
    public static boolean getBoolVarPreventtrggFirLoopMethodForSoftwareFam () {
        return BoolVarPreventtrggFirLoopForSoftwareProduct;
    }

    // By setting the variable to true, it maintains this  
    
    // new value throughout the duration of the request  
    
    // (or testMethod)  
    
    public static void setBoolVarPreventtrggFirLoopMethodForSoftwareFam () {
        BoolVarPreventtrggFirLoopForSoftwareProduct = true;
    }

    public static void setVarLoopMethodSoftFam () {
        BoolVarPreventtrggFirLoopForSoftwareProduct = false;
    }



}