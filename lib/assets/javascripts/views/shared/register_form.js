$(document).ready(function(){
  if($("form.register-form").length > 0){
    // If the hidden valid-form field is set to true then enable the submit button
    $("form.register-form #valid-form").change(function(){
      $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
    });

    // See if we should enable the submit button when a required input changes
    $("form.register-form input[class*='required'], #other-org-name, #user_org_name").on('change keyup', function(){
      toggleRegisterSubmit();
    });
  
    // Run the input validations when the focus changes
    $("form.register-form #user_email, form.register-form #user_recovery_email").on('blur change', function(){
      var msg = validateEmail($(this).val().trim());
      // If the standard email validation was successful validate that they do not match
      toggleFormElementError(this, (msg != '' ? msg : validateEmailsDoNotMatch()));
    });
    $("form.register-form #user_password").on('blur change', function(){
      toggleFormElementError(this, validatePassword($(this).val().trim()));
    });
  
    // Toggle the password field so that its visible/masked
    $("form.register-form #password_show").click(function(){
      var typ = $("form.register-form #user_password").attr('type');
      $("form.register-form #user_password").attr('type', (typ === 'password' ? 'text' : 'password'));
    });
    
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
  
    // Run the validations in case the page was refreshed
    toggleFormElementError($("form.register-form #user_email"), 
                     validateEmail($("form.register-form #user_email").val().trim()));
    toggleFormElementError($("form.register-form #user_recovery_email"), 
                     validateEmail($("form.register-form #user_recovery_email").val().trim()));
    toggleFormElementError($("form.register-form #user_password"), 
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
                      $("form.register-form #user_email").val() === $("form.register-form #user_recovery_email").val() ||
                      ($("form.register-form #user_org_name").val().trim().length <=0 && $("form.register-form #user_other_organisation").val().trim().length <= 0));
      $("form.register-form #register-button").attr('aria-disabled', disabled);
    }
  }
});
