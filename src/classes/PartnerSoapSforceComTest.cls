@isTest
private class PartnerSoapSforceComTest {

   /**
     * Dummy Metadata API web service mock class 
   **/
    private class WebServiceMockImplTest implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            System.debug('Requrst ::' + request);
            System.debug('responseType ::' + responseType);
            if(request instanceof partnerSoapSforceCom.login_element ) {
               partnerSoapSforceCom.GetUserInfoResult  userInfoResult = new partnerSoapSforceCom.GetUserInfoResult();
               partnerSoapSforceCom.LoginResult result = new partnerSoapSforceCom.LoginResult();
               result.userInfo = userInfoResult;
               partnerSoapSforceCom.loginResponse_element soapResponse = new partnerSoapSforceCom.loginResponse_element();
               soapResponse.result = result;
               response.put('response_x', soapResponse);
            } 
            
            
           else if(request instanceof partnerSoapSforceCom.convertLead_element){
               partnerSoapSforceCom.convertLeadResponse_element soapResponse  = new partnerSoapSforceCom.convertLeadResponse_element();    
               soapResponse.result = new List<partnerSoapSforceCom.LeadConvertResult>{ new partnerSoapSforceCom.LeadConvertResult()}; 
               response.put('response_x', soapResponse);
           } 
           
           else if(request instanceof partnerSoapSforceCom.describeAvailableQuickActions_element) {
               partnerSoapSforceCom.describeAvailableQuickActionsResponse_element soapResponse = new  partnerSoapSforceCom.describeAvailableQuickActionsResponse_element();
               soapResponse.result = new List<partnerSoapSforceCom.DescribeAvailableQuickActionResult>{ new partnerSoapSforceCom.DescribeAvailableQuickActionResult()};
               response.put('response_x', soapResponse);
           }
           
           else if(request instanceof partnerSoapSforceCom.describeGlobal_element){
               partnerSoapSforceCom.describeGlobalResponse_element soapResponse = new  partnerSoapSforceCom.describeGlobalResponse_element();
               soapResponse.result  = new partnerSoapSforceCom.DescribeGlobalResult();
               response.put('response_x', soapResponse);
           }
           
           else if(request instanceof partnerSoapSforceCom.emptyRecycleBin_element){               
               partnerSoapSforceCom.emptyRecycleBinResponse_element soapResponse = new partnerSoapSforceCom.emptyRecycleBinResponse_element();
               soapResponse.result = new List<partnerSoapSforceCom.EmptyRecycleBinResult>{new partnerSoapSforceCom.EmptyRecycleBinResult()};
               response.put('response_x', soapResponse);
           }
           
           else if(request instanceof partnerSoapSforceCom.process_element){               
               partnerSoapSforceCom.processResponse_element soapResponse = new partnerSoapSforceCom.processResponse_element();
               soapResponse.result = new List<partnerSoapSforceCom.ProcessResult>{new partnerSoapSforceCom.ProcessResult()};
               response.put('response_x', soapResponse);
           }
           
           else if(request instanceof partnerSoapSforceCom.invalidateSessions_element){               
               partnerSoapSforceCom.invalidateSessionsResponse_element soapResponse = new partnerSoapSforceCom.invalidateSessionsResponse_element();
               response.put('response_x', soapResponse);
           }
          
           else if(request instanceof partnerSoapSforceCom.getServerTimestamp_element){               
               partnerSoapSforceCom.getServerTimestampResponse_element soapResponse = new partnerSoapSforceCom.getServerTimestampResponse_element();
               response.put('response_x', soapResponse);
           }
            
