Public Class Ellu_SFDC_SAP_PreventInfiniteTrigLoop {

    Private Static Boolean BoolVarPreventtrggFirLoop =false;
    
    public static boolean getBoolVarPreventtrggFirLoopMethod () {
        return BoolVarPreventtrggFirLoop;
    }

    // By setting the variable to true, it maintains this  
    
    // new value throughout the duration of the request  
    
    // (or testMethod)  
    
    public static void setBoolVarPreventtrggFirLoopMethod () {
        BoolVarPreventtrggFirLoop = true;
    }

    public static void setVarLoopMethod () {
        BoolVarPreventtrggFirLoop = false;
    }



}