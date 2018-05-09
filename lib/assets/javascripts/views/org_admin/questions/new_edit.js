import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';
import onChangeQuestionFormat from './sharedEventHandlers';

export default (context) => {
  const target = $(context);
  if (isObject(target)) {
    Tinymce.init({ selector: `${target.attr('id')} .question` });
    ariatiseForm({ selector: `${target.attr('id')} .question_form` });
    target.on('click', '.new_question_cancel', (e) => {
      const questionNew = $(e.target).closest('.question_new');
      questionNew.hide();
      questionNew.closest('.row').find('.question_new_link').show();
    });
    target.on('change', '[name="question[question_format_id]"]', onChangeQuestionFormat);
  }
};
