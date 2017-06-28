$(document).ready(function(){
  $("#is_test").on('click, change', function(e){
    toggleVisibility();
    // If the test box is checked then update the visibility to 'is_test'
    if($("#is_test").is(':checked')){
      $('#plan_visibility').val('is_test');
    }else{
      $('#plan_visibility').val('');
    }
  });
  
  $("input[name='vis']").on('change', function(e){
    $('#plan_visibility').val($("input[name='vis']:checked").attr('id'));
  });
  
  toggleVisibility();
  
  function toggleVisibility(){
    var test = $("#is_test").is(':checked');
    // If the test checkbox is true then disable the visibility dropdown
    $("input[name='vis']").attr('aria-disabled', test).attr('disabled', test);
  }

  /*----------------
  TODO: See if this is still necessary after redesign of Edit Plan page
  Listener for click on buttons containing show-edit-toggle class
  ------------------*/
  $(".show-edit-toggle").click(function (e) {
      e.preventDefault();
      $(".edit-plan-details").toggle();
      $(".show-plan-details").toggle();
  });

});