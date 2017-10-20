import timeago from 'timeago.js/dist/timeago';
import {
  isObject,
  isNumber,
  isString } from '../../utils/isType';
import { Tinymce } from '../../utils/tinymce';
import debounce from '../../utils/debounce';

$(() => {
  /*
   * Shows the closest saving-message HTML element within a question-form
   * @param { Strin } selector - A valid CSS selector to look for
   * @return { jQuery }
   */
  const showSavingMessage = selector => $(selector).closest('.question-form').find('.saving-message').show();
  /*
   * Retrieves the question id for the closest form-answer
   * @param { String } selector - A valid CSS selector to look for
   * @return { String } representing the question id for a given answer, otherwise undefined
   */
  const questionId = selector => $(selector).closest('.form-answer').attr('data-autosave');
  /*
   * A map of debounced functions, one for each input, textarea or select change at any 
   * form with class form-answer. The key represents a question id and the value holds 
   * the debounced function for a given input, textarea or select. Note, this map is 
   * populated on demand, i.e. the first time a change is made at a given input, textarea
   * or select within the form, a new key-value should be created. Succesive times, the 
   * debounced function should be retrieved instead.
   */
  const debounceMap = {};
  const autoSaving = (selector) => {
    if ($(selector).closest('.question-form').find('.answer-locking').html().length === 0) {
      $(selector).closest('.form-answer').trigger('submit');
    }
  };
  // Initialises tinymce for any target element with class tinymce_answer
  Tinymce.init({ selector: '.tinymce_answer' });
  // Listeners for change, blur and focus at any target element with class tinymce_answer
  Tinymce.findEditorsByClassName('tinymce_answer').forEach((editor) => {
    editor.on('Blur', () => {
      const id = questionId(`#${editor.id}`);
      $(`#${editor.id}`).val(editor.getContent()); // Updates target element of editor with its content
      if (!debounceMap[id]) {
        debounceMap[id] = debounce(autoSaving);
      }
      debounceMap[id]($(`#${editor.id}`));
    });
    editor.on('Focus', () => {
      const id = questionId(`#${editor.id}`);
      if (debounceMap[id]) {
        /* Cancels the delayed execution of autoSaving, either because user
         * transitioned from an option_based question to the comment or 
         * because the target element triggered blur and focus before 
         * the delayed execution of autoSaving.
         */
        debounceMap[id].cancel();
      }
    });
  });
  // Listener for input or select field
  $('.form-answer').on('change', 'input, select', (e) => {
    const id = questionId(e.target);
    if (!debounceMap[id]) {
      debounceMap[id] = debounce(autoSaving);
    }
    debounceMap[id]($(e.target));
  });
  // Listener for submit button
  $('.form-answer').on('submit', (e) => {
    e.preventDefault();
    const id = questionId(e.target);
    if (debounceMap[id]) {
      // Cancels the delated execution of autoSaving
      // (e.g. user clicks the button before the delay is met)
      debounceMap[id].cancel();
    }
    showSavingMessage(e.target);
    const formElements = $(e.target).closest('.form-answer').serializeArray();
    const answerId = formElements.find(el => el.name === 'answer[id]');
    if (answerId) {
      // TODO centralise AJAX calls
      $.ajax({
        method: 'PUT',
        url: `/answers/${answerId}`,
        data: formElements,
      }).done((data) => {
        // Validation for the data object received
        if (isObject(data)) {
          if (isObject(data.question)) { // Object related to question within data received
            if (isNumber(data.question.id)) {
              if (isString(data.question.answer_status)) {
                $(`#answer-status-${data.question.id}`).html(data.question.answer_status); // TODO check partial render of this view on the server
                timeago().render($('abbr.timeago'));
              }
              if (isString(data.question.locking)) {
                $(`#answer-locking-${data.question.id}`).html(data.question.locking);
              }
              if (isNumber(data.question.answer_lock_version)) {
                $(e.target).closest('.form-answer').find('#answer_lock_version').val(data.question.answer_lock_version);
              }
            }
          }
          if (isObject(data.plan)) { // Object related to plan within data received
            if (isString(data.plan.progress)) {
              $('.progress').html(data.plan.progress);
            }
          }
          if (isObject(data.section)) { // Object related to section within data received
            if (isNumber(data.section.id)) {
              if (isString(data.section.progress)) {
                $(`.section-progress-${data.section.id}`).html(data.section.progress);
              }
            }
          }
        }
      }, () => {
        // TODO adequate error handling for network error 
      });
    }
  });
  timeago().render($('abbr.timeago'));
});
