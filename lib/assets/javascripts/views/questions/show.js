$(() => {
  $('.question_edit_link').on('click', (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    $(source).closest('.question_show').hide();
    $(target).show();
  });

  $('.add_annotations_button').on('click', (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    $(target).show();
    $(source).hide();
  });

  $('.edit_annotations_button').on('click', (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    $(target).show();
    $(source).hide();
    $(target).closest('.col-md-12').find('.show_annotations_div').hide();
  });
});
