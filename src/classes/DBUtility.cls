public with sharing class DBUtility {
	/*To get all Profile__c having type = template*/
	public static list<Profile__c> getProfileHavingTypeTemplate(){
		return new list<Profile__c>([Select Name,Type__c,Account__r.name From Profile__c  where type__C='Template']);
	}
	/**/
	public static list<Profile_Order_Choice__c> getProfileOrderChoice(){
		return new list<Profile_Order_Choice__c>([SELECT Name FROM Profile_Order_Choice__c]);
	}
	/*To get all Profile__c BY ID*/
	public static list<Profile__c> getProfileById(list<String> profileIds){
		return new list<Profile__c>([Select Name,Type__c,Account__r.name From Profile__c  where id IN:profileIds]);
	}
	/**/
	public static list<Profile__c> getProfileandOrderChoiceBypId(list<String> profileIds){
		return new list<Profile__c>([Select Account__c, (Select Id, OwnerId, Name, Order_Choice__c, Profile__c From Profile_Order_Choices__r) From Profile__c  where id IN:profileIds]);
	}
	/*
		@Description: To get profile and its all order choice by profile Id
		@Param: ProfileId 
	*/
	public static list<Profile__c> getProfileandOrderChoiceBypId(String profileId){
		return new list<Profile__c>([Select Name,type__c,Account__r.Name,Account__c, (Select Id, OwnerId, Name, Order_Choice__c, Profile__c From Profile_Order_Choices__r) From Profile__c  where id =:profileId]);
	}
	/*
	     @Description:-To get all Profile Order Choices  
	*/
	public static list<Profile_Order_Choice__c> getProfileOrder(){
		return new list<Profile_Order_Choice__c>([SELECT Name FROM Profile_Order_Choice__C  ]);
	}
}