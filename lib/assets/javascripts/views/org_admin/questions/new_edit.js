import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';
import onChangeQuestionFormat from './sharedEventHandlers';
import initAnnotations from '../../annotations/form';
import initQuestionOptions from '../question_options/index';

export default (context) => {
  const target = $(context);
  if (isObject(target)) {
    // Wire up the Question and then any annotations
    Tinymce.init({ selector: `#${context} .question` });
    ariatiseForm({ selector: `#${context} .question_form` });
    initAnnotations(context);
    initQuestionOptions(context);

    $(`#${context} select.question_format`).change((e) => {
      onChangeQuestionFormat(e);
    });
  }
};
