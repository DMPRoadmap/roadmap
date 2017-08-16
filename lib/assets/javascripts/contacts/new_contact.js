var RecaptchaOptions = {
  theme : "clean"
};

$(document).ready(function(){
  $("input[type='text'], input[type='email'], textarea").change(function(e){
    var enable = ($("#contact_us_contact_name").val().trim().length > 0 &&
                  $("#contact_us_contact_email").val().trim().length > 0 &&
                  $("#contact_us_contact_subject").val().trim().length > 0 &&
                  $("#contact_us_contact_message").val().trim().length > 0);
    
    $("#create_contact_submit").attr('aria-disabled', !enable);
  });
});