$(document).ready(function(){
	// Replace the default js-combobox clear button [X] with a fontawesome icon
	$(".combobox-clear-button").html('<i class="fa fa-times-circle"></i>');
	
	// Function to hide/show the clear button when text changed in the dropdown
	$(".combobox-container input.js-combobox").keyup(function(e){
		displayClearButton(this);
	});
	
	// Initialize the clear buttons on load
	$(".combobox-container input.js-combobox").each(function(idx){
		displayClearButton(this);
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