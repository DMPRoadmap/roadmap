$(document).ready(function(){
  // If the hidden valid-form field is set to true then enable the submit button
  $("#valid-form").change(function(){
    $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
  });

  $("#sign-in-form input[class*='required']").change(function(){
    toggleSignInSubmit();
  });
});

function toggleError(input, valid){
  if(valid){
    $(input).siblings('.' + $(input).attr('id') + '-error').hide();
    $(input).removeClass('red-border');
  }else{
    $(input).siblings('.' + $(input).attr('id') + '-error').show();
    $(input).addClass('red-border');
  }
}

function toggleSignInSubmit(){
  var disabled = (validateEmail($("#user_email").val()) != '' || validatePassword($("#user_password").val()) != '');
  $("#sign-in-button").attr('aria-disabled', disabled);
}

function toggleRegisterSubmit(){
  var disabled = ($("#user_firstname").val().trim().length <= 0 || 
                  $("#user_surname").val().trim().length <= 0 || 
                  $("#user_email").val().trim().length <= 0 || 
                  $("#user_recovery_email").val().trim().length <= 0 || 
                  $("#user_password").val().trim().length <= 0 ||
                  $("#user_email").val() === $("#user_recovery_email").val());
  $("#register-button").attr('aria-disabled', disabled);
}