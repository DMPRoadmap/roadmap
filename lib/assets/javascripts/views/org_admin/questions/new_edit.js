import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';
import onChangeQuestionFormat from './sharedEventHandlers';
import initAnnotations from '../../annotations/form';

export default (context) => {
  const target = $(context);
  if (isObject(target)) {
    // Wire up the Question and then any annotations
    Tinymce.init({ selector: `#${context} .question` });
    ariatiseForm({ selector: `#${context} .question_form` });
    initAnnotations(context);

    target.on('click', '.new_question_cancel', (e) => {
      const questionNew = $(e.target).closest('.question_new');
      questionNew.hide();
      questionNew.closest('.row').find('.question_new_link').show();
    });
    $(`#${context} select.question_format`).change((e) => {
      onChangeQuestionFormat(e);
    });
  }
};
