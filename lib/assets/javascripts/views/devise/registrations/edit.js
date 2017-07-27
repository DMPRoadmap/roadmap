$(document).ready(function(){
  // See if we should enable the submit button when a required input changes
  $("input").change(function(){
    toggleSubmit();
  });
  
  // Run the input validations when the focus changes
  $("#user_email, #user_recovery_email").blur(function(){
    var msg = validateEmail($(this).val().trim());
    // If the standard email validation was successful validate that they do not match
    toggleFormElementError(this, (msg != '' ? msg : validateEmailsDoNotMatch()));
  });
  $("#user_current_password").blur(function(){
    toggleFormElementError(this, validatePassword($(this).val().trim()));
  });
  $("#user_new_password, #user_password_confirmation").blur(function(){
    var msg = validatePassword($(this).val().trim());
    // If the standard password validation was successful validate that they match
    toggleFormElementError(this, (msg != '' ? msg : validatePasswordsMatch()));
  });
  
  // Toggle the password field so that its visible/masked
  $("#password_show").click(function(){
    var typ = $("#user_current_password").attr('type');
    $("#user_current_password").attr('type', (typ === 'password' ? 'text' : 'password'));
    $("#user_new_password").attr('type', (typ === 'password' ? 'text' : 'password'));
    $("#user_password_confirmation").attr('type', (typ === 'password' ? 'text' : 'password'));
  });
  
  // Make sure the show password checkbox is unchecked on load
  $("#password_show").attr("checked", false);
  
  $('#user_org_name').on("change", function(e) {
      e.preventDefault();
      var selected_org = $(this).val();
      var other_orgs = $("#other-org-name").attr("data-orgs").split(",");
      var index = $.inArray(selected_org, other_orgs);
      if (index > -1) {
          $("#other-org-name").show();
          $("#user_other_organisation").focus();
      }
      else {
          $("#other-org-name").hide();
          $("#user_other_organisation").val("");
      }
  });
  $("#other-org-link > a").click(function(e){
      e.preventDefault();
      var other_org = $("#other-org-name").attr("data-orgs").split(",");
      $("#user_org_name").val("");
      $("#user_org_id").val("");
      $("#user_org_name").change();
  });

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
                    validateEmail($("#user_recovery_email").val()) != '');
    $("#update").attr('aria-disabled', disabled);
  }
});

