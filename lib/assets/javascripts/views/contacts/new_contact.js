var RecaptchaOptions = {
  theme : "clean"
};

$(document).ready(function(){
  // Run the input validations when the focus changes
  $("#contact_us_contact_email").blur(function(){
    toggleInputError(this, validateEmail($(this).val().trim()));
  });
	
  $("input[type='text'], input[type='email'], textarea").change(function(e){
    var enable = ($("#contact_us_contact_name").val().trim().length > 0 &&
                  validateEmail($("#contact_us_contact_email").val().trim()) === '' &&
                  $("#contact_us_contact_subject").val().trim().length > 0 &&
                  $("#contact_us_contact_message").val().trim().length > 0);
    
    // Disabled recaptcha since always sets enable, TODO change when we tackle https://github.com/DMPRoadmap/roadmap/issues/501
		// if($("#recaptcha-anchor")){
		// 	if($("#recaptcha-anchor").prop('aria-checked') != 'true'){
		// 		enable = false;
		// 	}
		// }
    $("#create_contact_submit").attr('aria-disabled', !enable);
  });
});