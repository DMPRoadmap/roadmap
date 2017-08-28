$(document).ready(function(){
  //Validate banner_text area for less than 165 character
  $("form#edit_org_details").submit(function(){
      if (getStats('org_banner_text').chars > 165) {
          alert(__('Please only enter up to 165 characters, you have used') + " " + getStats('org_banner_text').chars + ". " + __('If you are entering an URL try to use something like http://tinyurl.com/ to make it smaller.'));
          return false;
      }
  });
	
  $("#org_name").keyup(function(){
    $("#save_org_submit").attr('aria-disabled', ($(this).val().trim() == '' || 
                                                 $("#org_abbreviation").val().trim() == ''));
  });
  $("#org_abbreviation").keyup(function(){
    $("#save_org_submit").attr('aria-disabled', ($(this).val().trim() == '' || 
                                                 $("#org_name").val().trim() == ''));
  });
  
  $("#save_org_submit").attr('aria-disabled', ($("#org_name").val() && ($("#org_name").val().trim() == '' ||  $("#org_abbreviation").val().trim() == '')));
});