$(document).ready(function(){
  
  $(".tab-panels div.tab-panel:not(.active)").hide();
	
  $(".tabs li a").click(function(e){
    e.preventDefault();
    
    // Make the clicked tab the active tab
    $(this).parent().addClass('active');
    $(this).attr('aria-selected', 'true');
    $.each($(this).parent().siblings(), function(i, sib){
      $(sib).removeClass('active');
      $(sib).find('> a').attr('aria-selected', 'false');
    });
    
    // Make the corresponding panel visible and the others hidden
    let panel = $($(this).attr("href"));
    panel.show().attr("aria-hidden", 'false');
    $.each($(panel).siblings(), function(i, p){
      $(p).hide().attr("aria-hidden", 'true');
    });
  });
  
	// If the hidden valid-form field is set to true then enable the submit button
	$("#valid-form").change(function(){
		$(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
	});
	
/*	$("input[type='email']").change(function(){
		toggleError(this, validateEmail($(this).val().trim()));
	});
*/
	$("input[name*='password']").change(function(){
		toggleError(this, validatePassword($(this).val().trim()));
	});

	$("input[class='required']").change(function(){
		toggleSubmit();
	})
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
	let disabled = ($("#user_email").val().trim().length <= 0 || 
									$("#user_password").val().trim().length <= 0);
	$("#sign-in-button").attr('aria-disabled', disabled);
}

function toggleRegisterSubmit(){
	let disabled = ($("#user_firstname").val().trim().length <= 0 || 
									$("#user_surname").val().trim().length <= 0 || 
									$("#user_email").val().trim().length <= 0 || 
									$("#user_recovery_email").val().trim().length <= 0 || 
									$("#user_password").val().trim().length <= 0 ||
									$("#user_email").val() === $("#user_recovery_email").val());
	$("#register-button").attr('aria-disabled', disabled);
}