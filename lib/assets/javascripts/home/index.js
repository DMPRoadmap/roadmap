$(document).ready(function(){
  $(".tab-panels div.tab-panel:not(.active)").hide();
  
  $(".tabs li a").click(function(e){
    e.preventDefault();
    
    // Make the clicked tab the active tab
    $(this).parent().addClass('active');
    $(this).attr('aria-selected', 'true');
    $.each($(this).parent().siblings(), function(i, sib){
      $(sib).removeClass('active');
      $(sib).find('> a').attr('aria-selected', 'false');
    });
    
    // Make the corresponding panel visible and the others hidden
    let panel = $($(this).attr("href"));
    panel.show().attr("aria-hidden", 'false');
    $.each($(panel).siblings(), function(i, p){
      $(p).hide().attr("aria-hidden", 'true');
    });
  });
  
  // If the hidden valid-form field is set to true then enable the submit button
  $("#valid-form").change(function(){
    $(this).siblings(".form-submit").attr('aria-disabled', $(this).val() != "true");
  });

  $("#shibboleth-login").click(function(e){
    e.preventDefault();
    window.location.href = $(this).attr('href');
  })
});