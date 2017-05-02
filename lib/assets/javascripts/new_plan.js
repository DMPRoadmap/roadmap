$(document).ready(function(){
	// Replace the default js-combobox clear button [X] with a fontawesome icon
	$(".combobox-clear-button").html('<i class="fa fa-times-circle"></i>');
	
	// Form submit button is disabled until all requirements are met
	$(".form-submit").prop("disabled", true);
	
	// Function to hide/show the clear button when text changed in the dropdown
	$(".combobox-container input.js-combobox").keyup(function(){
		displayClearButton(this);
	});
	
	$(".combobox-container input.js-combobox").change(function(){
		toggleSubmit();
	});
	
	// Initialize the clear buttons on load
	$(".combobox-container input.js-combobox").each(function(){
		displayClearButton(this);
	});
	
	// Hide the clear button if it gets clicked
	$(".combobox-clear-button").click(function(){
		$(this).css("display", 'none');
	});
	
	// If the user clicks the no Organisation checkbox disable the dropdown and hide clear button
	$("#plan_no_org").click(function(){
		$("#plan_org_name").prop("disabled", this.checked).val("");
		displayClearButton($("#plan_org_name"));
		toggleSubmit();
	});
	
	// If the user clicks the no Funder checkbox disable the dropdown and hide clear button
	$("#plan_no_funder").click(function(){
		$("#plan_funder_name").prop("disabled", this.checked).val("");
		displayClearButton($("#plan_funder_name"));
		toggleSubmit();
	});
	
	$(".form-submit").click(function(e){
		e.preventDefault();
		
		retrieveTemplates(function(hash){
			if(hash['templates']){
				if(hash['templates'].length > 1){
					// Display they template selector
					console.log(hash);
				}else{
					$("#plan_template_id").val(hash['templates'][0]['id']);
					// submit the page
					$("form").submit();
				}
			}
		});
	});
});

function displayClearButton(combobox){
	var clear = $(combobox).siblings(".combobox-clear-button");
	// For some reason the standard .show() forces a 'display: block;' so we
	// instead directly set the attribute to maintain the position of the button
	if($(combobox).val().trim().length <= 0){
		clear.css("display", 'none');
	}else{
		clear.css("display", 'inline');
	}
}

// Only display the submit button if the user has made each decision
function toggleSubmit(){
	// If the (no_org checkbox is checked OR an org was selected) AND
	//				(no_funder checkbox is checked OR a funder was selected)
	var show = ($("#plan_no_org").prop("checked") || 
							$("#plan_org_name").val().trim().length > 0) &&
						 ($("#plan_no_funder").prop("checked") || 
							$("#plan_funder_name").val().trim().length > 0) &&
						 $('input[name="plan[template_id]"]:checked');
	
	$(".form-submit").prop("disabled", !show);
}

// AJAX call to retrieve the list of available templates
function retrieveTemplates(callback){
	var retrieve = ($("#plan_no_org").prop("checked") || 
									$("#plan_org_name").val().trim().length > 0) &&
						 		 ($("#plan_no_funder").prop("checked") || 
									$("#plan_funder_name").val().trim().length > 0);

	if(retrieve){
		var args = {org_name: $("#plan_org_name").val(),
								funder_name: $("#plan_funder_name").prop("value")};
								
		$.getJSON("/plans/possible_templates", args).done(function(json){
			callback(json);
		});
	}
}