import { VALIDATION_MESSAGE_PASSWORDS_MATCH } from '../constants';
import { isObject, isString } from './isType';

const getHelpBlock = (id) => {
  if (isString(id)) {
    return `<span id="${id}" class="help-block" style="display:none;">
            ${VALIDATION_MESSAGE_PASSWORDS_MATCH}</span>`;
  }
};

const isValid = (pwd, confirmation) => {
  return pwd === confirmation;
};

const valid = (el, block) => {
  $(el).attr('aria-invalid', false);
  $(el).parent().removeClass('has-error');
  $(`#${block}`).hide();
};
const invalid = (el, block) => {
  $(el).attr('aria-invalid', true);
  $(el).parent().addClass('has-error');
  $(`#${block}`).show();
};

export default (options) => {
  if (isObject(options) && isString(options.selector)) {
    const id = `${options.selector}_password_matcher`;

    const pwd = $(options.selector).find('#user_password');
    const cnf = $(options.selector).find('#user_password_confirmation');
    const sbmt = $(options.selector).find('input[type="submit"]');

    if (isObject(pwd) && isObject(cnf) && isObject(sbmt)){
      if (isValid($(pwd).val(), $(cnf).val())) {
        $(cnf).after(getHelpBlock(id));
        $(cnf).attr('aria-describedby', id);

        $(sbmt).click((e) => {
          if (cnf !== pwd) {
            e.preventDefault();
            invalid(cnf, id);
          } else {
            valid(cnf, id);
          }
        });
      }
    }
  }
};
