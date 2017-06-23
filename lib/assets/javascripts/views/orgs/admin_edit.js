$(document).ready(function(){
  $("#org_name").keyup(function(){
    $("#save_org_submit").attr('aria-disabled', ($(this).val().trim() == '' || 
                                                 $("#org_abbreviation").val().trim() == ''));
  });
  $("#org_abbreviation").keyup(function(){
    $("#save_org_submit").attr('aria-disabled', ($(this).val().trim() == '' || 
                                                 $("#org_name").val().trim() == ''));
  });
  
  $("#save_org_submit").attr('aria-disabled', ($("#org_name").val().trim() == '' || 
                                               $("#org_abbreviation").val().trim() == ''));
});