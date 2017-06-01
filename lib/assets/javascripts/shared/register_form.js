$(document).ready(function(){
  // If the hidden valid-form field is set to true then enable the submit button
  $("form.user-registration #valid-form").change(function(){
    $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
  });

  $("form.user-registration input[class*='required']").change(function(){
    toggleRegisterSubmit();
  });

  $("form.user-registration #user_email, form.user-registration #user_recovery_email").blur(function(){
    emailsMatch($(this).parent('form'));
  });

  function toggleRegisterSubmit(){
    let disabled = ($("#user_firstname").val().trim().length <= 0 || 
                    $("#user_surname").val().trim().length <= 0 || 
                    $("#user_email").val().trim().length <= 0 || 
                    $("#user_recovery_email").val().trim().length <= 0 || 
                    $("#user_password").val().trim().length <= 0 ||
                    $("#user_email").val() === $("#user_recovery_email").val());
    $("form.user-registration #register-button").attr('aria-disabled', disabled);
  }
	
	function emailsMatch(form){
    let email = $(this).find('#user_email');
		let recovery = $(this).find('#user_recovery_email');
		
		if($(email).val().trim() === $(recovery).val().trim()){
      $("span." + $(email).attr('roadmap-js-id') + "_error").html('').attr('role', '');
      $("input[roadmap-js-id='" + $(email).attr('roadmap-js-id') + "']").removeClass('red-border');
    }else{
      $("span." + $(email).attr('roadmap-js-id') + "_error").attr('role', 'tooltip');
      $("input[roadmap-js-id='" + $(email).attr('roadmap-js-id') + "']").addClass('red-border');
    }
	}
});
