$(document).ready(function(){
  /*----------------
    Listener for changes in access-level for a plan shared with a user
    TODO partial update instead of forcing a page reload
  ------------------*/
  $(".toggle-existing-user-access").change(function(){
    var params = {role: {access_level: $(this).find("option:checked").val()}};
    remoteSave("/roles/" + $(this).closest("form").find("#role_id").val(), 'PUT', JSON.stringify(params));
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
  
  $("input[name='plan[visibility]']").on('click, change', function(e){
    var params = {plan: {visibility: $("input[name='plan[visibility]']:checked").val()}};
    remoteSave("/plans/" + $("#plan_id").val() + "/visibility", 'POST', JSON.stringify(params));
  });
  
  // Display the submit button only if there is a valid email and password
  function toggleAddCollaboratorSubmit(){
    var disabled = (validateEmail($("#role_user_email").val()) != '' || 
                    $("input[name='role[access_level]']:checked").val() == undefined);
    $("#add-collaborator-button").attr('aria-disabled', disabled);
  }
});