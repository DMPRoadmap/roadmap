// update details in section progress panel
export const updateSectionProgress = (id, numSecAnswers, numSecQuestions) => {
  const progressDiv = $(`#section-panel-${id}`).find('.section-status');
  progressDiv.html(`(${numSecAnswers} /  ${numSecQuestions})`);
  const heading = progressDiv.closest('.panel-heading');
  if (numSecQuestions === 0) { // disable section if empty
    if (heading.parent().attr('aria-expanded') === 'true') {
      heading.parent().trigger('click');
    }
    heading.addClass('empty-section');
    heading.closest('.panel').find(`#collapse-${id}`).hide();
    heading.closest('.panel').find('i.fa-plus, i.fa-minus').removeClass('fa-plus').removeClass('fa-minus');
  } else if (heading.hasClass('empty-section')) { // enable section if questions re-added
    heading.removeClass('empty-section');
    heading.closest('.panel').find('i[aria-hidden="true"]').addClass('fa-plus');
    heading.closest('.panel').find(`#collapse-${id}`).css('display', '');
  }
};

// given a question id find the containing div
// used inconditional questions
export const getQuestionDiv = (id) => $(`#answer-form-${id}`).closest('.row');
