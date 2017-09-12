$(() => {
  $('#select_all').click(() => {
    $('.preferences').find('input[type="checkbox"]').prop('checked', true);
  });

  $('#deselect_all').click(() => {
    $('.preferences').find('input[type="checkbox"]').prop('checked', false);
  });
});
