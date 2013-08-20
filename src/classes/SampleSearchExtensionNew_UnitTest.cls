@isTest
public with sharing class SampleSearchExtensionNew_UnitTest 
{
	Static TestMethod void TestMethod1()
	{
		Sample_Product__c sampProdObj = new Sample_Product__c();
		sampProdObj.color_code__c = '929';
		sampProdObj.style_desc__c = 'ab';
		sampProdObj.style_code__c = 'PREDG';
		sampProdObj.SKU__c = '176332';
		sampProdObj.Product_Category__c = 'Rubber';
		sampProdObj.size__c = '4X48';
		sampProdObj.color_desc__c = '789';
		sampProdObj.Active__c = true;
		insert sampProdObj;
		
		ApexPages.StandardController controller = new ApexPages.StandardController(sampProdObj);
		SampleSearchExtensionNew sampSrchExtObj = new SampleSearchExtensionNew(controller);
	}
}