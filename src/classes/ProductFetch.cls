public with sharing class ProductFetch {
	private static transient  List<PricebookEntry> productList23;
    private static transient  Map<String,Set<String>> prodNamecatNameSetMap = new Map<String,Set<String>>();
    private static transient  Map<String,Set<String>> catNameStyleDespSetMap = new Map<String,Set<String>>(); 
    private static transient  Map<String,Set<String>> styleDespBKSetMap = new Map<String,Set<String>>();
    private static transient  Map<String,Set<String>> bkSizeSetMap = new Map<String,Set<String>>();
    private static transient  Map<String,Set<String>> sizeCOlorDesSetMap = new Map<String,Set<String>>();
    
  public static Map<String,Set<String>> getStyleDesp(String pName) {
    	Set<String> tempSDSet ;
        catNameStyleDespSetMap = new Map<String,Set<String>>(); 
    	for(PricebookEntry tempPBE : [Select Product2.Product_Category__c,Product2.Bk__c, Product2.Style_Description__c,Product2.size__c,
              Product2.Color_Description__c, Id,  Product2.Name   From PricebookEntry Where 
              IsActive = true and Product2.IsActive = true and Product2.Product_Category__c =: pName and 
              Product2.Bk__c != null and Product2.Style_Description__c != null and Product2.size__c != null and  Product2.Color_Description__c != null] ){
            if(null==tempPBE.Product2.Product_Category__c||null==tempPBE.Product2.Style_Description__c){
            }else if(catNameStyleDespSetMap.containsKey(tempPBE.Product2.Product_Category__c)){
                tempSDSet = catNameStyleDespSetMap.get(tempPBE.Product2.Product_Category__c); 
                tempSDSet.add(tempPBE.Product2.Style_Description__c);
                catNameStyleDespSetMap.put(tempPBE.Product2.Product_Category__c,tempSDSet);
            }else{
                tempSDSet = new Set<String>(); 
                tempSDSet.add(tempPBE.Product2.Style_Description__c);
                catNameStyleDespSetMap.put(tempPBE.Product2.Product_Category__c,tempSDSet);
            }
        }
        return catNameStyleDespSetMap;
   }
   
   public static Map<String,Set<String>> getBK(String pName,String styleDesc) {
    	Set<String> tempbkSet;
        styleDespBKSetMap = new Map<String,Set<String>>();
    	for(PricebookEntry tempPBE : [Select Product2.Product_Category__c,Product2.Bk__c, Product2.Style_Description__c,Product2.size__c,
              Product2.Color_Description__c, Id,  Product2.Name   From PricebookEntry Where 
              IsActive = true and Product2.IsActive = true and Product2.Product_Category__c =:pName and 
              Product2.Bk__c != null  and Product2.Style_Description__c =: styleDesc and Product2.size__c != null and  Product2.Color_Description__c != null] ){
            if(null==tempPBE.Product2.Product_Category__c||null==tempPBE.Product2.Style_Description__c||null==tempPBE.Product2.Bk__c){
                }else if(styleDespBKSetMap.containsKey(tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c)){
                    tempbkSet = styleDespBKSetMap.get(tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c);
                    tempbkSet.add(tempPBE.Product2.Bk__c);
                    styleDespBKSetMap.put(tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c,tempbkSet);
                }else{
                    tempbkSet = new Set<String>(); 
                    tempbkSet.add(tempPBE.Product2.Bk__c);
                    styleDespBKSetMap.put(tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c,tempbkSet);
                }
   		}
   		return styleDespBKSetMap;
   }
   
   public static Map<String,Set<String>> getProdSize(String bk, String styleDesc, String pName) {
    	Set<String> tempSizeSet;
        bkSizeSetMap = new Map<String,Set<String>>();
    	for(PricebookEntry tempPBE : [Select Product2.Product_Category__c,Product2.Bk__c, Product2.Style_Description__c,Product2.size__c,
              Product2.Color_Description__c, Id,  Product2.Name   From PricebookEntry Where 
              IsActive = true and Product2.IsActive = true and Product2.Product_Category__c =:pName and 
              Product2.Bk__c =: bk and Product2.Style_Description__c =:styleDesc and Product2.size__c != null and  Product2.Color_Description__c != null] ){
            if(null==tempPBE.Product2.Product_Category__c||null==tempPBE.Product2.Style_Description__c||null==tempPBE.Product2.Bk__c||null==tempPBE.Product2.Size__c){
                }else if(bkSizeSetMap.containsKey(tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c)){
                    tempSizeSet = bkSizeSetMap.get(tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c);
                    tempSizeSet.add(tempPBE.Product2.Size__c);
                    bkSizeSetMap.put(tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c,tempSizeSet);
                }else{
                    tempSizeSet = new Set<String>(); 
                    tempSizeSet.add(tempPBE.Product2.Size__c);
                    bkSizeSetMap.put(tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c,tempSizeSet);
                }
             
   		}
   		return bkSizeSetMap;
   }
   
   public static Map<String,Set<String>> getColordes(String size, String bk, String styleDesc , String pName) {
    	Set<String> tempcolordesSet;
        sizeCOlorDesSetMap = new Map<String,Set<String>>();
    	for(PricebookEntry tempPBE : [Select Product2.Product_Category__c,Product2.Bk__c, Product2.Style_Description__c,Product2.size__c,
              Product2.Color_Description__c, Id,  Product2.Name   From PricebookEntry Where 
              IsActive = true and Product2.IsActive = true and Product2.Product_Category__c =:pName and 
              Product2.Bk__c =: bk and Product2.Style_Description__c =:styleDesc and Product2.size__c =: size and  Product2.Color_Description__c != null] ){
            if(null==tempPBE.Product2.Product_Category__c||null==tempPBE.Product2.Style_Description__c||null==tempPBE.Product2.Bk__c||null==tempPBE.Product2.Size__c||null==tempPBE.Product2.Color_Description__c){
                }else if(sizeCOlorDesSetMap.containsKey(tempPBE.Product2.Size__c+tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c)){
                    tempcolordesSet = sizeCOlorDesSetMap.get(tempPBE.Product2.Size__c+tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c);
                    tempcolordesSet.add(tempPBE.Product2.Color_Description__c);
                    sizeCOlorDesSetMap.put(tempPBE.Product2.Size__c+tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c,tempcolordesSet);
                }else{
                    tempcolordesSet = new Set<String>(); 
                    tempcolordesSet.add(tempPBE.Product2.Color_Description__c);
                    sizeCOlorDesSetMap.put(tempPBE.Product2.Size__c+tempPBE.Product2.Bk__c+tempPBE.Product2.Style_Description__c+tempPBE.Product2.Product_Category__c,tempcolordesSet);
                }
             
   		}
   		return sizeCOlorDesSetMap;
   }
}