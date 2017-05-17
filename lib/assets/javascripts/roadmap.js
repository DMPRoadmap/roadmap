$(document).ready(function(){
  
  $('input[type="email"]').on('change', function(){
    if(!validateEmail($(this).val().trim())){
      $("#" + $(this).attr('id') + "_tip").attr('role', 'tooltip');
    }else{
      $("#" + $(this).attr('id') + "_tip").attr('role', '');
    }
  });
  
  $('input[name*="password"]').on('change', function(){
    if(!validatePassword($(this).val().trim())){
      $("#" + $(this).attr('id') + "_tip").attr('role', 'tooltip');
    }else{
      $("#" + $(this).attr('id') + "_tip").attr('role', '');
    }
  });
});


// ---------------------------------------------------------------------------
function validatePassword(sPassword) {
  if (sPassword.trim().length >= 8 && sPassword.trim().length <= 128){
    return true;
  }
  else {
    return false;
  }
}