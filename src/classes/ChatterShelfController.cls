public with sharing class ChatterShelfController {
  public String userId;
  public ChatterBookmark__c cb;
  public Datetime lastCBDate;
  public Datetime earlierThanLimit;
  public Integer cbCount;
  public Integer page;
  public Integer qlimit = 5;
  
  public class ChatterShelfBookmarkPostPair {
    public ChatterBookmark__c CB { get; set; }
    public UserFeed NF { get; set; }
  }
  
  public List<ChatterShelfBookmarkPostPair> getPosts()  {
    if (userId == null) userId = UserInfo.getUserId();
    if (earlierThanLimit == null) earlierThanLimit = System.Now();
    
    List<String> feedItemIdsList = new List<String>();
    Set<String> feedItemIdsSet = new Set<String>();
    Set<String> feedItemParentIdsSet = new Set<String>();
    Map<String, ChatterBookmark__c> cbMap = new Map<String, ChatterBookmark__c>();
    
    DateTime newLastCBDate;
    
    for (ChatterBookmark__c bookmark : [SELECT Id, CreatedDate, FeedItemId__c, FeedItemParentId__c FROM ChatterBookmark__c WHERE CreatedById=:userId AND CreatedDate<=:earlierThanLimit ORDER BY CreatedDate DESC LIMIT :qlimit]) {
      feedItemIdsList.add(bookmark.FeedItemId__c);
      feedItemIdsSet.add(bookmark.FeedItemId__c);
      feedItemParentIdsSet.add(bookmark.FeedItemParentId__c);
      cbMap.put(bookmark.FeedItemId__c, bookmark);
      lastCBDate = bookmark.createdDate;
    }
    
    Map<String, UserFeed> feedItemIdToNewsFeed = loadNewsFeedByFeedItemId(feedItemIdsSet, feedItemParentIdsSet, qlimit);
    
    List<ChatterShelfBookmarkPostPair> ret = new List<ChatterShelfBookmarkPostPair>();
    for (String s : feedItemIdsList) {
      UserFeed nf = feedItemIdToNewsFeed.get(s);
      ChatterShelfBookmarkPostPair pair = new ChatterShelfBookmarkPostPair();
      pair.CB = cbMap.get(s);
      pair.NF = nf;
      ret.add(pair);
    }
    return ret;
  }
  
  private Map<String, UserFeed> loadNewsFeedByFeedItemId(Set<String> feedItemIdsSet, Set<String> feedItemParentIdsSet, Integer qlimit) {
    Map<String, UserFeed> feedItemIdToNewsFeed = new Map<String, UserFeed>();
    for (UserFeed nf : [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate,
                        ParentId, Parent.Name,
                        FeedPost.Body, FeedPost.Title, FeedPost.LinkUrl,
                        (SELECT Id, FieldName, OldValue, NewValue, FeedItemId FROM FeedTrackedChanges),
                        (SELECT CommentBody, CreatedDate, CreatedById, CreatedBy.FirstName, CreatedBy.LastName FROM FeedComments ORDER BY CreatedDate LIMIT 20)
                        FROM UserFeed
                        WHERE Id IN :feedItemIdsSet
                        LIMIT :qlimit]) {
      String fiId15 = (nf.Id + '').substring(0, 15);
      feedItemIdToNewsFeed.put(fiId15, nf);
      FeedItemIdsSet.remove(fiId15);
    }
    return feedItemIdToNewsFeed;
  }
  
  public String getPagination() {
    if (getMaxPage() == 0) return 'No shelved posts';
    return 'Page ' + getPage() + ' of ' + getMaxPage();
  }
  
  public Integer getCBCount() {
    if (cbCount == null) {
      cbCount = [SELECT COUNT() FROM ChatterBookmark__c WHERE CreatedById=:userId];
    }
    return cbCount;
  }
  
  public ChatterBookmark__c getCB() {
    cb = new ChatterBookmark__c();
    cb.OwnerId = UserInfo.getUserId();
    return cb;
  }
  
  public Integer getPage() {
    if (page == null) page = 1;
    return page;
  }
  
  public Integer getMaxPage() {
    return (getCBCount() + qLimit - 1) / qLimit;
  }
  
  public void Latest() {
    earlierThanLimit = null;
    page = 1;
  }
  
  public void Older() {
    earlierThanLimit = lastCBDate;
    page++;
  }
  
  public void Redraw() {
    Map<String, String> params = ApexPages.currentPage().getParameters();
    for (String key : params.keySet()) {
      if (key.endsWith('user_lkid')) {
        userId = params.get(key);
        if (userId == null || userId == '000000000000000' || userId == '') userId = UserInfo.getUserId();
        break;
      }
    }
    page = 1;
    earlierThanLimit = null;
    cbCount = null;
  }
  
  public void Unshelf() {
    cbCount = null;
    
    Map<String, String> params = ApexPages.currentPage().getParameters();
    for (String k : params.keySet()) {
      String val = params.get(k);
      if (val.startsWith('unshelf_')) {
        val = val.replace('unshelf_','');
        Delete([SELECT Id FROM ChatterBookmark__c WHERE Id=:val]);
        break;
      }
    }
  }
  
  public Boolean getLoggedInUser() {
    return UserInfo.getUserId().startsWith(userId);
  }
}