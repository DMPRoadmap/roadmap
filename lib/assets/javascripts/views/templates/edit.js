$(() => {
  $('.template_show_link').on('click', (e) => {
    e.preventDefault();
    $(e.target).closest('.template_edit').hide();
    $(e.target).closest('.tab-pane').find('.template_show').show();
  });
});
