public with sharing class ChatterStarJsController extends BaseCustomActionJsController {
  
  public override String actionId() {
    return 'star';
  }
  
  public override List<String> getActionHtmls(List<String> fiIds) {
    Set<String> ratableFeedIds = new Set<String>();
    for (UserFeed uf : [SELECT Id FROM UserFeed WHERE Id IN :fiIds AND Type != 'TrackedChange' AND Type !='ContentPost' LIMIT :fiIds.size()]) {
      ratableFeedIds.add((uf.Id + '').substring(0, 15));
    }
    
    Map<String, Integer> counts = new Map<String, Integer>();
    Map<String, Double> stars = new Map<String, Double>();
    for (AggregateResult ar : [SELECT fiId__c, AVG(rating__c), COUNT(rating__c) FROM ChatterStar__c WHERE fiId__c IN :ratableFeedIds GROUP BY fiId__c]) {
      stars.put((String)ar.get('fiId__c'), (Double)ar.get('expr0'));
      counts.put((String)ar.get('fiId__c'), (Integer)ar.get('expr1'));
    }
    
    List<String> labels = new List<String>();
    
    for (String fiId : fiIds) {
      if (ratableFeedIds.contains(fiId)) {
        Double rating = stars.get(fiId);
        if (rating == null) rating = 0;
        
        Integer count = counts.get(fiId);
        if (count == null) count = 0;
        
        labels.add(starsLabel(fiId, rating, count));
      } else {
        labels.add('');
      }
    }
    return labels;
  }
  
  public override void handleAction(String fiId, String parentId, String op, String param) {
    Delete([SELECT Id FROM ChatterStar__c WHERE fiId__c = :fiId AND OwnerId = :UserInfo.getUserId()]);
    ChatterStar__c cc = new ChatterStar__c();
    cc.fiId__c = fiId;
    cc.parentId__c = parentId;
    cc.rating__c = Integer.valueOf(op);
    cc.postDate__c = [SELECT CreatedDate FROM UserFeed WHERE Id=:fiId LIMIT 1][0].CreatedDate;
    Insert(cc);
    
    AggregateResult ar = [SELECT AVG(rating__c), COUNT(rating__c) FROM ChatterStar__c WHERE fiId__c = :fiId GROUP BY fiId__c];
    changeActionHtml(fiId, starsLabel(fiId, (Double)ar.get('expr0'), (Integer)ar.get('expr1')));
    appendReturnScript('CStar.setupStars("' + fiId + '");');
  }
  
  private String starsLabel(String fiId, Double rating, Integer count) {
    rating = ((Double)((rating * 100).round()))/100;
    
    return '&nbsp;&nbsp;<span id="' + fiId + '_star_cstars' + '" class="cstars" style="background-color:#efefef; height:12px; display:inline-block; vertical-align: -2px;">' +
           '<span id="' + fiId + '_star_cstarbar' + '" style="position:absolute;z-index:1;height:12px;">&nbsp;</span>' +
           '<img class="cstar"/><img class="cstar"/><img class="cstar"/><img class="cstar"/><img class="cstar"/>' +
           '</span><input id="' + fiId + '_star_rating' + '" type="hidden" value="' + rating + '"/>' +
           '<span style="font-size:0.92em;"> (' + count + ' votes' + (count>0?', avg ' + rating:'') + ')</span>';
  }
  
}