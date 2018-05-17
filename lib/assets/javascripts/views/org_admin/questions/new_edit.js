import getConstant from '../../../constants';
import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';
import onChangeQuestionFormat from './sharedEventHandlers';
import initQuestionShow from './show';
import initAnnotations from '../../annotations/form';
import initQuestionOptions from '../question_options/index';

export default (context) => {
  if (isObject($(`#${context}`))) {
    // Wire up the Question and then any annotations and question_options
    // TODO: Tinymce.init fails if this is called more than once on the same context
    //       other JS works fine (e.g. ariatise, buttons, etc.)
    Tinymce.init({ selector: `#${context} .question` });
    ariatiseForm({ selector: `#${context} .question_form` });
    initAnnotations(context);
    initQuestionOptions(context);
    // Swap in the question_formats when the user selects an option based question type
    $(`#${context} select.question_format`).change((e) => {
      onChangeQuestionFormat(e);
    });
    // When the user clicks the cancel button on the new Question form remove the
    // contents and display the 'Add question' button again
    $('.cancel-new-question').click((e) => {
      e.preventDefault();
      const target = $(e.target);
      const panel = target.closest('.question_new');
      const row = panel.closest('.row');
      panel.html('');
      row.find('h4').hide();
      row.find('.question_new_link').show();
    });
    // When the user clicks the cancel button on the edit Question form replace the
    // contents of the question container with the show form
    // TODO: Not sure why, but use of the Rails `remote: true` does not work,
    //       so we use AJAX here. Would be better to sue the Rails `remote:true`
    $('.cancel-edit-question').click((e) => {
      e.preventDefault();
      const link = $(e.target);
      if (isObject(link)) {
        // TODO: Trying to destroy the existing editors in case they are the reason why
        //       line 15 above does not rewiring Tinymce on subsequent loads
        Tinymce.destroyEditorsByClassName(`#${context} .question`);
        $.get(link.attr('href'))
          .done((data) => {
            $(`#${context}`).html(data);
            initQuestionShow(context);
          }).fail(() => {
            link.after(`<br><div class="pull-right alert alert-warning" role="alert">${getConstant('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION_QUESTION')}</div>`);
          });
      }
    });
  }
};
