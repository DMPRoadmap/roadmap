$(document).ready(function() {
  $("#select_all").click(function() {
    $('.preferences').find('input[type="checkbox"]').prop('checked', true);
  });

  $("#deselect_all").click(function() {
    $('.preferences').find('input[type="checkbox"]').prop('checked', false);
  });
});