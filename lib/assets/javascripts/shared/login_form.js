$(document).ready(function(){
  // If the hidden valid-form field is set to true then enable the submit button
  $("form.login-form #valid-form").change(function(){
    $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
  });

  // See if we should enable the submit button when a required input changes
  $("form.login-form input[class*='required']").on('change keyup', function(){
    toggleLogInSubmit();
  });

  // Run the input validations when the focus changes
  $("form.login-form #user_email").on('blur', function(){
    toggleInputError(this, validateEmail($(this).val().trim()));
  });
  $("form.login-form #user_password").on('blur', function(){
    toggleInputError(this, validatePassword($(this).val().trim()));
  });
  
  // Toggle the password field so that its visible/masked
  $("form.login-form #password_show").click(function(){
    let typ = $("form.login-form #user_password").attr('type');
    $("form.login-form #user_password").attr('type', (typ === 'password' ? 'text' : 'password'));
  });
  
  // Run the validations in case the page was refreshed
  toggleInputError($("form.login-form #user_email"), 
                   validateEmail($("form.login-form #user_email").val().trim()));
  toggleInputError($("form.login-form #user_password"), 
                   validatePassword($("form.login-form #user_password").val().trim()));
  
  // Make sure the show password checkbox is unchecked on load
  $("form.login-form #password_show").attr("checked", false);
  
  // Display the submit button only if there is a valid email and password
  function toggleLogInSubmit(){
    let disabled = (validateEmail($("form.login-form #user_email").val()) != '' || 
                    validatePassword($("form.login-form #user_password").val()) != '');
    $("form.login-form #sign-in-button").attr('aria-disabled', disabled);
  }
});

