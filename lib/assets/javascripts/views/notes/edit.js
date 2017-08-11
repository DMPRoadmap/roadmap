(function(ctx){
    ctx.edit = ctx.edit || (function(noteId, questionId){
        if($ && noteId && questionId) {
            $('.edit_comment_class').hide();
            $('.view_comment_class').hide();
            $('.archive_comment_class').hide();
            $('#lastet_comment_div_'+ questionId).hide();
            $('#view_comment_div_'+ noteId).hide();
            $('#archive_comment_div_'+ noteId).hide();
            $('#add_comment_block_div_'+ questionId).hide();
            $('#edit_comment_div_'+ noteId).show();
            $('#add_comment_button_top_div_'+ questionId).show();
        }
    });
})(define('dmproadmap.notes'));