// update details in section progress panel
export const updateSectionProgress = (id, numSecAnswers, numSecQuestions) => {
  const progressDiv = $(`#section-panel-${id}`).find('.section-status');
  progressDiv.html(`(${numSecAnswers} /  ${numSecQuestions})`);
  const heading = progressDiv.closest('.panel-heading');
  const hideColor = 'rgb(211, 211, 211)';
  if (numSecQuestions === 0) { // disable section if empty
    if (heading.parent().attr('aria-expanded') === 'true') {
      heading.parent().trigger('click');
    }
    heading.css({ 'background-color': hideColor, cursor: 'auto' });
    heading.closest('.panel').find(`#collapse-${id}`).hide();
    heading.closest('.panel').find('i.fa-plus, i.fa-minus').removeClass('fa-plus').removeClass('fa-minus');
  } else if (heading.css('background-color') === hideColor) { // enable section if questions re-added
    heading.css({ 'background-color': 'rgb(79,82,83)', cursor: 'pointer' });
    heading.closest('.panel').find('i[aria-hidden="true"]').addClass('fa-plus');
    heading.closest('.panel').find(`#collapse-${id}`).css('display', '');
  }
};

export const getQuestionDiv = id => $(`#answer-form-${id}`).closest('.row');
