@isTest
private class TestPriceBookTrigger {
    
    @isTest(SeeAllData=true)
    static void testInsertProductWithValue() {
        Id pId = insertValidProduct();
        Product2[] testProducts = [SELECT Id FROM Product2 WHERE Id = :pId LIMIT 1];
        if (testProducts != NULL && testProducts.size() != 0) {
        	System.assertNotEquals(TestProducts.get(0), NULL, 'TestInsertProductWithValue: object was not inserted correctly');
        }
        //insertValidProduct();
    }
    
    private static String insertValidProduct() {
        Product2 p = new Product2(Name = 'TestProductName' + System.currentTimeMillis(), SKU__c = String.valueOf(System.currentTimeMillis()));
        insert p;
        return p.Id;
    }
    
}