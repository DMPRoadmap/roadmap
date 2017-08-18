$(document).ready(function(){
    // Allow the 'button disabled' tooltip to appear if the button is NOT clickable
    $("#<%= id %>").on('click focus', function(e){
      if($(this).attr('aria-disabled') == 'true'){
        e.preventDefault();
        toggleFormElementError(this, "<%= tooltip %>");
      }else{
        toggleFormElementError(this, '');
      }
    }).on('blur', function(){
        toggleFormElementError(this, '');
    });
});