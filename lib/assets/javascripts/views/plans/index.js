$(document).ready(function(){
  // Update the plan's test status via ajax when the checkbox is clicked
  $("input[type='checkbox']").on('click, change', function(e){
    var self = this;
    var id = $(this).attr("id").replace("is_test-", "");
    var params = {plan: {visibility: $(this).is(':checked') ? 'is_test' : 'privately_visible'}};

    asyncRequest(
      {url: "/plans/" + id + "/set_test", 
       type: 'POST', 
       data: JSON.stringify(params)}, 
      {success: function(data){ 
        if($(self).is(':checked')){
          $("#visibility-" + id + " span").html(__('N/A')).attr('title', '');
        }else{
          $("#visibility-" + id + " span").html(__('Private'))
        }
      }});
  });
});
