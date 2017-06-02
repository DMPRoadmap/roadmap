$(document).ready(function(){
  $("#user_email").blur(function(){
    $("#password-reset-button").attr('aria-disabled', validateEmail($(this).val()) != '');
  });
	
	// Run the input validations when the focus changes
	$("#user_email").blur(function(){
    toggleInputError(this, validateEmail($(this).val().trim()));
	});
});