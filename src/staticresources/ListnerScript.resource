<!-- We can locate this div with the script below, traverse up the DOM
and then hide the entire sidebar component. -->
<div id="sidebarComponentLocator">
    If you see this, something is broke with Dynamic functionality.
</div> 
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript">
</script> 
<script type="text/javascript"> 
var j$ = jQuery.noConflict();    
j$(document).ready(function() { 	
	try{ 
		/*Get the Contact object prefix to make sure the current page is belonging to Contact page*/
		j$("#sidebarComponentLocator").closest(".sidebarModule").hide().prev().hide();
		var ContactObjectPrefix = '';
		try{
			ContactObjectPrefix = j$(location).attr('href').split('/')[3]; 
		}catch(e){
			console.log('Url is not Loaded, Please refrech your page. '+e);
		} 	
		if(ContactObjectPrefix.substring(0, 3) == '003'){ 
			var lblIsSupportCaller = j$("label:contains('Is Support Caller')");
			if (lblIsSupportCaller != null && lblIsSupportCaller.attr('for') != null) {
				var IsSupportCallerChkBxId = lblIsSupportCaller.attr('for'); 
				var IsSupportCallerInput = "input[name='" + IsSupportCallerChkBxId + "']";
				j$("input[name='save'],input[name='save_new']").click(function() {  
					var result = sforce.connection.query("Select Name, Label, Id From PermissionSet Where Name in( 'Full_Case_Access_Read_Write_Edit','Case_Knowledge_Access_Read')");  
					var queryMore = true;					 
					if(j$(IsSupportCallerInput).is(':checked')){	
					    while (queryMore) {
					        var records = result.getArray("records");
					        for (var i = 0; i < records.length; i++) { 
					            addPermissionSetToUser(ContactObjectPrefix,records[i].Id);
					            break;
					        }
					        if (result.getBoolean("done")) {
					            queryMore = false;
					        } else {
					            result = sforce.connection.queryMore(result.queryLocator);
					        }
					    }
					}else{
						while (queryMore) {
					        var records = result.getArray("records");
					        for (var i = 0; i < records.length; i++) { 
					            deletePermissionSetAssignment(records[i].Id,ContactObjectPrefix);					            
					        }
					        if (result.getBoolean("done")) {
					            queryMore = false;
					        } else {
					            result = sforce.connection.queryMore(result.queryLocator);
					        }
					    }						
					}
				});
			} else if(j$('.labelCol').text().indexOf('Is Support Caller') != -1){				
				var IsSupportCallerChkBxChked = j$(j$("td").filter(function() { return $.text([this]) == 'Is Support Caller'; }).parent()).find('input:checkbox').is(':checked');
				var result = sforce.connection.query("Select Name, Label, Id From PermissionSet Where Name = 'Full_Case_Access_Read_Write_Edit'"); 
				var records = null;
				if(result != null){
					records = result.getArray("records");
				}
				var queryMore = true;
				if(IsSupportCallerChkBxChked || j$(j$("td").filter(function() { return $.text([this]) == 'Is Support Caller'; }).parent()).find('img').attr('alt') == 'Checked'){ 					
				 	while (queryMore) {				        
				        for (var i = 0; i < records.length; i++) { 
				            addPermissionSetToUser(ContactObjectPrefix,records[i].Id);
				            break;
				        }
				        if (result.getBoolean("done")) {
				            queryMore = false;
				        } else {
				            result = sforce.connection.queryMore(result.queryLocator);
				        }
				    }	
				}else{  
					if(records != null){
						if(getUserIdByContactId(ContactObjectPrefix,records[0].Id) != null){
							while (queryMore) {
						        var records = result.getArray("records");
						        for (var i = 0; i < records.length; i++) { 
						            deletePermissionSetAssignment(records[i].Id,ContactObjectPrefix);					            
						        }
						        if (result.getBoolean("done")) {
						            queryMore = false;
						        } else {
						            result = sforce.connection.queryMore(result.queryLocator);
						        }
						    }
				    	}
			    	}	
				}
			} else{
				console.log('Element not found');
			}
		}		
	} catch(e) { 
		 console.log('Error:'+e)
	}    
}); 
/*@For add permission set to portal User.*/
function addPermissionSetToUser(ContactId,pSId){
	try{
		var result = sforce.connection.query("Select Id,ContactId, (Select Id, PermissionSetId, AssigneeId, SystemModstamp From PermissionSetAssignments) From User u where ContactId = '"+ContactId+"'");	
		var queryMore = true;
		while (queryMore) {
	        var records = result.getArray("records");
	        for (var i = 0; i < records.length; i++) { 
	            createPermissionSetAssignment(pSId,records[i].Id);
	            break;
	        }
	        if (result.getBoolean("done")) {
	            queryMore = false;
	        } else {
	            result = sforce.connection.queryMore(result.queryLocator);
	        }
	    }
	}catch(e){
		console.log('Error:'+e);
	}
} 
/*@Create permissionSetAssignment record!*/
function createPermissionSetAssignment(PermissionSetId,AssigneeId){
	try{
		var toCreatePSAssignments = [];
	    var toCreatePsAssignment = new sforce.SObject("PermissionSetAssignment");
	    toCreatePsAssignment.PermissionSetId = PermissionSetId;
	    toCreatePsAssignment.AssigneeId = AssigneeId;
	    toCreatePSAssignments.push(toCreatePsAssignment);
		var result = sforce.connection.create(toCreatePSAssignments);
		var sb = "";
		for (var i=0; i<result.length; i++) {
		    if (result[i].getBoolean("success")) {
		    	sb += "\n new PermissionSetAssignment created with id " + result[i].id;
		    } else {
		 	   sb += "\n failed to create PermissionSetAssignment " + result[i];
		    }
		}
		console.log("Result : " + sb);
	}catch(e){
		console.log('Error:'+e);
	}
}
/*@Delete Permission set from the portal User*/
function deletePermissionSetAssignment(PermissionSetId,contactId){
	try{
		var AssigneeId = getUserIdByContactId(contactId,PermissionSetId);	
		var pSAResult = sforce.connection.query("Select SystemModstamp, PermissionSetId, Id, AssigneeId From PermissionSetAssignment Where PermissionSetId = '"+PermissionSetId+"' AND AssigneeId = '"+AssigneeId+"'");	
		var records = pSAResult.getArray("records");
		if(records.length > 0){
			var delPS = sforce.connection.deleteIds([records[0].Id]);
		  	if (delPS[0].getBoolean("success")) {
		    	console.log("Delete PermissionSet with id " + PermissionSetId + " deleted");
		  	} else {
		    	console.log("Failed to Delete PermissionSet " + records[0].Id);
		  	}
	  	}
    }catch(e){
    	console.log('Error:'+e);
    }
}
/*@ To get User Id By Contact Id*/
function getUserIdByContactId(contactId,pSAssigneeId){
	try{
		var result = sforce.connection.query("Select Id,ContactId, (Select Id, PermissionSetId, AssigneeId, SystemModstamp From PermissionSetAssignments Where PermissionSetId ='"+pSAssigneeId+"') From User u where ContactId = '"+contactId+"'");
		var records = result.getArray("records"); 
		if(records.length > 0 && records[0].PermissionSetAssignments.getArray("records").length > 0){
			return records[0].Id;
		}
	}catch(e){
		console.log('Error:'+e);
	}
	return null;	
}  
</script>
&nbsp; &nbsp;
<div id="dialog" title="Basic dialog">
    &nbsp;
    <p>
        Somthing is broken.
    </p>
</div> 