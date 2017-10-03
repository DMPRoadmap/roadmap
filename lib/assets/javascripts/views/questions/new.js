$(() => {
  $('.new_question_cancel').on('click', (e) => {
    const questionNew = $(e.target).closest('.question_new');
    questionNew.hide();
    questionNew.closest('.row').find('.question_new_link').show();
  });
});
