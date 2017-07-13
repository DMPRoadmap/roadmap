$(document).ready(function(){
  toggleDataContact();

  // Run the input validations when the focus changes
  $("input[type='email']").on('blur', function(){
    toggleInputError(this, validateEmail($(this).val().trim()));
  }).on('change keyup', function(){
    toggleProjectDetailsSubmit();
  });

  $("#plan_title").on('blur', function(){
    toggleInputError(this, ($(this).val().trim().length <= 0 ? __('The title cannot be blank') : ''), false);
  });

  $("#show-data-contact").click(function(){
    toggleDataContact();
  })
  
  $("#is_test").click(function(){
    $("#plan_visibility").val($(this).is(":checked") ? 'is_test' : 'privately_visible');
  });
  
  $("#show-other-guidance-orgs").click(function(){
    if($("#other-guidance-orgs").css('display') === 'block'){
      $("#other-guidance-orgs").hide();
      $(this).html($(this).html().replace('Hide', __('See')));
    }else{
      $("#other-guidance-orgs").show();
      $(this).html($(this).html().replace('See', __('Hide')));
    }
  });
  
  // Check form validation on page load
  toggleProjectDetailsSubmit();
  
  function toggleDataContact(){
    if($("#show-data-contact").is(':checked')){
      $(".data-contact-info").hide();
      $(".data-contact-info input").val('');
    }else{
      $(".data-contact-info").show();
    }
  }

  function toggleProjectDetailsSubmit(){
    var piEmail = $("#plan_principal_investigator_email").val();
    var dcEmail = $("#plan_data_contact_email").val();
    var disabled = $("#plan_title").val() == undefined;
    
    if(piEmail.trim() != '' && !disabled){
      disabled = validateEmail(piEmail) != '';
    }
    if(dcEmail.trim() != '' && !disabled){
      disabled = validateEmail(dcEmail) != '';
    }
                    
    $("#save-details-button").attr('aria-disabled', disabled);
  }
});