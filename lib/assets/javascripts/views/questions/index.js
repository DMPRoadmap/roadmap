$(() => {
  $('.question_new_link').on('click', (e) => {
    e.preventDefault();
    $(e.target).hide();
    $(e.target).closest('.row').find('.question_new').show();
  });
});
