$(document).ready(function(){
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