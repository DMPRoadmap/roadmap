(function(ctx){
    ctx.archive = ctx.archive || (function(noteId, questionId){
        if($ && noteId && questionId) {
            $('.edit_comment_class').hide();
            $('.view_comment_class').hide();
            $('.archive_comment_class').hide();
            $('#view_comment_div_'+ noteId).hide();
            $('#lastet_comment_div_'+ questionId).hide();
            $('#edit_comment_div_'+ noteId).hide();
            $('#add_comment_block_div_'+ questionId).hide();
            $('#archive_comment_div_'+ noteId).show()
            $('#add_comment_button_top_div_'+ questionId).show();
        }
    });
    ctx.archive.cancel = ctx.archive.cancel || (function(event, noteId){
        event.preventDefault();
        if($ && noteId){
            $('#archive_comment_div_'+noteId).hide();
        }
    });
})(define('dmproadmap.notes'));