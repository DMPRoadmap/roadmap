$(() => {
  $('.cancel_add_annotations').on('click', (e) => {
    e.preventDefault();
    const target = $(e.target).attr('href');
    $(target).hide();
    $(target).closest('.col-md-12').find('.add_annotations_button').show();
    $(target).closest('.col-md-12').find('.show_annotations_div').show();
  });
});
