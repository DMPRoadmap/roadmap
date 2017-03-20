$( document ).ready(function() {
  $(".select2-container").select2();
  
  // The following function references a JSON array that is
  // constructed in app/view/projects/_dropdown_new_project.html.erb
  // ----------------------------------------------------------
  function getTemplates(){
    // decide whether to filter by funder templates or institution templates
    // if the #other_funder_name is hidden, then do not include institutional templates
    // by default use the funder's templates
    var funder = [$("#plan_funder_id").val()];

    var template = $("#project_dmptemplate_id :selected").val();
            
    selectItemsFromJsonArray(templates, 'organisation', orgs, function(array){
      // Clear and reload the contents of the dropdown
      $("#project_dmptemplate_id").html("").select2( {data: array} ).val();

      // If there are less than 2 templates, hide the dropdown
      if(array.length < 2){
        $("#template-control-group").hide();
        //reloadGuidanceOptions();
        
      }else{
        // Select the first item in the list if there was none selected
        if(template == undefined){
          $("#project_dmptemplate_id").val(array[0]['id']).trigger('change');
        }else{
          //reloadGuidanceOptions();
        }
        
        $("#template-control-group").show();

        // if there is only one template disable the dropdown
        if(array.length > 1){
          $("#project_dmptemplate_id").prop('disabled', false);
        }else{
          $("#project_dmptemplate_id").prop('disabled', true);
        }
      }
    });
  }

  // The following function references a JSON array that is
  // constructed in app/view/projects/_dropdown_new_project.html.erb
  // ----------------------------------------------------------
  function reloadGuidanceOptions() {
    var institution = $("#project_institution_id").select2('val');
    var template = $("#project_dmptemplate_id :selected").val();
    var options = null;
    
    if(!template){
      template = $("#project_dmptemplate_id :selected").children().first().val();
    }
    
    options_container = $("#guidance-control-group");
    options_container = options_container.find(".choices-group");
    options_container.empty();
        
    var orgs = [$("#project_funder_id").val(),
                $("#project_institution_id").val()];

    // select all of the guidance groups available to the funder and/or institution
    selectItemsFromJsonArray(guidance_for_template_or_organisation, 'organisation', 
                                                          institution, function(array){
      array = guidance_always_available.concat(array);
      
      for(var i = 0; i < array.length; i++){
        var selected = false
  
        options_container.append(
            "<li class=\"choice\">" +
                "<label for=\"project_guidance_group_ids_" + array[i]['id'] + "\">" +
                "<input id=\"project_guidance_group_ids_" + array[i]['id'] + "\" " +
                       "name=\"project[guidance_group_ids][]\" " +
                       "value=\"" + array[i]['id'] + "\" type=\"checkbox\" />" +
                array[i]['text'] + "</label>" +
            "</li>"
        );
      }
    
      if(array.length > 0){
        $("#guidance-control-group").show();
      }else{
        $("#guidance-control-group").hide();
      }
    });
  }

  // ----------------------------------------------------------
  $("#project_is_test").click(function(e){
    if(this.checked){
      $("input[name='project[visibility]']").prop('disabled', true);
      $(".is-test-label").show();
    }else{
      $("input[name='project[visibility]']").prop('disabled', false);
      $(".is-test-label").hide();
    }
  });
  
  // Handle the 'test' flag on page load
  // ----------------------------------------------------------
  if($("#project_is_test").checked){
    $("input[name='project[visibility]']").prop('disabled', true);
    $(".is-test-label").show();
  }else{
    $("input[name='project[visibility]']").prop('disabled', false);
    $(".is-test-label").hide();
  }

});
