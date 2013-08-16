<!-- We can locate this div with the script below, traverse up the DOM
and then hide the entire sidebar component. -->
<div id="sidebarComponentLocator">
    If you see this, something is broke with Dynamic Button functionality.
</div> 
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript">
</script>
<style>
	.requiredLoaderBG{
		background-color: gray;
		opacity:0.5;
		filter:alpha(opacity=50);
		position: fixed;  
		z-index: 1;
	}	
</style>
<script type="text/javascript"> 
var j$ = jQuery.noConflict();    
j$(document).ready(function() { 
	try{ 
		/*Get the event object prefix to make sure the current page is belonging to event page*/
		j$("#sidebarComponentLocator").closest(".sidebarModule").hide().prev().hide();
		var eventObjectPrefix = '';
		try{
			eventObjectPrefix = j$(location).attr('href').split('/')[3];
		}catch(e){
			console.log('Url is not Loaded, Please refrech your page. '+e);
		} 	
		if(eventObjectPrefix == '00U'){	
			var userId = sforce.connection.getUserInfo().userId; 
			j$('.sidebarCell a, .zen a,input[type$="button"],input[type$="submit"]').click(function(){					
				if(j$(this).attr('name') != 'save' && j$(this).attr('name') != 'savenewtask' && j$(this).attr('name') != 'savenewevent' 
				&& j$(this).attr('name') != 'new' && j$(this).attr('name') != 'attachFile'){
					var flag = confirm("You are closing a tab that has unsaved changes. \nWould you like to save your changes?");
					if(!flag){						
						var gtm12 = j$('#evt6').val();   
						var subStringTxt = gtm12.substr(gtm12.indexOf('||*'),gtm12.indexOf('*||')-gtm12.indexOf('||*~')+3); 
						var mtId = subStringTxt.substr(subStringTxt.indexOf('Meeting id:')+11,10); 						 
						try{ 
							sforce.apex.execute('RMA_C2M.GTMHelper', 'deleteRemoteMeeting', { meetingId: mtId, assignedTo: userId }); 
						}catch(ex){
							erorRepting('Error Occured to create GTM, Details:' +ex); 
							alert('Error:'+ex);
						}
						return true;
					}else{
						return false;
					}
				}
			});
			var lblCreateGTMInvite = j$("label:contains('Create GoToMeeting Invite')");
			if (lblCreateGTMInvite != null && lblCreateGTMInvite.attr('for') != null) {
				gtmchkbxId = lblCreateGTMInvite.attr('for');
				console.log("input[name='" + gtmchkbxId + "']");
				var gtmInput = "input[name='" + gtmchkbxId + "']";
				j$(gtmInput).click(function() {  
					var start = j$("#StartDateTime").val() + ' ' + j$("#StartDateTime_time").val();  
					var end = j$("#EndDateTime").val() + ' ' + j$("#EndDateTime_time").val();  
					var meetingtype = 'Scheduled'; 
					var isRecurrence = j$("#IsRecurrence").val(); 
					if (isRecurrence) { meetingtype = 'Recurring'; }  
					var subject = j$("#evt5").val();  
					var passwordrequired = 'false';  					
					if(j$(this).is(':checked')){ 
						j$('body').addClass('requiredLoaderBG'); 
						var isUserHaveGTMAccount = sforce.apex.execute('RMA_C2M.GTMHelper', 'isUserHaveGTMAccount', { userId:userId }); 
						if(isUserHaveGTMAccount == 'false'){
							if(confirm("You do not have the GTM Account, First of all you need to create a GTM Account Please press 'Ok' if want to create.")){ 
								window.location = "/apex/rma-c2m__GTMConsole"; 
							}else{
								j$('body').removeClass('requiredLoaderBG');
								j$(this).removeAttr('checked');	
							}							
						} else { 
							j$(this).parent().append("<strong class='gtmMsg12' style='color:green'>&nbsp;Please wait Creating GotoMeeting Details....</strong>"); 
							setTimeout(function() { 
								try{ 
									var result = sforce.apex.execute('RMA_C2M.GTMHelper', 'createRemoteMeeting', { startDate: start, endDate: end, meetingType: meetingtype, subject: subject, assignedTo: userId }); 
									var result1 = JSON.parse(result); 
									if(result1.joinURL == "Error"){	
										alert("Error: "+result1.meetingId);									
										j$('body').removeClass('requiredLoaderBG'); 
										j$('.gtmMsg12').remove();			        
										document.getElementById(gtmchkbxId).checked = false;
										return false;
									}
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
						j$(this).parent().append("<strong class='gtmMsg123' style='color:green'>&nbsp;Please wait Deleting GotoMeeting Details....</strong>"); 
						var gtm12 = j$('#evt6').val();   
						var subStringTxt = gtm12.substr(gtm12.indexOf('||*'),gtm12.indexOf('*||')-gtm12.indexOf('||*~')+3);  
						var mtId = subStringTxt.substr(subStringTxt.indexOf('Meeting id:')+11,10); 
						setTimeout(function() { 
							try{ 
								sforce.apex.execute('RMA_C2M.GTMHelper', 'deleteRemoteMeeting', { meetingId: mtId, assignedTo: userId }); 
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
				});
			} else {
			console.log('element not found');
		} 
	}
	} catch(e) { 
		j$('body').removeClass('requiredLoaderBG'); 
		j$('.gtmMsg123').remove(); 
		j$('.gtmMsg12').remove(); 
		erorReporting('Error Occured to create GTM. \nDetails: ' +e); alert(e); 
	}    
}); 
/*Email to the USer to report Error!*/ 
function erorReporting(body){
 	try{
  		sforce.apex.execute('RMA_C2M.GTMHelper', 'errorReporting', { Body: body }); 
	} catch(ex) {  
		alert(ex); 
	} 
}
</script>
&nbsp; &nbsp;
<div id="dialog" title="Basic dialog">
    &nbsp;
    <p>
        This is an animated dialog which is useful for displaying information.&nbsp;
        &nbsp; The dialog window can be moved, resized and closed with the 'x'
        icon.
    </p>
</div>
&nbsp; &nbsp;
<p>
    &nbsp; &nbsp;
    <b>
        Yes/No/Cancel
    </b>
    <br>
    &nbsp; &nbsp; Standard Yes/No/Cancel dialog. &nbsp;&nbsp; &nbsp;&nbsp;
    &nbsp;
    <button id="mb4">
        Show
    </button>
</p> 