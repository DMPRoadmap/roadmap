$(document).ready(function(){
  $("input[type='checkbox']").on('click, change', function(e){
    let self = this;
    let id = $(this).attr("id").replace("is_test-", "");
    let params = {plan: {visibility: $(this).is(':checked') ? 'is_test' : 'privately_visible'}};

    // Update the visbility to test or private
    $.post("/plans/" + id + "/visibility", params, function(data){
      if(data['code'] === 1){
        // If the save was successful make sure the Visibility text gets updated to 'Private'
        $(self).parent().siblings("#visibility-" + id).html(__('Private'));
      }else{
        // Display an error message
        $("#main-page-alert").show().html(data['msg']);
        e.preventDefault();
      }
    });
  });
});