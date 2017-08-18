$(document).ready(function(){
    $("#plan_template_selector").change(function(){
        $("#plan_template_id").val($(this).val()).change();
    });
});
