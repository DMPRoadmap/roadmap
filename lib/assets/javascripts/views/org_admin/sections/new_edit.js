import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';

export default (context) => {
  const target = $(context);
  if (isObject(target)) {
    Tinymce.init({ selector: `${target.attr('id')} .section` });
    ariatiseForm({ selector: `${target.attr('id')} .section_form` });
    target.on('click', '.section_new_cancel', (e) => {
      // TODO: We may want to reload this form to clear out any values.
      e.preventDefault();
      const section = $('#new_section');
      section.click();
    });
  }
};

