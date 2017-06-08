//= require jquery.timeago.js

$(document).ready(function(){
    $("form.answer").submit(function(){
        var container = $(this).closest('.question-form');
        var saving = container.find('.saving-message');
        saving.show();
    });
    $("form.answer fieldset input, form.answer fieldset select").change(function(){
        var unsaved = $(this).closest('.question-form').find('.answer-unsaved');
        unsaved.show();
        var notAnswered = $(this).closest('.question-form').find('.not-answered');
        notAnswered.hide();
    });
    $.fn.change_answer = function(editor){
        editor.on('change', function(event){
            var unsaved = $('#'+editor.id).closest('.question-form').find('.answer-unsaved');
            unsaved.show();
            var notAnswered = $('#'+editor.id).closest('.question-form').find('.not-answered');
            notAnswered.hide();
        });
    }
    $.fn.init_answer_status = function() {
        $('abbr.timeago').timeago();
    }
    $.fn.init_answer_status();
});