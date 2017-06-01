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
    $("form.answer fieldset textarea").change(function(){
        console.log('textarea changed');
    });
    // TODO An adequate listener for textarea (e.g. tinymce) that triggers unsaved.show(). Temporary workaround defined at $.fn.toggle_dirty (plans.js)
    $.fn.init_answer_status = function() {
        $('abbr.timeago').timeago();
    }
    $.fn.init_answer_status();
});