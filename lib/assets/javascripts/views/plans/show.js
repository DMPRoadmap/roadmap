$(document).ready(function(){
  // Run the input validations when the focus changes
  $("input[type='email']").on('blur', function(){
    toggleInputError(this, validateEmail($(this).val().trim()));
  }).on('change keyup', function(){
    toggleProjectDetailsSubmit();
  });

  $("#plan_title").on('blur', function(){
    toggleInputError(this, ($(this).val().trim().length <= 0 ? __('The title cannot be blank') : ''), true);
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
  
  $(".guidance-choice").click(function(){
    toggleGuidanceChoices();
  });
  
  toggleProjectDetailsSubmit();
  toggleDataContact();
  toggleGuidanceChoices();
  
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
  
  // Only allow up to 3 guidance groups to be selected
  function toggleGuidanceChoices(){
    if($(".guidance-choice:checked").length <= 6){
      $(".guidance-choice").removeAttr('disabled');
      $(".guidance-group-label").removeClass('disabled');
    }else{
      $(".guidance-choice:not(:checked)").attr('disabled', 'disabled')
          .siblings(".guidance-group-label").addClass('disabled');
    }
  }
});