$(document).ready(function(){
    /*----------------
        Listener for changes in access-level for a plan shared with a user
        TODO partial update instead of forcing a page reload
    ------------------*/
    $(".toggle-access-level").change(function(){
        $(this).closest('form').submit();
    });
});