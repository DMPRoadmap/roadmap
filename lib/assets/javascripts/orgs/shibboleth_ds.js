$(document).ready(function(){
  // If the hidden valid-form field is set to true then enable the submit button
  $("#org_id").change(function(){
    $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() === "");
  });

  $("#show_list").click(function(e){
    e.preventDefault();
    if($("#full_list").css("display") == "none"){
      $("#full_list").show();
      $(this).html(__('Hide list'));
    }else{
      $("#full_list").hide();
      $(this).html(__('See the full list of partner institutions'));
    }
  });
});