import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';
import initQuestions from '../questions/new_edit';

export default (context) => {
  const target = $(context);
  if (isObject(target)) {
    // Wire up the section and its Questions
    Tinymce.init({ selector: `#${context} .section` });
    ariatiseForm({ selector: `#${context} .section_form` });
    initQuestions(context);

    target.on('click', '.section_new_cancel', (e) => {
      // TODO: We may want to reload this form to clear out any values.
      e.preventDefault();
      const section = $('#new_section');
      section.click();
    });
  }
};

