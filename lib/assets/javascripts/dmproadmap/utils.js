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

function toggleFormElementError(input, errorMessage, blankAsError){
    //Check if element is a auto complete combobox
    if ($(input).attr('data-combobox-prefix-class') === 'combobox'){
        idbox = '#' + $(input).attr('id').replace('_name', '_id');
    }else{
        idbox = input;
    }
    var err = $(idbox).siblings("span.error-tooltip");
    if(err.length <= 0){
        err = $(idbox).siblings("span.error-tooltip-right");
    }
    console.log(err.length + ' - ' + errorMessage + ' - ' + $(input).val().trim().length);

    // If an error element is available and the error message is not empty and the field
    // is not empty (unless its a required field!)
    if(err.length > 0 && (errorMessage === '' || (!blankAsError && $(input).val().trim().length <= 0))){
        err.html('').attr('role', '').css('display', 'none');
        $(input).removeClass('red-border');
    }else{
        err.html(errorMessage).attr('role', 'alert').css('display', 'inline');
        $(input).addClass('red-border');
    }
}
