// import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import { Tinymce } from '../../utils/tinymce.js';
import { isObject, isString } from '../../utils/isType';
import getConstant from '../../utils/constants';
import { addAsterisks } from '../../utils/requiredField';

import onChangeQuestionFormat, { onChangeQuestionClassname } from '../questions/sharedEventHandlers';
import initQuestionOption from '../questionOptions/index';
import updateConditions from '../conditions/updateConditions';

$(() => {
  Tinymce.init({ selector: '#phase_description' });
  const parentSelector = '.section-group';

  const initQuestion = (context) => {
    const target = $(`#${context}`);
    if (isObject(target)) {
      // For some reason the toolbar options are retained after the call to
      // Tinymce.init() on the views/notifications/edit.js file. Tried 'Object.assign'
      // instead of '$.extend' but it made no difference.
      Tinymce.init({
        selector: `#${context} .question`,
        init_instance_callback(editor) {
          // When the text editor changes to blank, set the corresponding destroy
          // field to true (if present).
          editor.on('Change', () => {
            const $texteditor = $(editor.targetElm);
            const $fieldset = $texteditor.parents('fieldset');
            const $hiddenField = $fieldset.find('input[type=hidden][name$="[_destroy]"]');
            $hiddenField.val(editor.getContent() === '');
          });
        },
      });
      initQuestionOption(context);
      addAsterisks(`#${context}`);
      // Swap in the question_formats when the user selects an option based question type
      $(`#${context} select.question_format`).on('change', (e) => {
        onChangeQuestionFormat(e);
      });
      $(`#${context} select.question_schema_class`).on('change', (e) => {
        onChangeQuestionClassname(e);
      });
    }
  };

  $('.question_container').each((i, element) => {
    const questionId = $(element).attr('id');
    initQuestion(questionId);
  });

  const getQuestionPanel = (target) => {
    let panelBody;
    if (isObject(target)) {
      panelBody = target.closest('.question_container');
      if (!isObject(panelBody) || !isString(panelBody.attr('id'))) {
        panelBody = target.closest('.panel-body').find('.new-question');
      }
    }
    return panelBody;
  };
  const initSection = (selector) => {
    if (isString(selector)) {
      // Wire up the section and its Questions
      // For some reason the toolbar options are retained after the call to Tinymce.init() on
      // the views/notifications/edit.js file. Tried 'Object.assign' instead of '$.extend' but it
      // made no difference
      const prefix = 'collapseSection'
      let sectionId = selector;
      if (sectionId.startsWith(prefix)) {
        sectionId = `sc_${sectionId.replace(prefix, '')}_section_description`
      }

      Tinymce.init({
        selector: `#${sectionId}`,
        init_instance_callback: (editor) => {
          // When the text editor changes to blank, set the corresponding destroy
          // field to true (if present).
          editor.on('Change', (ed) => {
            const $texteditor = $(ed.getContentAreaContainer());
            const $fieldset = $texteditor.parents('fieldset');
            const $hiddenField = $fieldset.find('input[type=hidden][id$="_destroy"]');
            $hiddenField.val(ed.getContent() === '');
          });
        },
      });

      const questionForm = $(`#${selector}`).find('.question_form');
      if (questionForm.length > 0) {
        initQuestion(selector);
      }
    }
  };

  // Attach handlers for the Section expansion
  $(parentSelector).on('ajax:before', 'a.ajaxified-section[data-remote="true"]', (e) => {
    const panelBody = $(e.target).parent().find('.panel-body');
    return panelBody.attr('data-loaded') === 'false';
  });

  $(parentSelector).on('ajax:success', 'a.ajaxified-section[data-remote="true"]', (e) => {
    const panelBody = $(e.target).parent().find('.panel-body');
    const panel = panelBody.parent();
    if (isObject(panelBody)) {
      // Display the section's html
      panelBody.attr('data-loaded', 'true');
      panelBody.html(e.detail[0].html);

      // Wire up the section
      initSection(`${panel.attr('id')}`);
    }
  });

  // Attach handlers for the Question show/edit/new
  $(parentSelector).on('ajax:before', 'a.ajaxified-question[data-remote="true"]', (e) => {
    const panelBody = getQuestionPanel($(e.target));
    if (isObject(panelBody)) {
      // Release any Tinymce editors that have been loaded
      panelBody.find('.question').each((idx, el) => {
        Tinymce.destroyEditorById($(el).attr('id'));
      });
    }
  });
  $(parentSelector).on('ajax:success', 'a.ajaxified-question[data-remote="true"]', (e) => {
    const target = $(e.target);
    const panelBody = getQuestionPanel(target);
    if (isObject(panelBody)) {
      const id = panelBody.attr('id');
      // Display the section's html
      panelBody.html(e.detail[0].html);
      initQuestion(id);
      updateConditions(id);
      if (panelBody.is('.new-question')) {
        target.hide();
      }
    }
  });
  $(parentSelector).on('ajax:error', 'a.ajaxified-question[data-remote="true"]', (e) => {
    const panelBody = getQuestionPanel($(e.target));
    if (isObject(panelBody)) {
      panelBody.html(`<div class="pull-right alert alert-warning" role="alert">${getConstant('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION')}</div>`);
    }
  });
  // When we cancel the new question we just remove the form and its Tinymce editors
  $(parentSelector).on('click', '.cancel-new-question', (e) => {
    e.preventDefault();
    const target = $(e.target);
    const panel = target.closest('.question_container');
    panel.find('.question').each((idx, el) => {
      Tinymce.destroyEditorById($(el).attr('id'));
    });
    panel.html('');
    panel.closest('.panel-body').find('.new-question-button a.ajaxified-question[data-remote="true"]').show();
  });
  // Handle the section that has focus on initial page load
  const currentSection = $('.section-group .in');
  if (currentSection.length > 0) {
    initSection(`${currentSection.attr('id')}`);
  }
  // Handle the new section
  // initSection('#new_section_section_description');
  Tinymce.init({ selector: '#new_section_section_description' });
});
