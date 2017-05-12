//= require jquery.timeago.js
//= require tinymce
//= require tinymce-jquery

var dirty = {};



// functions added to buttons and links in the notes section of the answer form

// the "add note" button
function add_note_button(q_id){
        $(".alert-notice").hide();
        $('.view_comment_class').hide();
        $('.edit_comment_class').hide();
        $('.archive_comment_class').hide();
        //$('#add_comment_button_bottom_div_'+ q_id).hide();
        $('#add_comment_button_top_div_'+ q_id).hide();
        //$('#{questionid}new_note_text').text("");
        $('#add_comment_block_div_'+ q_id).show();
}

// the "view" link
function view_note_button(c_id, q_id){
        $(".alert-notice").hide();
        $('.view_comment_class').hide();
        $('.edit_comment_class').hide();
        $('.archive_comment_class').hide();
        $('#lastet_comment_div_'+ q_id).hide();
        $('#edit_comment_div_'+ c_id).hide();
        $('#archive_comment_div_'+ c_id).hide();
        $('#add_comment_block_div_'+ q_id).hide();
        $('#view_comment_div_'+ c_id).show();
        $('#add_comment_button_top_div_'+ q_id).show();
}


// the "edit" link
function edit_note(c_id, q_id){
        $('.edit_comment_class').hide();
        $('.view_comment_class').hide();
        $('.archive_comment_class').hide();
        $('#lastet_comment_div_'+ q_id).hide();
        $('#view_comment_div_'+ c_id).hide();
        $('#archive_comment_div_'+ c_id).hide();
        $('#add_comment_block_div_'+ q_id).hide();
        $('#edit_comment_div_'+ c_id).show();
        $('#add_comment_button_top_div_'+ q_id).show();
}


//the "remove" link
function archive_note(c_id, q_id){
        $('.edit_comment_class').hide();
        $('.view_comment_class').hide();
        $('.archive_comment_class').hide();
        $('#view_comment_div_'+ c_id).hide();
        $('#lastet_comment_div_'+ q_id).hide();
        $('#edit_comment_div_'+ c_id).hide();
        $('#add_comment_block_div_'+ q_id).hide();
        $('#archive_comment_div_'+ c_id).show()
        $('#add_comment_button_top_div_'+ q_id).show();
}
    
// cancel remove
function cancel_archive_note(c_id) {
		var c_id = $(this).prev(".comment_id").val();
        $('.archive_comment_class').hide();
        $('#view_comment_div_'+ c_id).show();
}




// adding functionality on page load

