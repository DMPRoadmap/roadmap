// ---------------------------------------------------------------------------
function toggleInputError(input, errorMessage){
  var err = $(input).siblings("span.error-tooltip");
  if(err.length <= 0){
    err = $(input).siblings("span.error-tooltip-right");
  }
  
  if(err.length > 0 && (errorMessage === '' || $(input).val().trim().length <= 0)){
    err.html('').attr('role', '');
    $(input).removeClass('red-border');
  }else{
    err.html(__('Error: ') + errorMessage).attr('role', 'tooltip');
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
  var filter = /^[a-zA-Z0-9]+[a-zA-Z0-9_.-]+[a-zA-Z0-9_-]+@[a-zA-Z0-9]+[a-zA-Z0-9.-]+.[a-z]{2,4}$/;
  if(filter.test(sEmail)){
    return '';
  }else{
    return __('Invalid Email');
  }
}