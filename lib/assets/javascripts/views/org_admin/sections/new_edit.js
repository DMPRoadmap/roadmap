import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';
import initQuestions from '../questions/index';

export default (context) => {
  const target = $(context);
  if (isObject(target)) {
    // Wire up the section and its Questions
    Tinymce.init({ selector: `#${context} .section` });
    ariatiseForm({ selector: `#${context} .section_form` });
    initQuestions(context);
  }
};

