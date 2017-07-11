$(document).ready(function(){
  /*----------------
    Listener for changes in access-level for a plan shared with a user
    TODO partial update instead of forcing a page reload
  ------------------*/
  $(".toggle-existing-user-access").change(function(){
    $(this).closest('form').submit();
  });
  
  // Run the input validations when the focus changes
  $("#role_user_email").on('blur', function(){
    toggleInputError(this, validateEmail($(this).val().trim()));
  });
  
  // See if we should enable the add collaborator button
  $("#role_user_email").on('change keyup', function(){
    toggleAddCollaboratorSubmit();
  });
  $("input[name='role[access_level]']").on('click', function(){
    toggleAddCollaboratorSubmit();
  });
  
  // Display the submit button only if there is a valid email and password
  function toggleAddCollaboratorSubmit(){
    var disabled = (validateEmail($("#role_user_email").val()) != '' || 
                    $("input[name='role[access_level]']:checked").val() == undefined);
    $("#add-collaborator-button").attr('aria-disabled', disabled);
  }
});