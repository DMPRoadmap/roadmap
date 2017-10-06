$(document).ready(function(){
    /*----------------
        Listener for click on buttons containing show-edit-toggle class
    ------------------*/
    $(".show-edit-toggle").click(function (e) {
        e.preventDefault();
        $(".edit-plan-details").toggle();
        $(".show-plan-details").toggle();
    });
});