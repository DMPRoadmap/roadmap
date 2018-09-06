import getConstant from '../constants';
import { isObject, isString, isArray } from './isType';

const getHelpBlock = (id) => {
  if (isString(id)) {
    return `<span id="${id}" class="help-block" style="display: none;">
            ${getConstant('VALIDATION_MESSAGE_PASSWORDS_MATCH')}</span>`;
  }
  return '';
};

const togglePassword = (password) => {
  $(password).attr('type', ($(password).attr('type') === 'password' ? 'text' : 'password'));
};

const isValid = ((pwd, confirmation) =>
  pwd === confirmation
);

const valid = (el, block) => {
  $(el).attr('aria-invalid', false);
  $(el).parent().removeClass('has-error');
  $(block).hide();
};
const invalid = (el, block) => {
  $(el).attr('aria-invalid', true);
  $(el).parent().addClass('has-error');
  $(block).show();
};

export const addMatchingPasswordValidator = (options) => {
  if (isObject(options) && isString(options.selector)) {
    const id = `${$(options.selector).attr('id')}_password_matcher`;

    const pwd = $(options.selector).find('#user_password');
    const cnf = $(options.selector).find('#user_password_confirmation');
    const sbmt = $(options.selector).find('[type="submit"]');

    if (isObject(pwd) && isObject(cnf) && isObject(sbmt)) {
      if (isValid($(pwd).val(), $(cnf).val())) {
        $(cnf).parent().append(getHelpBlock(id));
        $(cnf).attr('aria-describedby', id);

        $(sbmt).click((e) => {
          if (cnf.val() !== pwd.val()) {
            e.preventDefault();
            invalid(cnf, `#${id}`);
          } else {
            valid(cnf, `#${id}`);
          }
        });
      }
    }
  }
};

/*
 *   This function is expecting your HTML to be in the following format. Only one toggle
 *   is needed per form. It will toggle all password fields within the containing form:
 *     <input type="checkbox" class="passwords_toggle" />
 */
export const togglisePasswords = (options) => {
  if (isObject(options) && isString(options.selector)) {
    const toggle = $(`${options.selector} .passwords_toggle`);
    const pwds = $(`${options.selector} input[type="password"]`);

    if (pwds && toggle) {
      toggle.on('change', () => {
        if (isArray(pwds)) {
          pwds.forEach((pwd) => {
            togglePassword(pwd);
          });
        } else {
          togglePassword(pwds);
        }
      });
    }
  }
};
