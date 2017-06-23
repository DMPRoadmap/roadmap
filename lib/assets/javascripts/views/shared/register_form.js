$(document).ready(function(){
  if($("form.register-form").length > 0){
    // If the hidden valid-form field is set to true then enable the submit button
    $("form.register-form #valid-form").change(function(){
      $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
    });

    // See if we should enable the submit button when a required input changes
    $("form.register-form input[class*='required']").on('change keyup', function(){
      toggleRegisterSubmit();
    });
  
    // Run the input validations when the focus changes
    $("form.register-form #user_email, form.register-form #user_recovery_email").on('blur change', function(){
      var msg = validateEmail($(this).val().trim());
      // If the standard email validation was successful validate that they do not match
      toggleInputError(this, (msg != '' ? msg : validateEmailsDoNotMatch()));
    });
    $("form.register-form #user_password").on('blur change', function(){
      toggleInputError(this, validatePassword($(this).val().trim()));
    });
  
    // Toggle the password field so that its visible/masked
    $("form.register-form #password_show").click(function(){
      var typ = $("form.register-form #user_password").attr('type');
      $("form.register-form #user_password").attr('type', (typ === 'password' ? 'text' : 'password'));
    });
  
    // Run the validations in case the page was refreshed
    toggleInputError($("form.register-form #user_email"), 
                     validateEmail($("form.register-form #user_email").val().trim()));
    toggleInputError($("form.register-form #user_recovery_email"), 
                     validateEmail($("form.register-form #user_recovery_email").val().trim()));
    toggleInputError($("form.register-form #user_password"), 
                     validatePassword($("form.register-form #user_password").val().trim()));
  
    // Make sure the show password checkbox is unchecked on load
    $("form.register-form #password_show").attr("checked", false);

    function validateEmailsDoNotMatch(){
      var email = $("form.register-form #user_email").val().trim();
      var recovery = $("form.register-form #user_recovery_email").val().trim();
      return (email === recovery ? (email != '' ? __('Emails must be different') : '') : '');
    }

    function toggleRegisterSubmit(){
      var disabled = ($("form.register-form #user_firstname").val().trim().length <= 0 || 
                      $("form.register-form #user_surname").val().trim().length <= 0 || 
                      validateEmail($("form.register-form #user_email").val()) != '' || 
                      validateEmail($("form.register-form #user_recovery_email").val()) != '' || 
                      !$("form.register-form #user_accept_terms").prop('checked') ||
                      $("form.register-form #user_email").val() === $("form.register-form #user_recovery_email").val());
      $("form.register-form #register-button").attr('aria-disabled', disabled);
    }
  }
});
