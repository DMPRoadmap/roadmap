$(document).ready(function(){
  // Form submit button is disabled until all requirements are met
  $(".form-submit").prop("disabled", true);
  $("#available-templates").hide();

  // When the hidden org and funder id fields change toogle the submit button
  $("#plan_org_id, #plan_funder_id").change(function(){
    retrieveTemplateOptions();
  });
  
  // If the user clicks the no Organisation checkbox disable the dropdown and hide clear button
  $("#plan_no_org, #plan_no_funder").click(function(){
    var whichOne = $(this).prop('id').split('_')[2];
    $("#plan_" + whichOne + "_name").prop("disabled", this.checked).val("").keyup();
  });
});

// Only display the submit button if the user has made each decision
// -------------------------------------------------------------
function retrieveTemplateOptions(){
  // If the (no_org checkbox is checked OR an org was selected) AND
  //        (no_funder checkbox is checked OR a funder was selected)
  var retrieve = ($("#plan_no_org").prop("checked") || 
                  $("#plan_org_id").val().trim().length > 0) &&
                 ($("#plan_no_funder").prop("checked") || 
                  $("#plan_funder_id").val().trim().length > 0);

  $("#available-templates").fadeOut();
  $("#plan_template_id").val("");
  $(".form-submit").prop('disabled', true);

  if(retrieve){
    // If the templates section isn't available then submit the form to find the template options
    if($("#available_templates").html() == undefined){
      $("form").submit();
    }
  }
}
