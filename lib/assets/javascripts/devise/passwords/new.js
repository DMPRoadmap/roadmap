$(document).ready(function(){
  $("#password-reset-form #user_email").change(function(){
    $("#password-reset-form #password-reset-button").attr('aria-disabled', validateEmail($(this).val()) != '');
  });
});