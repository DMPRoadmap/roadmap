$(() => {
  $('.question_edit_link').on('click', (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    $(source).closest('.question_show').hide();
    $(target).show();
  });

  $('.annotations_button').on('click', (e) => {
    e.preventDefault();
    const target = $(e.target).attr('href');
    $(target).show();
    $(target).closest('.col-md-12').find('.show_annotations_div').hide();
  });

  $('.cancel_edit_annotations').on('click', (e) => {
    e.preventDefault();
    const target = $(e.target).attr('href');
    $(target).hide();
    $(target).closest('.col-md-12').find('.show_annotations_div').show();
  });
});
