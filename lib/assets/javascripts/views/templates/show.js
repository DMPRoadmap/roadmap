$(() => {
  $('.template_edit_link').on('click', (e) => {
    e.preventDefault();
    $(e.target).closest('.template_show').hide();
    $(e.target).closest('.tab-pane').find('.template_edit').show();
  });
});
