<!-- We can locate this div with the script below, traverse up the DOMand then hide the entire sidebar component. -->
<div id="sidebarComponentLocator">&nbsp; &nbsp; If you see this, something is broke with Dynamic Button functionality.</div>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js" type="text/javascript"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript"></script>
<script src="https://ajax.googleapis.com/ajax/libs/ext-core/3.1.0/ext-core.js" type="text/javascript"></script>
<!--<script src="{!URLFOR($Resource.connectomeeting_resources, 'styles.css')}" type="text/javascript"></script>-->
<!--<style>
	.requiredLoaderBG{ 
	background-color: gray; 
	opacity:0.5; 
	filter:alpha(opacity=50); 
	background:url(!{$Resource.ajaxLoadGif}) ;  
	position: fixed;   
	z-index: 1; 
	} 
</style>-->
<script type="text/javascript">
 function showResult(btn) {        
		Ext.example.msg('Button Click', 'You clicked the {0} button', btn);    
}    
function showAlert() {        /*alert('YO, YO!');*/        
	Ext.get('mb4').on('click', function(e) {
			Ext.MessageBox.show({ title: 'Save Changes?',
								msg: 'You are closing a tab that has unsaved changes. <br />Would you like to save your changes?',
								buttons: Ext.MessageBox.YESNOCANCEL,
								fn: showResult,
								animateTarget: 'mb4',
								icon: Ext.MessageBox.QUESTION 
							});        
						});    
}
function showResultText(btn, text) {
	Ext.example.msg('Button Click', 'You clicked the {0} button and entered the text "{1}".', btn, text);    
} /*Immediately create a unique alias for this version of jQuery to prevent conflicts with other js libraries*/    
var j$ = jQuery.noConflict();    
/*var objectPefix = window.location.href.substring(window.location.href.indexOf('.com/') + 5, window.location.href.indexOf('.com/') + 8);    */
/*alert(objectPefix);*/    
/*var result = sforce.connection.query("Select Id, Name, CreatedDate from Account limit 1");    
var records = result.getArray("records");   */ /*alert(records[0].CreatedDate); Execute this code block once page DOM has fully loaded*/    
j$(document).ready(function() { 
	try{ 
		/*alert('loading listener'); 
		Hide the sidebar last as this is lowest priority. First priority is show/hiding the buttons. Find the sidebarComponentLocator, then find parent div with class 'sidebarModule' and the hide it*/ 

		j$("#sidebarComponentLocator").closest(".sidebarModule").hide().prev().hide();
		var n; /*j$("input[name='newEvent']").hide();*/ 
		/*j$("input[name='00Nd0000006i5Ty']").hide();*/
		var lblCreateGTMInvite = j$("label:contains('Create Goto Meeting Invite')");
		if (lblCreateGTMInvite != null && lblCreateGTMInvite.attr('for') != null) {
			var gtmchkbxId = lblCreateGTMInvite.attr('for');
			console.log("input[name='" + gtmchkbxId + "']");
			var gtmInput = "input[name='" + gtmchkbxId + "']";
			j$(gtmInput).click(function() { 
				/*alert('YO B!');*/ showAlert(); 
				var startDate = j$("#StartDateTime").val(); 
				var startTime = j$("#StartDateTime_time").val(); 
				var start = startDate + ' ' + startTime; 
				/*alert(start);*/ 
				var endDate = j$("#EndDateTime").val(); 
				var endTime = j$("#EndDateTime_time").val(); 
				var end = endDate + ' ' + endTime; 
				/*alert(end);*/ 
				var meetingtype = 'Scheduled'; 
				var isRecurrence = j$("#IsRecurrence").val(); 
				if (isRecurrence) { meetingtype = 'Recurring'; } /*alert(meetingtype);*/ 
				var subject = j$("#evt5").val(); /*alert(subject);*/ 
				var passwordrequired = 'false'; /*alert(passwordrequired);*/  
				var userId = sforce.connection.getUserInfo().userId;/*'005i0000000ZzEw';*/ /*alert('response: ' + userId);*/ 
				if(j$(this).is(':checked')){ 
					j$('body').addClass('requiredLoaderBG'); 
					var isUserHaveGTMAccount = sforce.apex.execute('GTMHelper', 'isUserHaveGTMAccount', { userId:userId }); 
					if(isUserHaveGTMAccount == 'false'){
					 if(confirm("You do not have the GTM Account, First of all you need to create a GTM Account Please press 'Ok' if want to create.")){ 
					 	window.location = "/apex/GTMConsole"; 
					 } 
					} else { 
						j$(this).parent().append("<strong class='gtmMsg12' style='color:green'>&nbsp;Please wait Creating Goto Meeting Details....</strong>"); 
						setTimeout(function() { 
							try{ 
								var result = sforce.apex.execute('GTMHelper', 'createRemoteMeeting', { startDate: start, endDate: end, meetingType: meetingtype, subject: subject, assignedTo: userId }); 
								console.log(result); 
								var result1 = JSON.parse(result); 
								var meeting = 'Goto Meeting Details:\nJoin URL:'+result1.joinURL+ '\nMeeting id:' + result1.meetingId + '\nConference Call Info: ' + result1.conferenceCallInfo; 
								j$('#evt6').val(j$('#evt6').val().trim()+'\n||*~~~~~~~~~~~~~~~~~~~~~~||\n'+meeting+'\n||~~~~~~~~~~~~~~~~~~~~~~*||\n'); 
								j$('body').removeClass('requiredLoaderBG'); 
								j$('.gtmMsg12').remove(); 
							} catch(e) { 
								j$('body').removeClass('requiredLoaderBG'); 
								j$('.gtmMsg123').remove(); j$('.gtmMsg12').remove(); 
								erorRepting('Error Occured to create GTM, Details:' +e); 
								alert('Error:'+e); 
							} 
						}, 100); 
					} 
				} else {  
					j$('body').addClass('requiredLoaderBG'); 
					j$(this).parent().append("<strong class='gtmMsg123' style='color:green'>&nbsp;Please wait Deleting Goto Meeting Details....</strong>"); 
					var gtm12 = j$('#evt6').val();   
					var subStringTxt = gtm12.substr(gtm12.indexOf('||*'),gtm12.indexOf('*||')-gtm12.indexOf('||*~')+3);  
					var mtId = subStringTxt.substr(subStringTxt.indexOf('Meeting id:')+11,10); 
					setTimeout(function() { 
						try{ 
							sforce.apex.execute('GTMHelper', 'deleteRemoteMeeting', { meetingId: mtId, assignedTo: userId }); 
							j$('#evt6').val(gtm12.replace(subStringTxt,'')); 
							j$('body').removeClass('requiredLoaderBG'); 
							j$('.gtmMsg123').remove(); 
						} catch(e) { 
							j$('body').removeClass('requiredLoaderBG'); 
							j$('.gtmMsg123').remove(); j$('.gtmMsg12').remove(); 
							erorRepting('Error Occured to create GTM, Details:' +e); 
							alert('Error:'+e); 
						} }, 500); 
				} 
				/*j$('body').removeClass('requiredLoaderBG'); */ 
			});
	} else {
		console.log('element not found');
	} 
	} catch(e) { 
		j$('body').removeClass('requiredLoaderBG'); 
		j$('.gtmMsg123').remove(); 
		j$('.gtmMsg12').remove(); 
		erorRepting('Error Occured to create GTM. \nDetails: ' +e); alert(e); 
	}    
}); 
	/*Email to the USer to report Error!*/ 
function erorRepting(body){
 	try{
  		sforce.apex.execute('GTMHelper', 'errorReporting', { Body: body }); 
	} catch(ex) { 
		alert(ex); 
	} 
}
</script>
&nbsp; &nbsp;<div id="dialog" title="Basic dialog">&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; <p>&nbsp; &nbsp; &nbsp; &nbsp; This is an animated dialog which is useful for displaying information.&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; The dialog window can be moved, resized and closed with the 'x'&nbsp; &nbsp; &nbsp; &nbsp; icon.&nbsp; &nbsp; </p></div>&nbsp; &nbsp;<p>&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; <b>&nbsp; &nbsp; &nbsp; &nbsp; Yes/No/Cancel&nbsp; &nbsp; </b>&nbsp; &nbsp; <br>&nbsp; &nbsp; &nbsp; &nbsp; Standard Yes/No/Cancel dialog. &nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; <button id="mb4">&nbsp; &nbsp; &nbsp; &nbsp; Show&nbsp; &nbsp; </button></p><div id="msg1">usman</div>