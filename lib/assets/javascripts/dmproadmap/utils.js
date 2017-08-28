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
    
    // If the user mouses over the dropdown clear the timeout timer. hide the dropdown when the mouse out
    $("#" + id + "-dropdown").mouseleave(function(){
      $(this).css('visibility', 'hidden');
    });
  });
  
  // Display tooltips when the item has focus or hover
  $("[data-toggle='tooltip']").on('click', function(e){
    e.preventDefault();
  });
  $("[data-toggle='tooltip']").on('focus mouseenter', function(e){
    e.preventDefault();
    if($(this).attr('data-content') !== undefined){
      var y = $(this).width() + 35;
      $(this).after('<div class="tooltip-message" style="left: ' + y + 'px;">' + $(this).attr('data-content') + '</div>');
    }
  }).on('blur mouseleave', function(e){
    $(this).parent().find('div.tooltip-message').remove();
  });
  // Display popover when the item has focus or hover
  $("[data-toggle='popover']").on('click', function(e){
    e.preventDefault();
  });
  $("[data-toggle='popover']").on('focus mouseenter', function(e){
    e.preventDefault();
    if($(this).attr('data-content') !== undefined){
      var y = $(this).width() + 35;
      $(this).after('<div class="popover-message" style="left: ' + y + 'px;">' + $(this).attr('data-content') + '</div>');
    }
  }).on('blur mouseleave', function(){
    $(this).parent().find('div.popover-message').remove();
  });
});

