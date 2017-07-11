$(document).ready(function(){
  toggleDataContact();

  $("#show-data-contact").click(function(){
    toggleDataContact();
  })
  
  function toggleDataContact(){
    if($("#show-data-contact").is(':checked')){
      $(".data-contact-info").hide();
      $(".data-contact-info input").val('');
    }else{
      $(".data-contact-info").show();
    }
  }
});