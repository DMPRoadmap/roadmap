$(document).ready(function(){
  $(".tab-panels div.tab-panel:not(.active)").hide();
  
  $("li[role='tab'] a").click(function(e){
    // Unselect the other tabs
    $("li[role='tab']").removeClass('active').children('a').attr('aria-selected', 'false');
    // Select the current tab
    $(this).attr('aria-selected', 'true').parent().addClass('active');

    // Display the corresponding panel if its a page anchor otherwise just follow the target
		if($(this).attr("href")[0] == '#'){
	    e.preventDefault();
			
		var panel = $($(this).attr("href"));
	    panel.show().attr("aria-hidden", 'false');
	    $.each($(panel).siblings(), function(i, p){
	      $(p).hide().attr("aria-hidden", 'true');
	    });
		}
  });
});

function selectActiveTab(){
  var tab = getURLParameter('tab');
	if (tab != '') 
	{
    // Unselect the other tabs
    $("li[role='tab']").removeClass('active').children('a').attr('aria-selected', 'false');
		// Select the current tab
		$(".tabs").find('#' + tab).attr('aria-selected', 'true').addClass('active');

		// Display the corresponding panel if its a page anchor otherwise just follow the target
		var panel = $(".tabs").find('#' + tab).children('a').attr("href");
	  $(".tab-panels").find(panel).addClass('active');
    $.each($(".tab-panels").find(panel).siblings(), function(i, p){
    	$(p).removeClass('active');
  	});
	}
}

function getURLParameter(sParam){
  var sPageURL = window.location.search.substring(1);
  var sURLVariables = sPageURL.split('&');
  for (var i = 0; i < sURLVariables.length; i++)    {
      var sParameterName = sURLVariables[i].split('=');
      if (sParameterName[0] == sParam){
          return sParameterName[1];
      }
  }
}