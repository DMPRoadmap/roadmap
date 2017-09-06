import ariatiseForm from '../../utils/ariatiseForm';

if ($) {
  $().ready(() => {
    // Invite Collaborators form on the Share page
    ariatiseForm({ selector: '#new_role' });
  });
}
/*
$(document).ready(function(){
  $(".toggle-existing-user-access").change(function(){
    var params = {role: {access_level: $(this).find("option:checked").val()}};
    asyncRequest({
      url: "/roles/" + $(this).closest("form").find("#role_id").val(), 
      type: 'PUT', 
      data: JSON.stringify(params)
    });
  });
  
  $("input[name='plan[visibility]']").on('click, change', function(e){
    var params = {plan: {visibility: $("input[name='plan[visibility]']:checked").val()}};
    asyncRequest({
      url: "/plans/" + $("#plan_id").val() + "/visibility", 
      type: 'POST', 
      data: JSON.stringify(params)
    });
  });
});
*/