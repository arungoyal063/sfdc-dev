public with sharing class ChatterStarController {
  private Integer timeRange;
  public List<RatedPostList> postLists {get;set;}
  
  public class RatedPost {
    public Double rating {get;set;}
    public Integer votes {get;set;}
    public String fiId {get;set;}
    public UserFeed uf {get;set;}
  }
  
  public class RatedPostList {
    public String title {get;set;}
    public List<RatedPost> ratedPosts {get;set;}
    public String prefix {get;set;}
    
    public RatedPostList(String title, List<RatedPost> ratedPosts, String prefix) {
      this.title = title;
      this.ratedPosts = ratedPosts;
      this.prefix = prefix;
    }
  }
  
  public void Init() {
    if (timeRange == null) timeRange = 2;
    
    postLists = loadPostLists();
  }
  
  public List<RatedPostList> loadPostLists() {
    return new List<RatedPostList> {
      new RatedPostList('Highest Rated', getFeeds(true, false), 'h'),
      new RatedPostList('Lowest Rated', getFeeds(false, false), 'l'),
      new RatedPostList('Most Votes', getFeeds(true, true), 'm')
    };
  }
  
  public Integer getTimeRange() {
    return timeRange;
  }
  
  public void Time1() { timeRange = 1; Init(); }
  public void Time2() { timeRange = 2; Init(); }
  public void Time3() { timeRange = 3; Init(); }
  public void Time4() { timeRange = 4; Init(); }
  
  public List<RatedPost> getFeeds(Boolean best, Boolean most) {
    String queryWhere = '';
    if (timeRange < 4) {
      queryWhere = ' WHERE postDate__c>';
      if (timeRange == 1) queryWhere += 'YESTERDAY';
      else if (timeRange == 2) queryWhere += 'LAST_WEEK';
      else if (timeRange == 3) queryWhere += 'LAST_MONTH';
    }
    String orderBy = ' ORDER BY ';
    if (most) {
      orderBy += 'COUNT(rating__c) DESC, AVG(rating__c)' + (best?' DESC':'') + ', MIN(postDate__c)';
    } else {
      orderBy += 'AVG(rating__c)' + (best?' DESC':'') + ', COUNT(rating__c) DESC, MIN(postDate__c)';
    }
    String query = 'SELECT fiId__c, AVG(rating__c), COUNT(rating__c) FROM ChatterStar__c' + queryWhere + ' GROUP BY fiId__c' + orderBy + ' LIMIT 5';
    List<RatedPost> rps = new List<RatedPost>();
    Map<String, RatedPost> fiIdToRatedPostMap = new Map<String, RatedPost>();
    for (AggregateResult ar : Database.query(query)) {
      RatedPost rp = new RatedPost();
      rp.fiId = (String)ar.get('fiId__c');
      rp.rating = ((Double)(((Double)ar.get('expr0') * 100).round()))/100;
      rp.votes = (Integer)ar.get('expr1');
      rps.add(rp);
      fiIdToRatedPostMap.put(rp.fiId, rp);
    }
    if (rps.size() > 0) {
      for (UserFeed uf : [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate,
                          ParentId, Parent.Name, FeedPost.Body, FeedPost.LinkUrl, FeedPost.Title,
                          (SELECT CommentBody, CreatedDate, CreatedById, CreatedBy.FirstName, CreatedBy.LastName  FROM FeedComments ORDER BY CreatedDate LIMIT 20)
                          FROM UserFeed WHERE Id IN :fiIdToRatedPostMap.keySet() LIMIT 5]) {
        fiIdToRatedPostMap.get((uf.Id + '').substring(0, 15)).uf = uf;
      }
    }
    return rps;
  }
}