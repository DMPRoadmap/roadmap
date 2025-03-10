import { Tinymce } from '../utils/tinymce.js';

// update details in section progress panel
export const updateSectionProgress = (id, numSecAnswers, numSecQuestions) => {
  const progressDiv = $(`#section-panel-${id}`).find('.section-status');
  progressDiv.html(`(${numSecAnswers} /  ${numSecQuestions})`);

  /**
   // THIS CODE MAY BE OBSOLETE.
   // RETAINING IT TILL SURE.
  const heading = progressDiv.closest('.card-heading');
  if (numSecQuestions === 0) { // disable section if empty
    if (heading.parent().attr('aria-expanded') === 'true') {
      heading.parent().trigger('click');
    }
    heading.addClass('empty-section');
    heading.closest('.card').find(`#collapse-${id}`).hide();
    heading.closest('.card').find('i.fa-plus, i.fa-minus').removeClass('fa-plus').removeClass('fa-minus');
  } else if (heading.hasClass('empty-section')) { // enable section if questions re-added
    heading.removeClass('empty-section');
    heading.closest('.card').find('i[aria-hidden="true"]').addClass('fa-plus');
    heading.closest('.card').find(`#collapse-${id}`).css('display', '');
  }
  */
};

// given a question id find the containing div
// used inconditional questions
export const getQuestionDiv = (id) => $(`#answer-form-${id}`).closest('.question-body');

// Clear an answers for a given question id.
export const deleteAllAnswersForQuestion = (questionid) => {
  const answerFormDiv = $(`#answer-form-${questionid}`);
  const editAnswerForm = $(`#answer-form-${questionid}`).find('.form-answer');

  editAnswerForm.find('input:checkbox').prop('checked', false);
  editAnswerForm.find('input:radio').prop('checked', false);
  editAnswerForm.find('option').prop('selected', false);
  editAnswerForm.find('input:text').val('');

  // Get the TinyMce editor textarea and rest content to ''
  const editorAnswerTextAreaId = `answer-text-${questionid}`;
  const tinyMceAnswerEditor = Tinymce.findEditorById(editorAnswerTextAreaId);
  if (tinyMceAnswerEditor) {
    tinyMceAnswerEditor.setContent('');
  }
  // Date fields in form are input of type="date"
  // The editAnswerForm.find('input:date') throws error, so
  // we need an alternate way to reset date.
  editAnswerForm.find('#answer_text').each ( (el) => {
    if($(el).attr('type') === 'date') {
      $(el).val('');
    }

  });
};