$( document ).ready(function() {

   //reload page back to where it was before committing comment
       
    if($('#comment_section_id').length) {
        var section_id = $('#comment_section_id').val();
        
        $("#collapse-" + section_id).addClass("in");
        $("#collapse-" + section_id).children(".accordion-inner").find(".loading").show();
        $("#collapse-" + section_id).children(".accordion-inner").find(".loaded").hide();
        
        setTimeout(function(){
            $("loaded").find(".section-lock-notice").html("");
            $("loaded").find(".section-lock-notice").hide();
            $(".question-form").find("select").removeAttr('disabled');
            $(".question-div").find(".question-readonly").hide();
            $(".question-div").find(".question-form").show();
                    
            $("#collapse-" + section_id).children(".accordion-inner").find(".loading").hide();
            $("#collapse-" + section_id).children(".accordion-inner").find(".loaded").show();
            $('html, body').animate({
                    'scrollTop': $("#current_question").offset().top
                    },1000);
        },8000);
    }

	window.onbeforeunload = function(){
		var message = null;
		if ($.fn.is_dirty()) {
			var questions = $.fn.get_unsaved_questions();
			message = __('You have unsaved answers in the following sections:')
			$.each(questions, function(section_text, question_texts){
				message += "\n\u2022"+section_text;
			});
		  return message;
		}
	};

	// Make timestamps readable
	$('abbr.timeago').timeago();

	// Update status messages on form submission
	$("form.answer").submit(function(){
		var submit_button = $(this).find('input[type="submit"]');
		var saving_message = $(this).find('.saving-message');
		submit_button.hide();
		q_id = $(this).find(".question_id").val();
		saving_message.show();
		s_status = $(this).closest(".accordion-group").find(".section-status:first");
		s_status.toggle_dirty(q_id, false);
	});

	//accordion guidance
	$('.accordion-guidance-link').on('click', function (e) {
		e.stopPropagation();
		var show = true;
		var div_to_toggle = $($(this).attr("href"));
		if (div_to_toggle.hasClass('in')) {
			show = false;
		}
		$($(this).attr("href")).toggleClass("in");
		if (show) {
			$(this).children(".plus-laranja").removeClass("plus-laranja").addClass("minus-laranja");
		}
		else {
			$(this).children(".minus-laranja").removeClass("minus-laranja").addClass("plus-laranja");
		}
		delete show;
		delete div_to_toggle;
		e.preventDefault();
	});


	// Handle section actions on accordion expansion/collapse
	$('.section-collapse').on('show', function() {
	    $('abbr.timeago').timeago();
   }).on('hide', function(){
  	 var section = $(this);
     var section_id = section.attr("id").split('-')[1];
     if ($.fn.is_dirty(section_id)) {
				$('#unsaved-answers-'+section_id).text("");
				$.each($.fn.get_unsaved_questions(section_id), function(index, question_text){
					$('#unsaved-answers-'+section_id).append("<li>"+question_text+"</li>");
				});
				$('#section-' + section_id + '-collapse-alert').modal();
      }
    });

    $(".cancel-section-collapse").click(function () {
        var section_id = $(this).attr('data-section');
        $("#collapse-" + section_id).collapse("show");
        $('#section-' + section_id + '-collapse-alert').modal("hide");
    });

    $(".discard-section-collapse").click(function () {
        var section_id = $(this).attr('data-section');
        $('#section-' + section_id + '-collapse-alert').modal("hide");
    });

    $(".save-section-collapse").click(function () {
        var section_id = $(this).attr('data-section');
        $("#collapse-" + section_id).find("input[type='submit']").click();
        $('#section-' + section_id + '-collapse-alert').modal("hide");
    });

    $("select, :radio, :checkbox, input").change(function() {
        $(this).closest(".accordion-group").find(".section-status:first").toggle_dirty($(this).closest("form.answer").find(".question_id").val(), true);
    });
  
    // COMMENTS Javascript

    //action for show comment block on the right side of a question
    $('.comments_accordion_button').click(function(e){
        var q_id = $(this).closest(".question_right_column_nav").find(".question_id").val();
        $(this).parent().addClass("active");
        $(this).closest(".question_right_column_ul").find(".guidance_tab_class").removeClass("active");
        $('#guidance-question-area-'+ q_id).hide();
        $('#comment-question-area-'+ q_id).show();
        e.preventDefault();
    });
    
    //action for show guidance block on the right side of a question
    $('.guidance_accordion_button').click(function(e){
        var q_id = $(this).closest(".question_right_column_nav").find(".question_id").val();
        $(this).parent().addClass("active");
        $(this).closest(".question_right_column_ul").find(".comment_tab_class").removeClass("active");
        $('#comment-question-area-'+ q_id).hide();
        $('#guidance-question-area-'+ q_id).show();
        e.preventDefault();
    });
});

$.fn.get_unsaved_questions = function(section_id) {
	if (section_id != null) {
		var questions = new Array();
		$.each(dirty[section_id], function(question_id,value){
			if (value && question_id != 'undefined') {
				questions.push($("label[for='answer-text-"+question_id+"']").text());
			}
		});
		return questions;
	}
	else {
		var questions = {};
		$.each(dirty, function(section_id,question_ids){
			var section_text = $("#section-header-"+section_id).clone().children().remove().end().text().trim();
			questions[section_text] = new Array();
			$.each(question_ids, function(question_id,value){
				if (value && question_id != 'undefined') {
					questions[section_text].push($("label[for='answer-text-"+question_id+"']").text());
				}
			});
		});
		return questions;
	}
};

$.fn.is_dirty = function(section_id, question_id) {
   if (section_id != null) {
        if (dirty[section_id] != null) {
			if (question_id != null) {
				if (dirty[section_id][question_id] != null) {
					return dirty[section_id][question_id];
				}
				else {
					return false;
				}
			}
			else {
				var is_dirty = false;
				$.each(dirty[section_id], function(question_id, value){
					if (value && question_id != 'undefined') {
						is_dirty = true;
					}
				});
				return is_dirty;
			}
		}
	}
	else {
		var is_dirty = false;
		$.each(dirty, function(section_id, questions){
			$.each(questions, function(question_id, value){
				if (value && question_id != 'undefined') {
					is_dirty = true;
				}
			});
		});
		return is_dirty;
	}
	return false;
};


$.fn.update_section_progress = function(data) {
	s_id = $(this).attr("id").split('-')[0];
	s_qs = data.sections[s_id]["num_questions"];
	question_word = "questions"
	if (s_qs == 1) {
		question_word = "question";
	}
	s_as = data.sections[s_id]["num_answers"];
	$(this).text("("+s_qs+" "+question_word+", "+s_as+" answered)");
	if (s_qs == s_as) {
		$(this).removeClass("label-warning");
		$(this).addClass("label-info");
	}
};

