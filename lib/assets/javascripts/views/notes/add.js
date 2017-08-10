(function(ctx){
    ctx.add = ctx.add || (function(questionId){
        if($ && questionId) {
            $(".alert-notice").hide();
            $('.view_comment_class').hide();
            $('.edit_comment_class').hide();
            $('.archive_comment_class').hide();
            $('#add_comment_button_top_div_'+ questionId).hide();
            $('#add_comment_block_div_'+ questionId).show();
        }
    });
})(define('dmproadmap.notes'));