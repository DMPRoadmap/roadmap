import { Tinymce } from './tinymce.js';

// update details in section progress panel
export const updateSectionProgress = (id, numSecAnswers, numSecQuestions) => {
  const progressDiv = $(`#section-panel-${id}`).find('.section-status');
  progressDiv.html(`(${numSecAnswers} /  ${numSecQuestions})`);
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
