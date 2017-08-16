//= require tinymce
/*
**Project: DMPRoadmap
**Description: This file include all javascript regarding admin interface
**Copyright: Digital Curation Centre and California Digital Library
*/


$( document ).ready(function() {
    /*----------------
        Listener for removing a question_option for option_based questions
        Note the usage of event-delegation approach through the presence of the selector (e.g. .remove-option) which means the handler
        is ONLY called when the event occurs at .remove-option and has the advantage of processing events from descendant elements (e.g. tr class="options_content") 
        that are added to the document at a later time
    ------------------*/
    $('.options_table').on('click','.remove-option', function(e){
        e.preventDefault();
        $(this).prev().val(true);
        $(this).closest('.options_content').hide();
    });
    /*----------------
        Listener for adding a question_option for option_based questions
    ------------------*/
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

	if($('.in').length > 0) {
		if ($('.in .current_question').length > 0) {
			$(document.body).animate({
				'scrollTop': $('.in .current_question').offset().top
			}, 1000);
		}
		else {
			$(document.body).animate({
				'scrollTop': $('.in').offset().top
			}, 1000);
		}
	}

    // This handler serves to display/hide default_answer field as well as to display/hide question_options fields
    // depending on the question_format selected
    $('.question_format').change(function(){
        var selected = $(this).val();
        var question_div = $(this).closest('.question-div');
        if(selected === '1' || selected === '2') {    
            question_div.find('.ques_format_option').hide();
            question_div.find('.default_answer').show();
            if(selected === '1') {  //textarea
                question_div.find('.default_answer_textfield').hide();
                question_div.find('.default_answer_textarea').prev().show()
            }
            else {  //textfield
                question_div.find('.default_answer_textarea').prev().hide();
                question_div.find('.default_answer_textfield').show();
            }
        }
        else if(selected === '3' || selected === '4' || selected === '5' || selected === '6') {  // option_based
            question_div.find('.default_answer').hide();
            question_div.find('.ques_format_option').show();
        }  
    });

	 //action for show or hide template editing display
	 $('#edit_template_button').click(function(e){
		 e.preventDefault();

		 $('#edit_template_div').show();
		 $('#show_template_div').hide();
	 });


	 //action for show or hide phase display
	 $('#edit_phase_button').click(function(e){
		 e.preventDefault();
		 $('#edit_phase_div').show();
		 $('#show_phase_div').hide();
	 });

	 //action to hide the alert to edit a version
	 $("#edit-version-confirmed").click(function (e){
		 $("#version_edit_alert").modal("hide");
	 });

	 //action to clone/add a version
	 $("#clone-version-confirmed").click(function (){
		$("#new_project").submit();
	 });

	 //action for show question editing display
	 $('.edit_question_button').click(function(e){
		 var q_id = $(this).prev(".question_id").val();
		 $('#edit_question_div_'+ q_id).show();
		 $('#show_question_div_'+ q_id).hide();
		 e.preventDefault();
	 });


	$(".cancel_edit_question").click(function(e){
		 var q_id = $(this).prev(".question_id").val();
		 $('#edit_question_div_'+ q_id).hide();
		 $('#show_question_div_'+ q_id).show();
		 e.preventDefault();
	 });

	 //action for adding a new question
	 $('.add_question_button').click(function(e){
         var s_id = $(this).prev(".section_id").val();
         $('#add_question_block_div_'+ s_id).show();
         $('#add_question_button_div_'+ s_id).hide();
         e.preventDefault();

	 });

    //if question text area is empty send alert
    $('.new_question_save_button').click(function(e){
        var s_id = $(this).prev(".section_id").val();
        if ($('#new_question_text_'+ s_id).tinymce().getContent() === ''){
            alert(__('Question text is empty, please enter your question.'));
            return false;
        }
    });

	 //action for cancelling a new question
	 $('.cancel_add_new_question').click(function(e){
        var s_id_new = $(this).prev(".section_id_new").val();
        $('#add_question_block_div_'+ s_id_new).hide();
        $('#add_question_button_div_'+ s_id_new).show();
        e.preventDefault();
	 });

	 //action for adding a new section
	 $('#add_section_button').click(function(e){
		 $('#add_section_block_div').show();
		 $('#add_section_button_div').hide();
		 e.preventDefault();
	 });


	 //action for cancelling a new section
	 $('#cancel_add_section').click(function(e){
		 $('#add_section_block_div').hide();
		 $('#add_section_button_div').show();
		 e.preventDefault();
	 });

	//ANNOTATIONS
	//action for adding a new annotation
	 $('.add_annotations_button').click(function(e){
		 var q_id = $(this).prev(".question_id").val();
		 $('#add_annotations_block_'+ q_id).show();
		 $('#add_annotations_button_'+ q_id).hide();
		 e.preventDefault();
	 });

	 //cancelling edit of an annotation
	 $(".cancel_edit_annotations").click(function(e){
		 var q_id = $(this).prev(".question_id").val();
     $('#edit_annotations_div_'+ q_id).hide();
     $('#show_annotations_div_'+ q_id).show();
		 e.preventDefault();
	 });

   //cancelling addition of an annotation
   $(".cancel_add_annotations").click(function(e){
     var q_id = $(this).prev(".question_id").val();
     $('#add_annotations_block_'+ q_id).hide();
     $('#add_annotations_button_'+ q_id).show();
     e.preventDefault();
   });

	 //edit an annotation
	 $('.edit_form_for_annotations').click(function(e){
		 var q_id = $(this).prev(".question_id").val();
		 $('#edit_annotations_div_'+ q_id).show();
		 $('#show_annotations_div_'+ q_id).hide();
		 e.preventDefault();
	 });

  //GUIDANCE
	//action for adding a new guidance next to the question
	 $('.add_guidance_button').click(function(e){
		 var q_id = $(this).prev(".question_id").val();
		 $('#add_guidance_block_'+ q_id).show();
		 $('#add_guidance_button_'+ q_id).hide();
		 e.preventDefault();
	 });

	 //cancelling edit of guidance next to the question
	 $(".cancel_guidance_answer").click(function(e){
		 var q_id = $(this).prev(".question_id").val();
		 $('#edit_guidance_div_'+ q_id).hide();
		 $('#show_guidance_div_'+ q_id).show();
		 e.preventDefault();
	 });

	 //edit guidance next to the question
	 $('.edit_form_for_guidance').click(function(e){
		 var q_id = $(this).prev(".question_id").val();
		 $('#edit_guidance_div_'+ q_id).show();
		 $('#show_guidance_div_'+ q_id).hide();
		 e.preventDefault();
	 });


    //Add new guidance Alerts
    $("#return_to_new_guidance").click(function(){
        $('#new_guidance_alert_dialog').modal("hide");
    });

// TODO: This seems to duplicate the functionality in #edit_guidance_submit
    $('#new_guidance_submit').click( function(e){
       // $('#new_guidance_alert_dialog').on("hide", function(){

        var alert_message = [];
        //verify if text area is not nil
        var editorContent = tinyMCE.get('guidance-text').getContent();
        if (editorContent == ''){
            alert_message.push(__('add guidance text'));
        }
        //verify if themes are selected
        if($('#guidance_theme_ids').val() == undefined || $('#guidance_theme_ids').val() == ''){
          alert_message.push(__('select at least one theme'));
        }
        //verify if guidance group is selected
        if ( ($('#guidance_guidance_group_id').val() == '') || $('#guidance_guidance_group_id').val() == undefined ) {
            alert_message.push(__('select a guidance group'));
        }
        if(alert_message.length == 0){
            //clear dropdowns before submission
            $('#new_guidance_alert_dialog').modal("hide");

            if ($('#g_options').val() == '2'){
                $('#guidance_theme_ids').val(null);
            }
            if($('#g_options').val() == '1'){
                $('#questions_select').val(null);
            }
            $('#new_guidance_form').submit();
           return false;

        }
        else if (alert_message.length != 0){
            var message = '';
            $('#new_guidance_alert_dialog').on("show", function(){

                $("#missing_fields_new_guidance").empty();
                $.each(alert_message, function(key, value){
                    message += "<li> "+value+"</li>";
                });
                $("#missing_fields_new_guidance").append(message);
            });
            delete message;
        }
        delete alert_message;
        e.preventDefault();
    });

    //edit guidance alerts
    $("#return_to_edit_guidance").click(function(){
        $('#edit_guidance_alert_dialog').modal("hide");
    });


    $('#edit_guidance_submit').click( function(e){
       // $('#new_guidance_alert_dialog').on("hide", function(){

        var alert_message = [];
        //verify if text area is not nil
        var editorContent = tinyMCE.get('guidance-text').getContent();
        if (editorContent == ''){
            alert_message.push(__('add guidance text'));
        }
        //verify dropdown with questions has a selected option if guidance for a question being used
        if($('#guidance_theme_ids').val() == undefined || $('#guidance_theme_ids').val() == ''){
          alert_message.push(__('select at least one theme'));
        }
        //verify if guidance group is selected
        if ( ($('#guidance_guidance_group_id').val() == '') || $('#guidance_guidance_group_id').val() == undefined  ) {
            alert_message.push(__('select a guidance group'));
        }

        if(alert_message.length == 0){
            //clear dropdowns before submission
            $('#edit_guidance_alert_dialog').modal("hide");

            if ($('#g_options').val() == '2'){ $('#guidance_theme_ids').val(null);}
            if($('#g_options').val() == '1'){$('#questions_select').val(null);}
            $('#edit_guidance_form').submit();
           return false;
        }
        else if (alert_message.length != 0){
            var message = '';
            $('#edit_guidance_alert_dialog').on("show", function(){

                $("#missing_fields_edit_guidance").empty();
                $.each(alert_message, function(key, value){
                    message += "<li> "+value+"</li>";
                });
                $("#missing_fields_edit_guidance").append(message);
            });
            delete message;
        }
        delete alert_message;
        e.preventDefault();
    });


    //Validate banner_text area for less than 165 character
    $("form#edit_org_details").submit(function(){
        if (getStats('org_banner_text').chars > 165) {
            alert(__('Please only enter up to 165 characters, you have used') + " " + getStats('org_banner_text').chars + ". " + __('If you are entering an URL try to use something like http://tinyurl.com/ to make it smaller.'));
            return false;
        }
    });




 });


//remove option when question format is base on a choice
function remove_object(link){
	$(link).prev("input[type=hidden]").val("1");
	$(link).closest(".options_content").hide();

}
function add_object(link, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");

    if (association == 'options') {
        $(link).parent().children('.options_table').children('.options_tbody').children('.new_option_before').before(content.replace(regexp, new_id));
    }
}

// Returns text statistics for the specified editor by id
function getStats(id) {
    var body = tinymce.get(id).getBody(), text = tinymce.trim(body.innerText || body.textContent);

    return {
        chars: text.length
    };
}