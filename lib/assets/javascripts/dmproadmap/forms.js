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
