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
  
  $("input[name='visibility']").on('change', function(e){
    $('#plan_visibility').val($("input[name='visibility']:checked").val());
  });
  
  toggleVisibility();
  
  function toggleVisibility(){
    var test = $("#is_test").is(':checked');
    // If the test checkbox is true then disable the visibility dropdown
    $("input[name='visibility']").attr('aria-disabled', test).attr('disabled', test);
  }
});