import getConstant from './constants';
import { isObject } from './isType';

const asterisk = `<span class="red" title="${getConstant('REQUIRED_FIELD_TEXT')}">* </span>`;

export const addAsterisk = (el) => {
  const target = $(el);
  if (isObject(target)) {
    // If the element is part of a Fieldset then place the asterisk before the <fieldset><legend>
    if (target.closest('fieldset').length > 0 && target.closest('fieldset').find('legend').length > 0) {
      const legend = target.closest('fieldset').find('legend');
      legend.html(`${asterisk} ${legend.html()}`);

    // If the element is a radio button or checkbox place the asterisk after the label
    } else if (target.is('[input="checkbox"]') || target.is('[input="radio"]')) {
      target.after(asterisk);

    // Else place the asterisk before the corresponding label
    } else {
      const label = target.closest('.form-group').find('label');
      if (isObject(label)) {
        $(label[0]).before(asterisk);
      }
    }
  }
};

export const addAsterisks = (el) => {
  $(el).find('[aria-required=true]').each((idx, jqObject) => {
    addAsterisk(jqObject);
  });
};

$(() => {
  addAsterisks('body');
});
