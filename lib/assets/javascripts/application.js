// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require v1.js
//= require jquery.placeholder.js
//= require jquery-ui.min.js
//= require jquery.tablesorter.min.js
//= require jquery-accessible-autocomplet-list-aria.js
//= require tinymce-jquery
//= require i18n
//= require i18n/translations
//= require_tree ./locale
//= require gettext/all
//= require roadmap-utils.js
//= require roadmap-form.js
//= require roadmap-tabs.js
//= require roadmap-modals.js
//= require roadmap-tables.js
//= require shared/login_form.js
//= require shared/register_form.js

$( document ).ready(function() {

  $('.accordion-body').on('show', function() {
    var plus = $(this).parent().children(".accordion-heading").children(".accordion-toggle").children(".icon-plus").removeClass("icon-plus").addClass("icon-minus");
  }).on('hide', function(){
    var minus = $(this).parent().children(".accordion-heading").children(".accordion-toggle").children(".icon-minus").removeClass("icon-minus").addClass("icon-plus");
  });

  //accordion home page
  $('.accordion-home').on('show', function() {
    var plus = $(this).parent().find(".plus-laranja").removeClass("plus-laranja").addClass("minus-laranja");
  }).on('hide', function(){
    var minus = $(this).parent().find(".minus-laranja").removeClass("minus-laranja").addClass("plus-laranja");
  });

  //accordion project details page when project has more than 1 plan
  $('.accordion-project').on('show', function() {
    var plus = $(this).parent().children(".accordion-heading").find(".plus-laranja").removeClass("plus-laranja").addClass("minus-laranja");
  }).on('hide', function(){
    var minus = $(this).parent().children(".accordion-heading").find(".minus-laranja").removeClass("minus-laranja").addClass("plus-laranja");
  });

	$('.export-format-selection').click(function(e){
		e.preventDefault();
		if($(this).val() == 'pdf'){
			$('#pdf-format-options').show();
		}else{
			$('#pdf-format-options').hide();
		}
	});

  //$('#3-or-4-splash').modal();


//  $(".help").popover();

//  $('.has-tooltip').tooltip({
//        placement: "right",
//        trigger: "focus"
//  });

  $(".show-edit-toggle").click(function (e) {
    e.preventDefault();
    
    $(".edit-plan-details").toggle();
    $(".show-plan-details").toggle();
  });

  $(".toggle-existing-user-access").change(function(){
    $(this).closest("form").submit();
  });

  $("#unlink-shibboleth-confirmed").click(function (){
        $("#unlink_flag").val('true');
    $("#edit_user").submit();
    
  });

  //Question Options
  // ---------------------------------------------------------------------------
  $(".options_table").on("click", ".remove-option", function(e){
    e.preventDefault();
    
    // Mark the option for removal 
    $($(this).siblings()[0]).val(true);
    
    // Hide the entire table row and the associated hidden field for the item
    $(this).parent().parent().addClass('hidden');
  });
  
  $(".add-option").click(function(e){
    e.preventDefault();

    var tbl = $(this).parent().find("table.options_table > tbody.options_tbody"),
        last = tbl.find("tr:last"),
        clone = last.clone();
        nbr = parseInt(last.find(".number_field").val());
  
    // Update the input field names and ids
    clone.find("input").each(function(index){
      $(this).prop("id", $(this).prop("id").replace(/_\d+_/g, "_" + nbr + "_"));
      $(this).prop("name", $(this).prop("name").replace(/\[\d+\]/g, "[" + nbr + "]"));
    });
  
    // Remove the hidden class and make sure the new row is not marked for removal
    clone.removeClass('hidden');
    clone.find("[id$=" + nbr + "__destroy]").val(false);
  
    // Default the other values
    clone.find("[id$=" + nbr + "_number]").val("" + (nbr + 1));
    clone.find("[id$=" + nbr + "_text]").val("");
    clone.find("[id$=" + nbr + "_is_default]").prop("checked", false);
    
    last.after(clone);
  });

  /*$('#continue-to-new').click(function(e){
    var destination = $(this).attr("href");
    var n = destination.lastIndexOf('=');
    destination = decodeURIComponent(destination.substring(n + 1));
    $.post('splash_logs', {destination: destination} );
    $("#3-or-4-splash").modal('hide');
    return false;
  });*/

});

// ---------------------------------------------------------------------------
function selectItemsFromJsonArray(array, selector, array_of_values, callback){
  var out = [];
  
  if(!Array.isArray(array_of_values)){
    array_of_values = [array_of_values];
  }

  for(var i = 0; i < array.length; i++){
    if(array_of_values.indexOf('' + array[i][selector]) >= 0){
      out.push(array[i]);
    }
  }
  
  var selectItemsFromJsonArrayInterval = setInterval(function(){
    if(i >= array.length){
      clearInterval(selectItemsFromJsonArrayInterval);
      callback(out);
    }
  }, 50);
}
