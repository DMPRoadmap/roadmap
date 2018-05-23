import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import { Tinymce } from '../../../utils/tinymce';
import { isObject, isString } from '../../../utils/isType';
import getConstant from '../../../constants';
import expandCollapseAll from '../../../utils/expandCollapseAll';
import ariatiseForm from '../../../utils/ariatiseForm';

import onChangeQuestionFormat from '../questions/sharedEventHandlers';
import initQuestionOption from '../question_options/index';

$(() => {
  // Attach handlers for the expand/collapse all accordions
  expandCollapseAll();

  Tinymce.init({ selector: '.phase' });
  ariatiseForm({ selector: '.phase_form' });
  const parentSelector = '#sections_accordion';

  const initQuestion = (context) => {
    const target = $(context);
    if (isObject(target)) {
      Tinymce.init({ selector: `#${context} .question` });
      ariatiseForm({ selector: `#${context} .question_form` });
      initQuestionOption(context);
      // Swap in the question_formats when the user selects an option based question type
      $(`#${context} select.question_format`).change((e) => {
        onChangeQuestionFormat(e);
      });
    }
  };
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
      Tinymce.init({ selector: `${selector} .section` });
      ariatiseForm({ selector: `${selector} .section_form` });

      const questionForm = $(selector).find('.question_form');
      if (questionForm.length > 0) {
        // Load Tinymce when the 'show' form has a question form.
        // ONLY applicable for template customizations
        Tinymce.init({ selector: `${selector} .question_form .question` });
      }
    }
  };

  // Attach handlers for the Section expansion
  $(parentSelector).on('ajax:before', 'a.ajaxified-section[data-remote="true"]', (e) => {
    const panelBody = $(e.target).parent().find('.panel-body');
    return panelBody.attr('data-loaded') === 'false';
  });
  $(parentSelector).on('ajax:success', 'a.ajaxified-section[data-remote="true"]', (e, data) => {
    const panelBody = $(e.target).parent().find('.panel-body');
    const panel = panelBody.parent();
    if (isObject(panelBody)) {
      // Display the section's html
      panelBody.attr('data-loaded', 'true');
      panelBody.html(data);
      // Wire up the section
      initSection(`#${panel.attr('id')}`);
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
  $(parentSelector).on('ajax:success', 'a.ajaxified-question[data-remote="true"]', (e, data) => {
    const target = $(e.target);
    const panelBody = getQuestionPanel(target);
    if (isObject(panelBody)) {
      const id = panelBody.attr('id');
      // Display the section's html
      panelBody.html(data);
      initQuestion(id);
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
  const currentSection = $('#sections_accordion .in');
  if (currentSection.length > 0) {
    initSection(`#${currentSection.attr('id')}`);
  }
  // Handle the new section
  initSection('#new_section_new_section');
});
