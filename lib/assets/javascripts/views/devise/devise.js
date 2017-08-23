$(document).ready(function(){
  // Password reset
  dmproadmap.utils.ariatiseForm.init({ selector: '#user_request_reset_password' });
  dmproadmap.utils.ariatiseForm.init({ selector: '#user_reset_password' });
  dmproadmap.utils.ariatiseForm.init({ selector: '#invitation_create_account' });

  $("[type='submit']").click(function(e){
    // We have to specifically include the form name in the selectors here in case there  
    // are multiple devise forms (e.g. sign-in modal and the forgot password forms)
    var frm = $(this).closest('form').attr('id'),
        pwd = $("#"+frm+" #user_password"),
        cnf = $("#"+frm+" #user_password_confirmation");

    // If the password and password_confirmation are present and do not match display an error
    if(pwd.val() && cnf.val()){
      if(pwd.val() != cnf.val()){
        e.preventDefault();
        dmproadmap.utils.ariatiseForm.displayValidationError(cnf, dmproadmap.constants.VALIDATION_MESSAGE_PASSWORDS_MATCH);
      }
    }
  });
});