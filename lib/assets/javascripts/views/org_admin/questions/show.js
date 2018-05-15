$(() => {
  $('.annotations_button').on('click', (e) => {
    e.preventDefault();
    const target = $(e.target).attr('href');
    $(target).show();
    $(target).closest('.col-md-12').find('.show_annotations_div').hide();
  });
});
