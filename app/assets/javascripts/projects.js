$( document ).ready(function() {
  $(".select2-container").select2();

  // ----------------------------------------------------------
  $("#project_funder_id").change(function(){
    reloadTemplateData();
    
    if($(this).val().length > 0){
      $("#other-funder-name").hide();
      $("#project_funder_name").val("");
      
    }else{
      $("#other-funder-name").show();
    }
    
    $("#institution-control-group").show();
    $("#create-plan-button").show();
    $("#confirm-funder").text($(this).val());
  });
  
  // ----------------------------------------------------------
  $("#project_institution_id").change(function(){
    reloadTemplateData();
    
    $("#confirm-institution").text($("#project_institution_id").select2('data').text);
  });
  
  // ----------------------------------------------------------
  $("#project_dmptemplate_id").change(function(){
    reloadGuidanceOptions();
  });
  
  // ----------------------------------------------------------
  $("#no-funder").click(function(e) {
    e.preventDefault();
    $("#project_funder_id").select2("val", "");
    $("#institution-control-group").show();
    $("#create-plan-button").show();
    $("#other-funder-name").show();
    $("#confirm-funder").text(I18n.t("helpers.none"));
  });

  // ----------------------------------------------------------
  $("#project_funder_name").change(function(){
    $("#confirm-funder").text($(this).val());
  });

  // ----------------------------------------------------------
  $("#no-institution").click(function() {
    $("#project_institution_id").select2("val", "");
    $("#confirm-institution").text(I18n.t("helpers.none"));
  });
  
  // ----------------------------------------------------------
  $("#project-confirmation-dialog").on("show", function(){
    if ($("#confirm-institution").text() == "") {
      $("#confirm-institution").text(I18n.t("helpers.none"));
    }
    if ($("#confirm-funder").text() == "") {
      $("#confirm-funder").text(I18n.t("helpers.none"));
    }
    if ($("#confirm-template").text() == "") {
      $("#confirm-template").closest("div").hide();
    }
    else {
      $("#confirm-template").closest("div").show();
    }
    $("#confirm-guidance").empty();
    $("input:checked").each(function(){
      $("#confirm-guidance").append("<li id='confirm-"+$(this).attr("id")+"'>"+$(this).parent().text()+"</li>");
    });
    $('.select2-choice').hide();
  });

  // ----------------------------------------------------------
  $("#new-project-cancelled").click(function (){
    $("#project-confirmation-dialog").modal("hide");
    $('.select2-choice').show();
  });

  // ----------------------------------------------------------
  $("#new-project-confirmed").click(function (){
    $("#new_project").submit();
  });

  // ----------------------------------------------------------
  //for the default template alert
  $("#default-template-confirmation-dialog").on("show", function(){
    $('.select2-choice').hide();
  });

  // ----------------------------------------------------------
  $("#default-template-cancelled").click(function (){
    $("#default-template-confirmation-dialog").modal("hide");
    $('.select2-choice').show();
  });

  // ----------------------------------------------------------
  $("#default-template-confirmed").click(function (){
    $("#default_tag").val('true');
    $("#new_project").submit();
  });
  
  
  // The following function references a JSON array that is
  // constructed in app/view/projects/_dropdown_new_project.html.erb
  // ----------------------------------------------------------
  function reloadTemplateData(){
    var orgs = [$("#project_funder_id").val(),
                $("#project_institution_id").val()];
                
    var template = $("#project_dmptemplate_id :selected").val();
            
    selectItemsFromJsonArray(templates, 'organisation', orgs, function(array){
      // Clear and reload the contents of the dropdown
      $("#project_dmptemplate_id").html("").select2( {data: array} ).val();

      // If there are no templates, hide the dropdown
      if(array.length <= 0){
        $("#template-control-group").hide();
        reloadGuidanceOptions();
        
      }else{
        // Select the first item in the list if there was none selected
        if(template == undefined){
          $("#project_dmptemplate_id").val(array[0]['id']).trigger('change');
        
        }else{
          reloadGuidanceOptions();
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
                       "name=\"project_guidance_group_ids_" + array[i]['id'] + "\" " +
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
});
