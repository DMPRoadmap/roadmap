//= require jquery.timeago.js
//= require tinymce

var dirty = {};



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
			message = I18n.t("you_have_unsaved_in_sections");
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
		submit_button.parent().hide();
		q_id = $(this).find(".question_id").val();
		saving_message.show();
		s_status = $(this).closest(".accordion-group").find(".section-status:first");
		s_status.toggle_dirty(q_id, false);
		// Allow quarter of a second for database to update
		timeout = setTimeout(function(){
			$.getJSON("status.json", function(data) {
				$.fn.update_plan_progress(data);
				$.fn.update_timestamp(q_id, data);
				s_status.update_section_progress(data);
				submit_button.parent().show();
				saving_message.hide();
			});
		},250);
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

	// Periodically check locks on open section - every 50 seconds
	setInterval(function(){
		// Only lock/unlock if there are forms on the page (not read-only)
		if ($('.question-form').length > 0) {
			section = $('.section-collapse.in');
			if (section.length > 0) {
				section.check_section_lock();
			}
    }
	}, 50000);

	// Handle section actions on accordion expansion/collapse
	$('.section-collapse').on('show', function() {
		var section = $(this);
        section.find(".loaded").hide();
		section.find(".loading").show();
		// Only lock if there are forms on the page (not read-only)
		if ($('.question-form').length > 0) {
			section.check_section_lock();
    }
    // check for updated answers
    $.getJSON("status.json", function(data) {
    	$.fn.update_plan_progress(data);
    	$(".section-status").each(function(){
    		$(this).update_section_progress(data);
    	});
    	//For each question in section, check answer timestamp against currently displayed
        var section_id = section.attr("id").split('-')[1];
    	var num_questions = data.sections[section_id]["questions"].length;
    	for (var i = 0; i < num_questions; i++) {
    		question_id = data.sections[section_id]["questions"][i];
    		//If timestamp newer than displayed, update answers
    		if ($.fn.update_timestamp(question_id, data)) {
    			$.fn.update_answer(question_id);
    		}
    	}
    	section.find(".loading").hide();
		section.find(".loaded").show();
    });
   }).on('hide', function(){
  	var section = $(this);
  	// Only attempt unlock if there are forms on the page (not read-only)
  	if ($('.question-form').length > 0) {
			var section_id = section.attr("id").split('-')[1];
			// LIBDMP-137
			// Changed post request 'unlock_section' to  'unlock_section.json'. 'unlock_section' unnecessary returns a huge html response and takes a quite lot of time to process(3sec) lowering server 
			// performance when there are large number of concurrent users.
			$.post('unlock_section.json', {section_id: section_id});
            
			if ($.fn.is_dirty(section_id)) {
				$('#unsaved-answers-'+section_id).text("");
				$.each($.fn.get_unsaved_questions(section_id), function(index, question_text){
					$('#unsaved-answers-'+section_id).append("<li>"+question_text+"</li>");
				});
				$('#section-' + section_id + '-collapse-alert').modal();
			}
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
    
    //action for show add comment block
    $('.add_comment_button').click(function(e){
        var q_id = $(this).closest(".comment-area").find(".question_id").val();
        $('.view_comment_class').hide();
        $('.edit_comment_class').hide();
        $('.archive_comment_class').hide();
        $('#add_comment_button_bottom_div_'+ q_id).hide();
        $('#add_comment_button_top_div_'+ q_id).hide();
        $('#add_comment_block_div_'+ q_id).show();
        e.preventDefault();
    });
    
    //submit new comment button
    $('.new_comment_submit_button').click(function(e){
        var q_id = $(this).parent().children(".question_id").val();
        var s_id = $(this).parent().children(".section_id").val();
        
        $("#collapse-" + s_id).children(".accordion-inner").find(".saving").show();
        $("#collapse-" + s_id).children(".accordion-inner").find(".loaded").hide();
        $(".alert-notice").hide();
        $("#new_comment_form_" + q_id).submit();
        
    });
    
     //action to view a comment block
    $('.view_comment_button').click(function(e){
        var c_id = $(this).next(".comment_id").val();
        var q_id = $(this).closest(".comment-area").find(".question_id").val();
        $('.view_comment_class').hide();
        $('.edit_comment_class').hide();
        $('.archive_comment_class').hide();
        $('#lastet_comment_div_'+ q_id).hide();
        $('#edit_comment_div_'+ c_id).hide();
        $('#archive_comment_div_'+ c_id).hide();
        $('#add_comment_block_div_'+ q_id).hide();
        $('#view_comment_div_'+ c_id).show();
        $('#add_comment_button_bottom_div_'+ q_id).show();
        $('#add_comment_button_top_div_'+ q_id).show();
        e.preventDefault();
    });
  
    //action to edit a comment block
    $('.edit_comment_button').click(function(e){
        var c_id = $(this).prev(".comment_id").val();
        var q_id = $(this).closest(".comment-area").find(".question_id").val();
        $('.edit_comment_class').hide();
        $('.view_comment_class').hide();
        $('.archive_comment_class').hide();
        $('#lastet_comment_div_'+ q_id).hide();
        $('#view_comment_div_'+ c_id).hide();
        $('#archive_comment_div_'+ c_id).hide();
        $('#add_comment_block_div_'+ q_id).hide();
        $('#edit_comment_div_'+ c_id).show();
        $('#add_comment_button_bottom_div_'+ q_id).show();
        $('#add_comment_button_top_div_'+ q_id).show();
        e.preventDefault();
    });
    
     //submit edit comment button
    $('.edit_comment_submit_button').click(function(e){
        var c_id = $(this).parent().children(".comment_id").val();
        var s_id = $(this).parent().children(".section_id").val();
        
        $("#collapse-" + s_id).children(".accordion-inner").find(".saving").show();
        $("#collapse-" + s_id).children(".accordion-inner").find(".loaded").hide();
        $(".alert-notice").hide();
        $("#edit_comment_form_" + c_id).submit();
        
    });
    
    //action to archive a comment block
    $('.archive_comment_button').click(function(e){
        var c_id = $(this).prev(".comment_id").val();
        var q_id = $(this).closest(".comment-area").find(".question_id").val();
        $('.edit_comment_class').hide();
        $('.view_comment_class').hide();
        $('.archive_comment_class').hide();
        $('#view_comment_div_'+ c_id).hide();
        $('#lastet_comment_div_'+ q_id).hide();
        $('#edit_comment_div_'+ c_id).hide();
        $('#add_comment_block_div_'+ q_id).hide();
        $('#archive_comment_div_'+ c_id).show()
        $('#add_comment_button_bottom_div_'+ q_id).show();
        $('#add_comment_button_top_div_'+ q_id).show();
        e.preventDefault();
    });
    
     //submit archived comment button
    $('.archive_comment_submit_button').click(function(e){
        var c_id = $(this).parent().children(".comment_id").val();
        var s_id = $(this).parent().children(".section_id").val();
        
        $("#collapse-" + s_id).children(".accordion-inner").find(".removing").show();
        $("#collapse-" + s_id).children(".accordion-inner").find(".loaded").hide();
        $(".alert-notice").hide();
        $("#archive_comment_form_" + c_id).submit();
        
    });
    
    //action to cancel archive block
    $(".cancel_archive_comment").click(function(e){
		var c_id = $(this).prev(".comment_id").val();
        $('.archive_comment_class').hide();
        $('#view_comment_div_'+ c_id).show();
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

$.fn.update_answer = function(question_id) {
	$.ajax({
		type: 'GET',
		url: "answer.json?q_id="+question_id,
		dataType: 'json',
		async: false, //Needs to be synchronous, otherwise end up mixing up answers
		success: function(data) {
			if (data != null) {
				//Get divs containing the form and readonly versions
				var form_div = $("#question-form-"+question_id);
				var readonly_div = $("#question-readonly-"+question_id);
				//Look for textfields
				if ($("input#answer-text-"+question_id).length == 1) {
					$("input#answer-text-"+question_id).val(data.text);
					readonly_div.find('.answer-text-readonly').html("<p>"+data.text+"</p>");
				}
				else {
					//Update answer text - both in textarea and readonly
					$('#answer-text-'+question_id).val(data.text);
					tinymce.get('answer-text-'+question_id).setContent(data.text);
					readonly_div.find('.answer-text-readonly').html(data.text);
				}
				//Update answer options - both in form and readonly
				num_options = data.options.length;
				form_div.find('option').each(function(){
					var selected = false;
					for (var j =0; j < num_options; j++) {
						if ($(this).val() == data.options[j].id) {
							selected = true;
						}
					}
					if (selected) {
						$(this).attr('selected', 'selected');
					}
					else {
						$(this).removeAttr('selected');
					}
				});
				form_div.find(':checkbox,:radio').each(function(){
					var selected = false;
					for (var j =0; j < num_options; j++) {
						if ($(this).val() == data.options[j].id) {
							selected = true;
						}
					}
					if (selected) {
						$(this).attr('checked', 'checked');
					}
					else {
						$(this).removeAttr('checked');
					}
				});

				var list_string = "";
				for (var j =0; j < num_options; j++) {
					list_string += "<li>"+data.options[j].text+"</li>";
				}
				readonly_div.find('.options').html(list_string);
				form_div.closest(".accordion-group").find(".section-status:first").toggle_dirty(question_id, false);
			}
		}
	});
    
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
	$("#questions-progress-title").text(data.num_answers+"/"+data.num_questions + " " + I18n.t("helpers.project.questions_answered"));
	$('#export-progress').css('width', data.space_used + '%');
	$("#export-progress-title").text(I18n.t("helpers.plan.export.space_used_without_max", {space_used: data.space_used}));
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

$.fn.update_timestamp = function(question_id, data) {
	q_status = $('#'+question_id+'-status');
	var t = q_status.children("abbr:first");
	var current_timestamp = new Date(t.attr('data-time'));
	var timestamp = data.questions[question_id]["answer_created_at"];
	if (timestamp != null) {
		timestamp = new Date(Number(timestamp) * 1000);
		if (timestamp.getTime() != current_timestamp.getTime()) {
			q_status.text("");
			q_status.append(I18n.t("helpers.answered_by") + " <abbr class='timeago'></abbr> " + I18n.t("helpers.answered_by_part2") + " " + data.questions[question_id]["answered_by"]);
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

$.fn.check_section_lock = function() {
	var section = $(this);
   	var section_id = section.attr("id").split('-')[1];
	$.getJSON("locked?section_id="+section_id, function(data) {
		if (data.locked) {
			section.find(".section-lock-notice").html("<p>" + I18n.t("helpers.project.share.locked_section_text") + data.locked_by + ".</p>");
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

$.fn.check_textarea = function(editor) {
     $("#"+editor.id).closest(".accordion-group").find(".section-status:first").toggle_dirty(editor.id.split('-')[2], editor.isDirty());
       
};





