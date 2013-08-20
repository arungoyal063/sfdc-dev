public abstract class BaseCustomActionJsController {
  
  protected String returnScript;
  protected String ERROR = 'alert("Error!");';
  
  ///// Abstract and virtual methods /////
  
  public abstract String actionId();
  public abstract List<String> getActionHtmls(List<String> fiIds);
  public abstract void handleAction(String fiId, String parentId, String op, String param);
  
  ///// Utility methods /////
  
  // Change the HTML of an action div
  protected void changeActionHtml(String fiId, String html) {
    returnScript += 'document.getElementById("' + fiId + '_' + actionId() + '_span").innerHTML = "' + html.replace('"', '\\"') + '";';
  }
  
  // Get HTML for an action link
  protected String getActionLinkHtml(String fiId, String op, String param, String label) {
      return '<a id="' + fiId + '_' + actionId() + '_a" href="javascript:void(0);" class="feeditemactionlink" onclick="CCA.action(\'' + actionId() + '\',\'' + fiId + '\',\'' + op + '\',\'' + param + '\');">' + label + '</a>';
  }
  
  protected void appendReturnScript(String script) {
    returnScript += script;
  }
  
  ///// Framework methods /////
  
  public void Action() {
    // XSRF protection from anything outside salesforce.com and force.com
    returnScript = 'var splits = ("" + document.location).split("/", 3)[2].split(".");' +
      'if (!(splits[splits.length-1] == "com" && (splits[splits.length-2] == "salesforce" || splits[splits.length-2] == "force"))) { alert("Invalid domain!"); while(true) {} };';
    
    Map<String, String> params = ApexPages.currentPage().getParameters();
    
    String fiIdParam = params.get('fiId');
    String parentIdParam = params.get('parentId');
    String opParam = params.get('op');
    String paramParam = params.get('param');
    if (fiIdParam == null || parentIdParam == null || opParam == null || paramParam == null) {returnScript = 'alert("error");'; return;}
    
    if (opParam == 'cca_setup' || opParam == 'cca_draw') {
      draw = true;
      if (opParam == 'cca_setup') setup = true;
      
      List<String> fiIds = paramParam.split(',');
      List<String> labels = getActionHtmls(fiIds);
      for (Integer i=0; i<fiIds.size(); i++) {
        changeActionHtml(fiIds[i], labels[i]);
      }
    } else {
      handleAction(fiIdParam, parentIdParam, opParam, paramParam);
    }
  }
  
  public Boolean setup { get; set; }
  public Boolean draw { get; set; }
  
  public String getScript() {
    return returnScript;
  }
  
}