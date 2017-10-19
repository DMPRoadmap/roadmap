$(() => {
  $('.question_edit_link').on('click', (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    $(source).closest('.question_show').hide();
    $(target).show();
  });
});
