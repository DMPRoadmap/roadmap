//= require jquery.timeago.js

$(document).ready(function(){
    $("form.answer").submit(function(){
        var saving = $(this).find('.saving-message');
        saving.show();
    });
    $("form.answer fieldset input, form.answer fieldset select").change(function(){
        var unsaved = $(this).closest('form.answer').find('.answer-unsaved');
        unsaved.show();
    });
    // TODO An adequate listener for textarea (e.g. tinymce) that triggers unsaved.show(). Temporary workaround defined at $.fn.toggle_dirty (plans.js)
    $.fn.init_answer_status = function() {
        $('abbr.timeago').timeago();
    }
    $.fn.init_answer_status();
});