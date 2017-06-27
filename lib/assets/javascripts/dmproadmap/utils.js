$(document).ready(function(){
  // Allow for tabs to be selected if a user presses enter while on a tab
  $("li[role='tab']").keydown(function(ev) {
    if (ev.which ==13) {
      $(this).click();
    }
  });

  // Display the dropdown when the user clicks the link
  $("a.dropdown").on('click', function(e){
    e.preventDefault();
    var id = $(this).prop('id');
    var visible = $("#" + id + "-dropdown").css('visibility') == 'visible';
    $("#" + id + "-dropdown").css('visibility', (visible ? 'hidden' : 'visible'));
    
    // Set an auto timeout so that the dropdown disappears after a second
    var dropdownTimer = setTimeout(function(){
      $("#" + id + "-dropdown").css('visibility', 'hidden');
    }, 1080);
    
    // If the user mouses over the dropdown clear the timeout timer. hide the dropdown when the mouse out
    $("#" + id + "-dropdown").mouseenter(function(){
      clearTimeout(dropdownTimer);
    }).mouseleave(function(){
      $(this).css('visibility', 'hidden');
    });
  });
});
