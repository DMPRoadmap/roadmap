// the "add note" button
/*----------------
    Invoked at app/views/phases/_note.html.erb L.14
------------------*/
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
/*----------------
    Invoked at app/views/phases/_list_notes.html.erb L.34
------------------*/
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
/*----------------
    Invoked at app/views/phases/_list_notes.html.erb L.37
------------------*/
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
/*----------------
    Invoked at app/views/phases/_archive_note.html.erb L.17
    Invoked at app/views/phases/_list_notes.html.erb L.38
    Invoked at app/views/phases/_list_notes.html.erb L.43
------------------*/
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
/*----------------
    Invoked at app/views/phases/_archive_note.html.erb L.18
------------------*/
function cancel_archive_note(c_id) {
        var c_id = $(this).prev(".comment_id").val();
        $('.archive_comment_class').hide();
        $('#view_comment_div_'+ c_id).show();
}