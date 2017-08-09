$(document).ready(function(){
  // If the hidden valid-form field is set to true then enable the submit button
  $("#org_name, #org_id").change(function(){
    if($(this).prop('tagName') === 'select'){
      $(this).siblings(".form-submit").attr('aria-disabled', $(this).children(':selected').attr('id') === "");
    }else{
      $(this).siblings(".form-submit").attr('aria-disabled', $("#org_id").val() === "");
    }
  });

  $("#show_list").click(function(e){
    e.preventDefault();
    if($("#full_list").css("display") == "none"){
      $("#full_list").attr('aria-hidden', 'false').show();
      $(this).html(__('Hide list'));
    }else{
      $("#full_list").attr('aria-hidden', 'true').hide();
      $(this).html(__('See the full list of partner institutions'));
    }
  });
});