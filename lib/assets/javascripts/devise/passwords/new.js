$(document).ready(function(){
  $("form.password-reset #user_email").on('change keyup', function(){
    $("#password-reset-button").attr('aria-disabled', validateEmail($(this).val()) != '');
  });
});