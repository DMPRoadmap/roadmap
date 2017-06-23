$(document).ready(function() {
    var email_regex = /[^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,}$/;
    var valid_email = false;
    var valid_password = false;
    var valid_password_confirmation = false;
    var valid_accept_terms = false;
    /*----------------
        Inits select2 for any typeahead class (e.g. at views/shared/_register_form.html.erb)
    ------------------*/
    $('.typeahead').select2({
        width: "element",
        allowClear: true
    });
    // TODO removing once the new create account functionality is in place
    $("#other-org-link > a").click(function(e){
        e.preventDefault();
        var other_org = $("#other-organisation-name").attr("data-orgs").split(",");
        $("#user_organisation_id").select2("val", other_org);
        $("#other-org-link").hide();
        $("#user_organisation_id").change();
    });
    $("#user_email.text_field.reg-input").change(function(){
        if (email_regex.test($(this).val())) {
            $(this).next().hide();
            valid_email = true;
        }
        else {
            $(this).next().show();
            valid_email = false;
        }
        set_aria_submit();
    });
    $("#user_password.text_field.reg-input").change(function() {
        if($(this).val().length >= 8) {
            $(this).next().hide();
            valid_password = true;
        }
        else {
            $(this).next().show();
            valid_password = false;
        }
        // If password_confirmation is non empty already, force to check its validity
        if($("#user_password_confirmation.text_field.reg-input").val().length > 0){
            console.log('force to check validity of confirmation');
            $("#user_password_confirmation.text_field.reg-input").change();
        }
        set_aria_submit();
    });
    $("#user_password_confirmation.text_field.reg-input").change(function() {
        if ($(this).val() === $("#user_password.text_field.reg-input").val()) {
            $(this).next().hide();
            valid_password_confirmation = true;
        }
        else {
            $(this).next().show();
            valid_password_confirmation = false;
        }
        set_aria_submit();
    });
    $("#user_accept_terms").change(function(){
        valid_accept_terms = $(this).prop('checked');
        set_aria_submit();
    });
    function set_aria_submit(){
        if(valid_email
            && valid_password
            && valid_password_confirmation
            && valid_accept_terms){
            $("#sign_up_submit").attr('aria-disabled', false);
        }
        else {
            $("#sign_up_submit").attr('aria-disabled', true);
        }
    }
});