$(document).ready(function(){
  // If the hidden valid-form field is set to true then enable the submit button
  $("form.login-form #valid-form").change(function(){
    $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
  });

  $("form.login-form input[class*='required']").change(function(){
    toggleLogInSubmit();
  });
  
  function toggleLogInSubmit(){
    let disabled = (validateEmail($("form.login-form #user_email").val()) != '' || 
                    validatePassword($("form.login-form #user_password").val()) != '');
    $("form.login-form #sign-in-button").attr('aria-disabled', disabled);
  }
});

