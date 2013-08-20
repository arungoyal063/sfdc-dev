@isTest
private class ChatterCustomActionsPackageTest {
  
  private class SetupData {
    public User u;
    public List<String> fiIds;
    public String fiIdsString;
  }
  
  static testMethod void testStarControllers() {
    SetupData sd = setup();
    System.runAs(sd.u) {
      // Star JS Controller
      ChatterCustomActionsJsController ccajs = new ChatterCustomActionsJsController();
      ccajs.getActionsConfig();
      
      ChatterStarJsController cstarjs = new ChatterStarJsController();
      System.assertEquals(cstarjs.actionId(), 'star');
      
      cstarJs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>'','parentId'=>'','op'=>'cca_setup','param'=>sd.fiIdsString});
      cstarJs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>sd.fiIds[0],'parentId'=>sd.u.Id,'op'=>'1','param'=>''});
      cstarJs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>'','parentId'=>'','op'=>'cca_draw','param'=>sd.fiIdsString});
      cstarJs.Action();
      cstarjs.getScript();
      
      // Star Controller
      ChatterStarController cstarc = new ChatterStarController();
      cstarc.Init();
      cstarc.Time1();
    }
  }
  
  static testMethod void testStarControllerRanges() {
    SetupData sd = setup();
    System.runAs(sd.u) {
      ChatterStarController cstarc = new ChatterStarController();
      cstarc.Time2();
      cstarc.Time3();
      cstarc.Time4();
      cstarc.getTimeRange();
      system.assertEquals(cstarc.postLists.size(), 3);
    }
  }
  
  static testMethod void testShelfControllers() {
    SetupData sd = setup();
    System.runAs(sd.u) {
      ChatterCustomActionsJsController ccajs = new ChatterCustomActionsJsController();
      ccajs.getActionsConfig();
      
      // Shelf JS Controller
      ChatterShelfJsController cshelfjs = new ChatterShelfJsController();
      System.assertEquals(cshelfjs.actionId(), 'shelf');
      
      cshelfjs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>'','parentId'=>'','op'=>'cca_setup','param'=>sd.fiIdsString});
      cshelfjs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>sd.fiIds[0],'parentId'=>sd.u.Id,'op'=>'shelf','param'=>''});
      cshelfjs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>'','parentId'=>'','op'=>'cca_draw','param'=>sd.fiIdsString});
      cshelfjs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>sd.fiIds[0],'parentId'=>sd.u.Id,'op'=>'unshelf','param'=>''});
      cshelfjs.Action();
      SetupParameters(new Map<String,String>{'fiId'=>sd.fiIds[0],'parentId'=>sd.u.Id,'op'=>'shelf','param'=>''});
      cshelfjs.Action();
      cshelfjs.getScript();
      
      // Shelf Controller
      ChatterShelfController cshelfc = new ChatterShelfController();
      cshelfc.getPosts();
      system.assertEquals(1, cshelfc.getPage());
      cshelfc.Older();
      cshelfc.Latest();
      system.assertEquals(1, cshelfc.getMaxPage());
      system.assertNotEquals(cshelfc.getCB(), null);
      system.assertEquals(true, cshelfc.getLoggedInUser());
      system.assertEquals('Page 1 of 1', cshelfc.getPagination());
      SetupParameters(new Map<String,String>{'user_lkid'=>'000000000000000'});
      cshelfc.Redraw();
      system.assertEquals('Page 1 of 1', cshelfc.getPagination());
      ChatterBookmark__c cb = [SELECT Id FROM ChatterBookmark__c WHERE FeedItemId__c=:sd.fiIds[0]];
      SetupParameters(new Map<String,String>{'param'=>('unshelf_' + cb.Id)});
      cshelfc.Unshelf();
      system.assertEquals(cshelfc.getPagination(), 'No shelved posts');
    }
  }
  
  static private void SetupParameters(Map<String,String> params) {
    for (String k : params.keySet()) {
      ApexPages.CurrentPage().getParameters().put(k, params.get(k));
    }
  }
  
  static private SetupData setup() {
    SetupData sd = new SetupData();
    Profile p = [select id from profile where name='Standard User'];
    sd.u = new User(alias = 'cca', email='testuser@chattercustomactions.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles', username='testuser@chattercustomactions.com');
    Insert(sd.u);
    System.runAs(sd.u) {
      sd.u.currentStatus = 'update';
      Update(sd.u);
      sd.fiIds = new List<String>();
      for (UserFeed uf : [SELECT FeedPost.FeedItemId FROM UserFeed WHERE CreatedById=:sd.u.Id]) {
        sd.fiIds.add((uf.FeedPost.FeedItemId + '').substring(0, 15));
      }
    }
    
    sd.fiIdsString = sd.fiIds[0];
    for (Integer i=1; i<sd.fiIds.size(); i++) {
      sd.fiIdsString += (',' + sd.fiIds[i]);
    }
    
    return sd;
  }
}