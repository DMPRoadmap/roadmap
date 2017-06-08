$(document).ready(function(){
  $("#show_list").click(function(e){
    e.preventDefault();
    $("#full_list").show();
    $(this).html(__('Hide list'));
  });
  
  $("#hide_list").click(function(e){
    e.preventDefault();
    $("#full_list").hide();
    $(this).html(__('See the full list of partner institutions'));
  });
});