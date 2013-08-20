public with sharing class TriggerRunOnce {

public static boolean run = true;

    public static boolean runOnce(){
 
        if(run){

            run=false;
            
            return true;
        
        } else{return run;}
        
    }
    
    private static testmethod void testTriggerRunOnce(){
        
        System.assert(TriggerRunOnce.runOnce(), 'Recursion check failed. Please review OSRUtil recursion logic');

        System.assert(!TriggerRunOnce.runOnce(), 'Recursion check failed. Please review OSRUtil recursion logic');

    }
}