           else if(request instanceof partnerSoapSforceCom.sendEmailMessage_element){               
               partnerSoapSforceCom.sendEmailMessageResponse_element soapResponse = new partnerSoapSforceCom.sendEmailMessageResponse_element();
               response.put('response_x', soapResponse);
           }
           
           
           
        }
    } 
    
   static testmethod void partnerSoapSforceCom_unitTest() {
       Test.setMock(WebServiceMock.class, new WebServiceMockImplTest());    
       partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
       partnerSoapSforceCom.LoginResult loginResult = sp.login('test@test.com', 'test1234'); 
       
       partnerSoapSforceCom.LeadConvert leadConvertObj = new partnerSoapSforceCom.LeadConvert();
       List<partnerSoapSforceCom.LeadConvertResult> convertLeadList = sp.convertLead(new List<partnerSoapSforceCom.LeadConvert> {leadConvertObj});
       sp.describeAvailableQuickActions('test');
       sp.describeGlobal();       
       sp.emptyRecycleBin(new List<String>{'test'});
       sp.process(new List<partnerSoapSforceCom.ProcessRequest> { new partnerSoapSforceCom.ProcessRequest()});
       sp.logout();
       sp.invalidateSessions(new List<String>{'test'});
       sp.getServerTimestamp();
       sp.sendEmailMessage(new List<String>{'test'});
       
       partnerSoapSforceCom.getUserInfo_element infoObj = new partnerSoapSforceCom.getUserInfo_element();
       partnerSoapSforceCom.DescribeTab tabObj = new partnerSoapSforceCom.DescribeTab();
       partnerSoapSforceCom.describeSearchScopeOrder_element searchObj = new partnerSoapSforceCom.describeSearchScopeOrder_element();
       partnerSoapSforceCom.MergeRequest mergeObj = new partnerSoapSforceCom.MergeRequest();
       partnerSoapSforceCom.resetPasswordResponse_element resObj = new partnerSoapSforceCom.resetPasswordResponse_element();
       partnerSoapSforceCom.sendEmailMessageResponse_element mailObj = new partnerSoapSforceCom.sendEmailMessageResponse_element();
       partnerSoapSforceCom.DebuggingHeader_element debugObj = new partnerSoapSforceCom.DebuggingHeader_element();
       partnerSoapSforceCom.SetPasswordResult passresultObj = new partnerSoapSforceCom.SetPasswordResult();
       partnerSoapSforceCom.Error errorObj = new partnerSoapSforceCom.Error(); 
       partnerSoapSforceCom.resetPassword_element resetObj = new partnerSoapSforceCom.resetPassword_element();
       
       
       partnerSoapSforceCom.DescribeLayoutButton layoutObj = new partnerSoapSforceCom.DescribeLayoutButton();
       partnerSoapSforceCom.describeDataCategoryGroups_element obj1 = new partnerSoapSforceCom.describeDataCategoryGroups_element();
       partnerSoapSforceCom.SendEmailError obj2 = new partnerSoapSforceCom.SendEmailError();
       partnerSoapSforceCom.DescribeLayoutItem obj3 = new partnerSoapSforceCom.DescribeLayoutItem();
       partnerSoapSforceCom.AllowFieldTruncationHeader_element obj4 = new partnerSoapSforceCom.AllowFieldTruncationHeader_element();
       partnerSoapSforceCom.deleteResponse_element obj7 = new  partnerSoapSforceCom.deleteResponse_element();
       partnerSoapSforceCom.describeSObjects_element test4 = new partnerSoapSforceCom.describeSObjects_element();
       partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element test5 = new partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element();
       partnerSoapSforceCom.update_element test6= new partnerSoapSforceCom.update_element();
      
       partnerSoapSforceCom.search_element serchObj = new  partnerSoapSforceCom.search_element();
      
       partnerSoapSforceCom.MergeResult testObj1 = new partnerSoapSforceCom.MergeResult();
       partnerSoapSforceCom.describeQuickActions_element testObj2 = new  partnerSoapSforceCom.describeQuickActions_element();
       partnerSoapSforceCom.RelatedListSort testObj4 = new  partnerSoapSforceCom.RelatedListSort();
       partnerSoapSforceCom.describeSObject_element testObj3 = new partnerSoapSforceCom.describeSObject_element();
       partnerSoapSforceCom.invalidateSessionsResponse_element testObj5 = new partnerSoapSforceCom.invalidateSessionsResponse_element();
       partnerSoapSforceCom.LoginScopeHeader_element testObj6 = new partnerSoapSforceCom.LoginScopeHeader_element();
       partnerSoapSforceCom.EmailFileAttachment testObject1= new partnerSoapSforceCom.EmailFileAttachment();
       partnerSoapSforceCom.delete_element testObj9= new partnerSoapSforceCom.delete_element();
       partnerSoapSforceCom.DescribeQuickActionListResult testObj7= new partnerSoapSforceCom.DescribeQuickActionListResult();
       partnerSoapSforceCom.sendEmail_element testObj8= new partnerSoapSforceCom.sendEmail_element(); 
       partnerSoapSforceCom.DescribeLayoutButtonSection test1 = new partnerSoapSforceCom.DescribeLayoutButtonSection();
       partnerSoapSforceCom.updateResponse_element test2  = new partnerSoapSforceCom.updateResponse_element();
       partnerSoapSforceCom.queryAll_element test3 = new partnerSoapSforceCom.queryAll_element();

   }
   
   
    static testmethod void partnerSoapSforceCom_unitTest2() {
        partnerSoapSforceCom.DescribeSoftphoneLayoutItem test1 = new partnerSoapSforceCom.DescribeSoftphoneLayoutItem(); 
        partnerSoapSforceCom.logout_element test2 = new partnerSoapSforceCom.logout_element();
        partnerSoapSforceCom.DescribeSoftphoneLayoutSection test3 = new partnerSoapSforceCom.DescribeSoftphoneLayoutSection();
        partnerSoapSforceCom.describeDataCategoryGroupsResponse_element test4 = new  partnerSoapSforceCom.describeDataCategoryGroupsResponse_element();
        partnerSoapSforceCom.describeQuickActionsResponse_element test5 = new partnerSoapSforceCom.describeQuickActionsResponse_element();
        partnerSoapSforceCom.PerformQuickActionResult test6 = new partnerSoapSforceCom.PerformQuickActionResult();
        partnerSoapSforceCom.ResetPasswordResult test7 = new partnerSoapSforceCom.ResetPasswordResult();
        partnerSoapSforceCom.merge_element test8 = new partnerSoapSforceCom.merge_element();
        partnerSoapSforceCom.describeGlobal_element test9 = new partnerSoapSforceCom.describeGlobal_element();
        partnerSoapSforceCom.queryResponse_element test10 = new partnerSoapSforceCom.queryResponse_element();
        partnerSoapSforceCom.DescribeColumn test11 = new partnerSoapSforceCom.DescribeColumn();
        partnerSoapSforceCom.describeDataCategoryGroupStructures_element test12 = new partnerSoapSforceCom.describeDataCategoryGroupStructures_element();
        partnerSoapSforceCom.Email test13 = new  partnerSoapSforceCom.Email();
        partnerSoapSforceCom.describeSoftphoneLayout_element test14= new partnerSoapSforceCom.describeSoftphoneLayout_element();
        partnerSoapSforceCom.getServerTimestamp_element test15 =  new partnerSoapSforceCom.getServerTimestamp_element();
        partnerSoapSforceCom.ChildRelationship test16 = new partnerSoapSforceCom.ChildRelationship();
        partnerSoapSforceCom.DescribeLayoutComponent test17 = new partnerSoapSforceCom.DescribeLayoutComponent();
        partnerSoapSforceCom.QueryResult test18 = new partnerSoapSforceCom.QueryResult();
        partnerSoapSforceCom.CallOptions_element test19 = new partnerSoapSforceCom.CallOptions_element();
        partnerSoapSforceCom.sendEmailMessage_element test20 = new partnerSoapSforceCom.sendEmailMessage_element();
        partnerSoapSforceCom.MruHeader_element test21= new partnerSoapSforceCom.MruHeader_element();
        partnerSoapSforceCom.DescribeSearchScopeOrderResult test22 = new partnerSoapSforceCom.DescribeSearchScopeOrderResult();
        partnerSoapSforceCom.ProcessWorkitemRequest test23 = new partnerSoapSforceCom.ProcessWorkitemRequest();
        partnerSoapSforceCom.SessionHeader_element test24 = new partnerSoapSforceCom.SessionHeader_element();
        partnerSoapSforceCom.AllOrNoneHeader_element test25 = new  partnerSoapSforceCom.AllOrNoneHeader_element();
        partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult test26 = new  partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult();
        partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField test27 = new  partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField();
        partnerSoapSforceCom.describeTabs_element test29 = new  partnerSoapSforceCom.describeTabs_element();
        partnerSoapSforceCom.SaveResult test30 = new partnerSoapSforceCom.SaveResult();
        partnerSoapSforceCom.DisableFeedTrackingHeader_element test31 = new partnerSoapSforceCom.DisableFeedTrackingHeader_element();
        partnerSoapSforceCom.retrieve_element test32 = new partnerSoapSforceCom.retrieve_element(); 
        partnerSoapSforceCom.describeSearchLayoutsResponse_element test33 = new partnerSoapSforceCom.describeSearchLayoutsResponse_element();
        partnerSoapSforceCom.GetServerTimestampResult test34 = new partnerSoapSforceCom.GetServerTimestampResult ();
        partnerSoapSforceCom.RelatedList test35 = new partnerSoapSforceCom.RelatedList();
        partnerSoapSforceCom.describeSearchScopeOrderResponse_element test36 = new partnerSoapSforceCom.describeSearchScopeOrderResponse_element();
        partnerSoapSforceCom.retrieveResponse_element test37 = new partnerSoapSforceCom.retrieveResponse_element();
        partnerSoapSforceCom.queryAllResponse_element test38 = new partnerSoapSforceCom.queryAllResponse_element();     
        partnerSoapSforceCom.createResponse_element test39 = new partnerSoapSforceCom.createResponse_element();
        partnerSoapSforceCom.ProcessSubmitRequest test40 = new partnerSoapSforceCom.ProcessSubmitRequest ();
        partnerSoapSforceCom.create_element test41 = new  partnerSoapSforceCom.create_element();
        partnerSoapSforceCom.invalidateSessions_element test42 = new partnerSoapSforceCom.invalidateSessions_element();
        partnerSoapSforceCom.DescribeSearchLayoutResult test43 = new partnerSoapSforceCom.DescribeSearchLayoutResult();
        partnerSoapSforceCom.DescribeQuickActionListItemResult test45 = new partnerSoapSforceCom.DescribeQuickActionListItemResult();
        partnerSoapSforceCom.LocaleOptions_element test46 = new partnerSoapSforceCom.LocaleOptions_element();
        partnerSoapSforceCom.DescribeSoftphoneScreenPopOption test47 = new partnerSoapSforceCom.DescribeSoftphoneScreenPopOption();
        partnerSoapSforceCom.PackageVersion  test48  = new partnerSoapSforceCom.PackageVersion();
        partnerSoapSforceCom.DataCategory test49 = new partnerSoapSforceCom.DataCategory();
        partnerSoapSforceCom.DescribeGlobalResult test50 = new partnerSoapSforceCom.DescribeGlobalResult(); 
        partnerSoapSforceCom.AssignmentRuleHeader_element test51 = new partnerSoapSforceCom.AssignmentRuleHeader_element();
        partnerSoapSforceCom.describeSearchLayouts_element test52 = new partnerSoapSforceCom.describeSearchLayouts_element();
        partnerSoapSforceCom.PackageVersionHeader_element test53 = new partnerSoapSforceCom.PackageVersionHeader_element();
        partnerSoapSforceCom.UserTerritoryDeleteHeader_element test54 = new partnerSoapSforceCom.UserTerritoryDeleteHeader_element();
        partnerSoapSforceCom.DebuggingInfo_element test55 = new partnerSoapSforceCom.DebuggingInfo_element();
        partnerSoapSforceCom.describeSObjectResponse_element test56 = new partnerSoapSforceCom.describeSObjectResponse_element();
        partnerSoapSforceCom.undelete_element test57 = new partnerSoapSforceCom.undelete_element();          
        partnerSoapSforceCom.RelatedListColumn  objtest1 = new partnerSoapSforceCom.RelatedListColumn();
        partnerSoapSforceCom.UpsertResult test58 = new partnerSoapSforceCom.UpsertResult ();
        partnerSoapSforceCom.setPasswordResponse_element test59 = new partnerSoapSforceCom.setPasswordResponse_element (); 
        partnerSoapSforceCom.DescribeSObjectResult test60= new partnerSoapSforceCom.DescribeSObjectResult();
        
    }
    
    
    static testmethod void partnerSoapSforceCom_unitTest3() {
        partnerSoapSforceCom soapObj = new partnerSoapSforceCom();
               
        partnerSoapSforceCom.logoutResponse_element test1 = new partnerSoapSforceCom.logoutResponse_element();
        partnerSoapSforceCom.InvalidateSessionsResult test2 = new partnerSoapSforceCom.InvalidateSessionsResult();
        partnerSoapSforceCom.describeLayout_element test3 = new  partnerSoapSforceCom.describeLayout_element ();
        partnerSoapSforceCom.RecordTypeMapping test4 = new  partnerSoapSforceCom.RecordTypeMapping();
        partnerSoapSforceCom.PicklistEntry test5  = new partnerSoapSforceCom.PicklistEntry();
        partnerSoapSforceCom.SingleEmailMessage  test6 = new partnerSoapSforceCom.SingleEmailMessage();
        partnerSoapSforceCom.login_element test7= new  partnerSoapSforceCom.login_element();      
        partnerSoapSforceCom.MassEmailMessage test87 = new partnerSoapSforceCom.MassEmailMessage();
         
        partnerSoapSforceCom.upsertResponse_element test55 = new partnerSoapSforceCom.upsertResponse_element();
        partnerSoapSforceCom.Field test75 =new  partnerSoapSforceCom.Field(); 
   
         partnerSoapSforceCom.describeSObjectsResponse_element test54= new partnerSoapSforceCom.describeSObjectsResponse_element();      
         partnerSoapSforceCom.getUserInfoResponse_element  test50 = new  partnerSoapSforceCom.getUserInfoResponse_element();
         partnerSoapSforceCom.mergeResponse_element test40 = new partnerSoapSforceCom.mergeResponse_element();
         partnerSoapSforceCom.PicklistForRecordType test25 = new partnerSoapSforceCom.PicklistForRecordType(); 
         partnerSoapSforceCom.getUpdated_element test35 = new  partnerSoapSforceCom.getUpdated_element();  
         partnerSoapSforceCom.DescribeTabSetResult test20 = new partnerSoapSforceCom.DescribeTabSetResult();
         
         partnerSoapSforceCom.DescribeGlobalSObjectResult test41 = new partnerSoapSforceCom.DescribeGlobalSObjectResult();
         partnerSoapSforceCom.DescribeQuickActionResult test42 = new partnerSoapSforceCom.DescribeQuickActionResult (); 
         partnerSoapSforceCom.SendEmailResult  test43 = new partnerSoapSforceCom.SendEmailResult();
        
         partnerSoapSforceCom.DescribeDataCategoryGroupResult test45 = new  partnerSoapSforceCom.DescribeDataCategoryGroupResult();
         partnerSoapSforceCom.StreamingEnabledHeader_element test46 = new partnerSoapSforceCom.StreamingEnabledHeader_element();
         partnerSoapSforceCom.query_element test47 = new partnerSoapSforceCom.query_element();
         partnerSoapSforceCom.getUpdatedResponse_element test48 = new  partnerSoapSforceCom.getUpdatedResponse_element();
         partnerSoapSforceCom.getServerTimestampResponse_element test49  = new partnerSoapSforceCom.getServerTimestampResponse_element();
         partnerSoapSforceCom.describeTabsResponse_element test51 = new partnerSoapSforceCom.describeTabsResponse_element();
         partnerSoapSforceCom.QueryOptions_element test52 = new partnerSoapSforceCom.QueryOptions_element();
         partnerSoapSforceCom.DeleteResult test53 = new partnerSoapSforceCom.DeleteResult(); 
         partnerSoapSforceCom.GetUpdatedResult test59 = new partnerSoapSforceCom.GetUpdatedResult();
         partnerSoapSforceCom.SearchRecord test58 = new partnerSoapSforceCom.SearchRecord();
         partnerSoapSforceCom.getDeleted_element test62 = new partnerSoapSforceCom.getDeleted_element();
         partnerSoapSforceCom.sendEmailResponse_element test61 = new partnerSoapSforceCom.sendEmailResponse_element();
         
         faultPartnerSoapSforceCom faultObj = new faultPartnerSoapSforceCom();
        faultPartnerSoapSforceCom.ApiFault  obj1 = new faultPartnerSoapSforceCom.ApiFault();
        faultPartnerSoapSforceCom.InvalidSObjectFault obj2 = new faultPartnerSoapSforceCom.InvalidSObjectFault();
        faultPartnerSoapSforceCom.MalformedQueryFault obj3 = new faultPartnerSoapSforceCom.MalformedQueryFault();
        faultPartnerSoapSforceCom.InvalidIdFault obj4 = new faultPartnerSoapSforceCom.InvalidIdFault();
        faultPartnerSoapSforceCom.InvalidFieldFault obj5 = new faultPartnerSoapSforceCom.InvalidFieldFault();
        faultPartnerSoapSforceCom.MalformedSearchFault obj6 =  new faultPartnerSoapSforceCom.MalformedSearchFault();
        faultPartnerSoapSforceCom.ApiQueryFault obj7 = new faultPartnerSoapSforceCom.ApiQueryFault();
        faultPartnerSoapSforceCom.UnexpectedErrorFault obj8 = new faultPartnerSoapSforceCom.UnexpectedErrorFault();
        faultPartnerSoapSforceCom.LoginFault obj9 = new faultPartnerSoapSforceCom.LoginFault();
        faultPartnerSoapSforceCom.InvalidQueryLocatorFault obj10 = new faultPartnerSoapSforceCom.InvalidQueryLocatorFault();
        faultPartnerSoapSforceCom.InvalidNewPasswordFault obj11 = new faultPartnerSoapSforceCom.InvalidNewPasswordFault();

    }
   
    
}