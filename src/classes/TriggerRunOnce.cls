public class TriggerRunOnce {

    public static boolean run = true;
    public static boolean billRun = true;
    
    
    public static boolean runOnce(){
 
        if(run){

            run=false;
            
            return true;
        
        } else{return run;}
        
    }
    
    public static boolean billRunOnce(){
 
        if(billRun){

            billRun=false;
            
            return true;
        
        } else{return billRun;}
        
    }
    

    
    private static testmethod void testTriggerRunOnce(){
        
        System.assert(TriggerRunOnce.runOnce(), 'Recursion check failed. Please review OSRUtil recursion logic');
        System.assert(!TriggerRunOnce.runOnce(), 'Recursion check failed. Please review OSRUtil recursion logic');
        System.assert(TriggerRunOnce.billRunOnce(), 'Recursion check failed. Please review OSRUtil recursion logic');
        System.assert(!TriggerRunOnce.billRunOnce(), 'Recursion check failed. Please review OSRUtil recursion logic');
    }
    
}