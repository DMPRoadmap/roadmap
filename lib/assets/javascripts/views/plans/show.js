$(document).ready(function(){
  toggleDataContact();

  $("#show-data-contact").click(function(){
    toggleDataContact();
  })
  
  $("#show-other-guidance-orgs").click(function(){
    if($("#other-guidance-orgs").css('display') === 'block'){
      $("#other-guidance-orgs").hide();
      $(this).html($(this).html().replace('Hide', __('See')));
    }else{
      $("#other-guidance-orgs").show();
      $(this).html($(this).html().replace('See', __('Hide')));
    }
  });
  
  function toggleDataContact(){
    if($("#show-data-contact").is(':checked')){
      $(".data-contact-info").hide();
      $(".data-contact-info input").val('');
    }else{
      $(".data-contact-info").show();
    }
  }
});