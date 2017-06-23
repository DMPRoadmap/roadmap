$(document).ready(function(){
  // Allow for tabs to be selected if a user presses enter while on a tab
  $("li[role='tab']").keydown(function(ev) {
    if (ev.which ==13) {
      $(this).click();
    }
  });

  $("a.dropdown").on('click', function(e){
    e.preventDefault();
    var id = $(this).prop('id');
		var visible = $("#" + id + "-dropdown").css('visibility') == 'visible';
    $("#" + id + "-dropdown").css('visibility', (visible ? 'hidden' : 'visible'));
  });
});
