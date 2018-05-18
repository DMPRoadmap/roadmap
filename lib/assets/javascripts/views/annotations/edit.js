$(() => {
  $('.cancel_edit_annotations').on('click', (e) => {
    e.preventDefault();
    const target = $(e.target).attr('href');
    $(target).hide();
    $(target).closest('.col-md-12').find('.edit_annotations_button').show();
    $(target).closest('.col-md-12').find('.show_annotations_div').show();
  });
});