$.fn.update_plan_progress = function(data) {
	$("#questions-progress").css("width", (data.num_answers/data.num_questions*100)+"%");
	$("#questions-progress-title").text(data.num_answers+"/"+data.num_questions + " " + __('questions answered'));
	$('#export-progress').css('width', data.space_used + '%');
	$("#export-progress-title").text(__('approx. %{space_used}% of available space used', {space_used: data.space_used}));
	if (data.space_used >= 100) {
		$('#export-progress').removeClass("space");
		$('#export-progress').addClass("full");
        $('#export-progress-title').addClass("bar-full-text");
	}
	else {
		$('#export-progress').removeClass("full");
		$('#export-progress').addClass("space");
        $('#export-progress-title').removeClass("bar-full-text");
	}
};

$.fn.update_question_timestamp = function(question_id) {
	q_status = $('#'+question_id+'-status');
	var t = q_status.children("abbr:first");
	var timestamp = new Date(t.attr('data-time'));
	if (timestamp != null) {
		timestamp = new Date(Number(timestamp) * 1000);
        q_status.text("");
        q_status.append( __('Answered') + " <abbr class='timeago'></abbr> " + __(' by ') + data.questions[question_id]["answered_by"]);
        t = q_status.children("abbr:first");
        // Update label to indicate successful submission
        q_status.removeClass("label-info label-warning");
        q_status.addClass("label-success");
        // Set timestamp text and data
        t.text(timestamp.toUTCString());
        t.attr('title', timestamp.toISOString()).data("timeago",null).timeago();
        t.attr('data-time', timestamp.toISOString());
        return true;
	}
	return false;
};

$.fn.update_timestamp = function(question_id, data) {
	q_status = $('#'+question_id+'-status');
	var t = q_status.children("abbr:first");
	var current_timestamp = new Date(t.attr('data-time'));
	var timestamp = data.questions[question_id]["answer_updated_at"];
	if (timestamp != null) {
		timestamp = new Date(Number(timestamp) * 1000);
		if (timestamp.getTime() != current_timestamp.getTime()) {
			q_status.text("");
      q_status.append( __('Answered') + " <abbr class='timeago'></abbr> " + __(' by ') + data.questions[question_id]["answered_by"]);
			t = q_status.children("abbr:first");
			// Update label to indicate successful submission
			q_status.removeClass("label-info label-warning");
			q_status.addClass("label-success");
			// Set timestamp text and data
			t.text(timestamp.toUTCString());
			t.attr('title', timestamp.toISOString()).data("timeago",null).timeago();
			t.attr('data-time', timestamp.toISOString());
			return true;
		}
	}
	return false;
};

// TODO: Should we drop this now that the locking check has been removed?
$.fn.check_section_lock = function() {
	var section = $(this);
   	var section_id = section.attr("id").split('-')[1];
	$.getJSON("locked?section_id="+section_id, function(data) {
		if (data.locked) {
			section.find(".section-lock-notice").html("<p>" + __('This section is locked for editing by ') + data.locked_by + ".</p>");
			section.find(".section-lock-notice").show();
			section.find("input").attr('disabled', 'disabled');
			section.find(".question-form").hide();
			section.find("select").attr('disabled', 'disabled');
			section.find(".question-readonly").show();
		}
		else {
			// LIBDMP-137
			// Changed post request 'lock_section' to  'lock_section.json'. 'lock_section' unnecessary returns a huge html response and takes a quite lot of time to process(3sec) lowering server 
			// performance when there are large number of concurrent users.
			$.post('lock_section', {section_id: section_id} ); 
			section.find(".section-lock-notice").html("");
			section.find(".section-lock-notice").hide();
			section.find("input").removeAttr('disabled');
			section.find(".question-form").show();
			section.find("select").removeAttr('disabled');
			section.find(".question-readonly").hide();
		}
	});
	return true;
};

$.fn.toggle_dirty = function(question_id, is_dirty) {
	section_id = $(this).attr("id").split('-')[0];
	if (dirty[section_id] == null) {
		dirty[section_id] = {};
	}
	dirty[section_id][question_id] = is_dirty;
	if (is_dirty) {
		$("#"+question_id+"-unsaved").show();
        
	}
	else {
		$("#"+question_id+"-unsaved").hide();
	}
};




// this is the function used to hanndle the interface between tinymce and the Dirty stuff
$.fn.check_textarea = function(editor) {
     $("#"+editor.id).closest(".accordion-group").find(".section-status:first").toggle_dirty(editor.id.split('-')[2], editor.isDirty());
       
};
