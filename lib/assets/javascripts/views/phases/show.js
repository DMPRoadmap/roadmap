$(() => {
  $('.phase_edit_link').on('click', (e) => {
    e.preventDefault();
    $(e.target).closest('.phase_show').hide();
    $(e.target).closest('.tab-pane').find('.phase_edit').show();
  });
});
