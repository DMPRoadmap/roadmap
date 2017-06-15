$(document).ready(function(){
  // See if we should enable the submit button when a required input changes
  $("input").change(function(){
    toggleSubmit();
  });
  
  // Run the input validations when the focus changes
  $("#user_email, #user_recovery_email").blur(function(){
    var msg = validateEmail($(this).val().trim());
    // If the standard email validation was successful validate that they do not match
    toggleInputError(this, (msg != '' ? msg : validateEmailsDoNotMatch()));
  });
  $("#user_current_password").blur(function(){
    toggleInputError(this, validatePassword($(this).val().trim()));
  });
  $("#user_new_password, #user_password_confirmation").blur(function(){
    var msg = validatePassword($(this).val().trim());
    // If the standard password validation was successful validate that they match
    toggleInputError(this, (msg != '' ? msg : validatePasswordsMatch()));
  });
  
  // Toggle the password field so that its visible/masked
  $("#passwords_show").click(function(){
    var typ = $("#user_current_password").attr('type');
    $("#user_current_password").attr('type', (typ === 'password' ? 'text' : 'password'));
    $("#user_new_password").attr('type', (typ === 'password' ? 'text' : 'password'));
    $("#user_password_confirmation").attr('type', (typ === 'password' ? 'text' : 'password'));
  });
  
  // Make sure the show password checkbox is unchecked on load
  $("#passwords_show").attr("checked", false);
  
  toggleSubmit();
  
  function validateEmailsDoNotMatch(){
    var email = $("form.register-form #user_email").val().trim();
    var recovery = $("form.register-form #user_recovery_email").val().trim();
    return (email === recovery ? (email != '' ? __('Emails must be different') : '') : '');
  }
  
  function validatePasswordsMatch(){
    var pwd = $("#user_new_password").val().trim();
    var conf = $("#user_password_confirmation").val().trim();
    return (pwd != conf ? (pwd != '' ? __('Passwords must match') : '') : '');
  }
  
  // Display the submit button only if there is a valid email and password
  function toggleSubmit(){
    var disabled = ($("#user_firstname").val().trim().length <= 0 || 
                    $("#user_surname").val().trim().length <= 0 || 
                    validateEmail($("#user_email").val()) != '' ||
                    validateEmail($("#user_recovery_email").val()) != '' ||
                    $("#user_new_password").val() != $("#user_password_confirmation").val());
    $("#update").attr('aria-disabled', disabled);
  }
});

