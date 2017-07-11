// ---------------------------------------------------------------------------
function toggleAutocompleteError(autocomplete, idbox, errorMessage){
	if(autocomplete.length > 0 && idbox.length > 0){
	  var err = $(idbox).siblings("span.error-tooltip");
	  if(err.length <= 0){
	    err = $(idbox).siblings("span.error-tooltip-right");
	  }
  
	  // If an error element is available and the error message is not empty and the field
	  // is not empty
	  if(err.length > 0 && (errorMessage === '' || $(autocomplete).val().trim().length <= 0)){
	    err.html('').attr('role', '');
	    $(autocomplete).removeClass('red-border');
	  }else{
	    err.html(errorMessage).attr('role', 'tooltip');
	    $(autocomplete).addClass('red-border');
	  }
	}
}

// ---------------------------------------------------------------------------
function toggleInputError(input, errorMessage){
  var err = $(input).siblings("span.error-tooltip");
  if(err.length <= 0){
    err = $(input).siblings("span.error-tooltip-right");
  }
  
console.log(err.length + ' - ' + errorMessage + ' - ' + $(input).val().trim().length);
	
  // If an error element is available and the error message is not empty and the field
  // is not empty
  if(err.length > 0 && (errorMessage === '' || $(input).val().trim().length <= 0)){
    err.html('').attr('role', '');
    $(input).removeClass('red-border');
  }else{
    err.html(errorMessage).attr('role', 'tooltip');
    $(input).addClass('red-border');
  }
}

// ---------------------------------------------------------------------------
function validatePassword(sPassword) {
  if(sPassword.trim().length >= 8 && sPassword.trim().length <= 128){
    return '';
  }else{
    return __('Passwords must have at least 8 characters');
  }
}

// ---------------------------------------------------------------------------
function validateEmail(sEmail) {
  var filter = /[^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,}$/;
  if(filter.test(sEmail)){
    return '';
  }else{
    return __('Invalid Email');
  }
}