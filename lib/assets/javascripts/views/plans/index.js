$(document).ready(function(){
  $("input[type='checkbox']").on('click, change', function(e){
    var self = this;
    var id = $(this).attr("id").replace("is_test-", "");
    var params = {plan: {visibility: $(this).is(':checked') ? 'is_test' : 'privately_visible'}};

    // Update the visbility to test or private
    $.post("/plans/" + id + "/visibility", params, function(data){
      if(data['code'] === 1){
        var msg = ($(self).is(':checked') ? __('The plan is now a test.') : __('The plan is no longer a test.'));
        // If the save was successful make sure the Visibility text gets updated to 'Private'
        $("div.roadmap-info-box span:not(.aria-only)").html(msg).attr('role', 'status')
            .css('width', 'auto').parent().css('visibility', 'visible');
        $(self).parent().siblings("#visibility-" + id).html(__('Private'));
      }else{
        // Display an error message
        $("div.roadmap-alert-box span:not(.aria-only)").show().html(data['msg'])
            .attr('role', 'alert').css('width', 'auto').css('visibility', 'visible');
        e.preventDefault();
      }
    });
  });
});