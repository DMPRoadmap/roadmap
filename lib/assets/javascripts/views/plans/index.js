$(document).ready(function(){
  $("input[type='checkbox']").on('click, change', function(e){
    var id = $(this).attr("id").replace("is_test-", "");
    var params = {plan: {visibility: $(this).is(':checked') ? 'is_test' : 'privately_visible'}};
    remoteSave("/plans/" + id + "/set_test", 'POST', JSON.stringify(params));
    if($(this).is(':checked')){
      $("#visibility-" + id + " span").html(__('N/A')).attr('title', '');
    }else{
      $("#visibility-" + id + " span").html(__('Private'))
    }
  });
});