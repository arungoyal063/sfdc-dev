public with sharing class ChatterShelfJsController extends BaseCustomActionJsController {
  public override String actionId() {
    return 'shelf';
  }
  
  public override List<String> getActionHtmls(List<String> fiIds) {
    Set<String> shelvableFeedIds = new Set<String>();
    for (UserFeed uf : [SELECT Id FROM UserFeed WHERE Type !='ContentPost' AND Id IN :fiIds LIMIT :fiIds.size()]) {
      shelvableFeedIds.add((uf.Id + '').substring(0,15));
    }
    Set<String> shelvedIds = new Set<String>();
    for (ChatterBookmark__c c : [SELECT feedItemId__c FROM ChatterBookmark__c WHERE feedItemId__c IN :shelvableFeedIds AND OwnerId=:UserInfo.getUserId()]) {
      shelvedIds.add((c.feedItemId__c + '').substring(0,15));
    }
    List<String> labels = new List<String>();
    for (String fiId : fiIds) {
      if (!shelvableFeedIds.contains(fiId)) {
        labels.add('');
      } else if (shelvedIds.contains(fiId)) {
        labels.add(getActionLinkHtml(fiId, 'unshelf', '', 'Unshelf'));
      } else {
        labels.add(getActionLinkHtml(fiId, 'shelf', '', 'Shelf'));
      }
    }
    return labels;
  }
  
  public override void handleAction(String fiId, String parentId, String op, String param) {
    if (op == 'shelf') {
      ChatterBookmark__c cb = new ChatterBookmark__c();
      cb.feedItemId__c = fiId;
      cb.feedItemParentId__c = parentId;
      Insert(cb);
      
      changeActionHtml(fiId, getActionLinkHtml(fiId, 'unshelf', '', 'Unshelf'));
    } else if (op == 'unshelf') {
      Delete([SELECT Id FROM ChatterBookmark__c WHERE FeedItemId__c = :fiId AND OwnerId = :UserInfo.getUserId()]);
      
      changeActionHtml(fiId, getActionLinkHtml(fiId, 'shelf', '', 'Shelf'));
    }
  }
  
}