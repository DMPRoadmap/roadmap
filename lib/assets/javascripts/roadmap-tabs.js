$(document).ready(function(){
  $(".tab-panels div.tab-panel:not(.active)").hide();
  
  $("li[role='tab'] a").click(function(e){
    e.preventDefault();
    
    // Unselect the other tabs
    $("li[role='tab']").removeClass('active').children('a').attr('aria-selected', 'false');
    // Select the current tab
    $(this).attr('aria-selected', 'true').parent().addClass('active');

    // Display the corresponding panel
    let panel = $($(this).attr("href"));
    panel.show().attr("aria-hidden", 'false');
    $.each($(panel).siblings(), function(i, p){
      $(p).hide().attr("aria-hidden", 'true');
    });
  });
});