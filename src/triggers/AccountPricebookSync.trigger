trigger AccountPricebookSync on Account (before insert, before update) {
    
    Integer size = Trigger.new.size();
    String[] pName = new String[]{};
    for(Account a : trigger.new)
    {
        if(a.Price_Book__c != null) pName.add(a.Price_Book__c);
    }
    List<Pricebook2> pList = [Select Id, Name from Pricebook2 where Name IN :pName];
    Map<String, Pricebook2> pMap = new Map<String, Pricebook2>();
    for(Pricebook2 p : pList)
    {
        pMap.put(p.Name, p);
    }
    for(Integer x = 0; x < size; x++){
        
        Account anew = Trigger.new[x];
        Account aold;
        if(!Trigger.isInsert)
            aold = Trigger.old[x];
            
        String newname = anew.Price_Book__c;
        if(Trigger.isInsert){
            if(anew.Price_Book__c != null){
                if(pMap.containsKey(newname)){
                    anew.Price_Book_ID__c = String.valueOf(pMap.get(newname).Id);
                }else{
                    anew.addError('No Pricebook with the name ' + anew.Price_Book__c + ' exists.');
                }
            }
        }else{
            if(anew.Price_Book__c != null && anew.Price_Book__c != aold.Price_Book__c){
                if(pMap.containsKey(newname)){
                    anew.Price_Book_ID__c = String.valueOf(pMap.get(newname).Id);
                }else{
                    anew.addError('No Pricebook with the name ' + anew.Price_Book__c + ' exists.');
                }
            }
        }
    }
    
}