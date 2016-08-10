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
//= require twitter/bootstrap
//= require v1.js
//= require select2.min.js
//= require jquery.placeholder.js
//= require tinymce-jquery
//= require i18n
//= require i18n/translations


$( document ).ready(function() {

	$(function(){
		$('.dropdown-toggle').dropdown()
	});

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
		var plus = $(this).parent().find(".plus-laranja").removeClass("plus-laranja").addClass("minus-laranja");
	}).on('hide', function(){
		var minus = $(this).parent().find(".minus-laranja").removeClass("minus-laranja").addClass("plus-laranja");
	});

	//$('#3-or-4-splash').modal();

	$('.typeahead').select2({
		width: "element",
		allowClear: true
	});

	$(".help").popover();

	$('.has-tooltip').tooltip({
        placement: "right",
        trigger: "focus"
	});

	$(".show-edit-toggle").click(function (e) {
		e.preventDefault();
		
		$(".edit-project").toggle();
		$(".view-project").toggle();
	});

	$(".toggle-existing-user-access").change(function(){
		$(this).closest("form").submit();
	});

	$("#user_email.text_field.reg-input").blur(function () {
		if (validateEmail($(this).val())) {
			$(this).parent().children("div").hide();
		}
		else {
			$(this).parent().children("div").show();
		}
	});

	$("#user_password.text_field.reg-input").blur(function () {
		if ($(this).val().length >= 8) {
			$(this).parent().children("div").hide();
		}
		else {
			$(this).parent().children("div").show();
		}
	});

	$("#user_password_confirmation.text_field.reg-input").blur(function () {
		if ($(this).val() == $("#user_password.text_field.reg-input").val()) {
			$(this).parent().children("div").hide();
		}
		else {
			$(this).parent().children("div").show();
		}
	});

	$('#user_organisation_id').on("change", function(e) {
		e.preventDefault();
		var selected_org = $(this).select2("val");
		var other_orgs = $("#other-organisation-name").attr("data-orgs").split(",");
		var index = $.inArray(selected_org, other_orgs);
		if (index > -1) {
			$("#other-organisation-name").show();
			$("#user_other_organisation").focus();
		}
		else {
			$("#other-organisation-name").hide();
		}
	});

	$("#other-org-link > a").click(function(e){
		e.preventDefault();
		var other_org = $("#other-organisation-name").attr("data-orgs").split(",");
		$("#user_organisation_id").select2("val", other_org);
		$("#other-org-link").hide();
		$("#user_organisation_id").change();
	});
    
    //alert dialog for unlink Shibbileth account 
   	$("#unlink-institutional-credentials-dialog").on("show", function(){
		$('.select2-choice').hide();
	});

	$("#unlink-shibboleth-cancelled").click(function (){
		$("#unlink-institutional-credentials-dialog").modal("hide");
		$('.select2-choice').show();
	});

	$("#unlink-shibboleth-confirmed").click(function (){
        $("#unlink_flag").val('true');
		$("#edit_user").submit();
		
	});

	//Question Options
	// ------------------------------------------------------------------------------------
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

function validateEmail(sEmail) {
  var filter = /^[a-zA-Z0-9]+[a-zA-Z0-9_.-]+[a-zA-Z0-9_-]+@[a-zA-Z0-9]+[a-zA-Z0-9.-]+[a-zA-Z0-9]+.[a-z]{2,4}$/;
  if (filter.test(sEmail)) {
    return true;
  }
  else {
    return false;
  }
}
