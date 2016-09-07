$( document ).ready(function() {

	$(".select2-container").select2();

/*  
  $("#project_funder_id").select2({
    placeholder: "Select a funder"
  });
*/
	/* ------------------------------------------------- */
  $("#project_funder_id").change(function () {
		// filter the template and guidance options based on the selected funder
    update_template_options();
    update_guidance_options();
		
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

	/* ------------------------------------------------- */
  $("#no-funder").click(function(e) {
    e.preventDefault();
    $("#project_funder_id").select2("val", "");
    update_template_options();
    update_guidance_options();
    $("#institution-control-group").show();
    $("#create-plan-button").show();
    $("#other-funder-name").show();
    $("#confirm-funder").text(I18n.t("helpers.none"));
  });

	/* ------------------------------------------------- */
  $("#project_funder_name").change(function(){
    $("#confirm-funder").text($(this).val());
  });

	/* ------------------------------------------------- */
  $("#project_institution_id").change(function () {
    update_template_options();
    update_guidance_options();
    $("#confirm-institution").text($("#project_institution_id").select2('data').text);
  });

	/* ------------------------------------------------- */
  $("#no-institution").click(function() {
    $("#project_institution_id").select2("val", "");
    update_template_options();
    update_guidance_options();
    $("#confirm-institution").text(I18n.t("helpers.none"));
  });

	/* ------------------------------------------------- */
  $("#project_dmptemplate_id").change(function (f) {
    //update_guidance_options();
    $("#confirm-template").text($("#project_dmptemplate_id :selected").text());
  });

	/* ------------------------------------------------- */
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

	/* ------------------------------------------------- */
  $("#new-project-cancelled").click(function (){
    $("#project-confirmation-dialog").modal("hide");
    $('.select2-choice').show();
  });

	/* ------------------------------------------------- */
  $("#new-project-confirmed").click(function (){
    $("#new_project").submit();
  });

	/* ------------------------------------------------- */
  //for the default template alert
  $("#default-template-confirmation-dialog").on("show", function(){
    $('.select2-choice').hide();
  });

	/* ------------------------------------------------- */
  $("#default-template-cancelled").click(function (){
    $("#default-template-confirmation-dialog").modal("hide");
    $('.select2-choice').show();
  });

	/* ------------------------------------------------- */
  $("#default-template-confirmed").click(function (){
    $("#default_tag").val('true');
    $("#new_project").submit();
  });

	/* ------------------------------------------------- */
  function update_template_options() {
    select_element = $("#project_dmptemplate_id");
    select_element.find("option").remove();
    
		var orgs = [$("#project_funder_id").val(),
								$("#project_institution_id").val()];
		
		// select all of the templates available to the funder and/or institution
		selectItemsFromJsonArray(templates, 'organisation', orgs, function(array){
	    for(var i = 0; i < array.length; i++){
	      var selected = false
	      if($("#project_dmptemplate_id").val() == array[i]['id']){
	        selected = true; 
	      }

	      select_element.append("<option value='" + array[i]['id'] + "'" +
	                              (selected ? " selected='selected'" : "") +
	                            ">" + array[i]['title'] + "</option>");
	    }
	    
			if(array.length > 2){
	      $("#template-control-group").show();
	    }else{
	      $("#template-control-group").hide();
	    }
		});
    
    $("#confirm-template").text("");
    $("#project_dmptemplate_id").change();
  }

	/* ------------------------------------------------- */
  function update_guidance_options() {
    var institution = $("#project_institution_id").select2('val');
    var template = $("#project_dmptemplate_id :selected").val();
    var options = null;
    
    options_container = $("#guidance-control-group");
    options_container = options_container.find(".choices-group");
    options_container.empty();
        
		var orgs = [$("#project_funder_id").val(),
								$("#project_institution_id").val()];

		// select all of the templates available to the funder and/or institution
		selectItemsFromJsonArray(guidance_groups, 'organisation', orgs, function(array){
			for(var i = 0; i < array.length; i++){
				var selected = false
    
	      options_container.append(
						"<li class=\"choice\">" +
	              "<label for=\"project_guidance_group_ids_" + array[i]['id'] + "\">" +
	              "<input id=\"project_guidance_group_ids_" + array[i]['id'] + "\" " +
	                     "name=\"project_guidance_group_ids_" + array[i]['id'] + "\" " +
	                     "value=\"" + array[i]['id'] + "\" type=\"checkbox\" />" +
	              array[i]['name'] + "</label>" +
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
