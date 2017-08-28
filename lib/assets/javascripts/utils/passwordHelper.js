import { VALIDATION_MESSAGE_PASSWORDS_MATCH, SHOW_PASSWORD_MESSAGE } from '../constants';
import { isObject, isString } from './isType';

const getHelpBlock = (id) => {
  if (isString(id)) {
    return `<span id="${id}" class="help-block" style="display: none;">
            ${VALIDATION_MESSAGE_PASSWORDS_MATCH}</span>`;
  }
  return '';
};

const getShowPasswordCheckbox = () => {
  return `<input id="password_toggle" class="form-control" type="checkbox" />
          <label class="control-label" for="password_toggle">${SHOW_PASSWORD_MESSAGE}</label>`;
};

const togglePassword = (password) => {
  $(password).attr('type', ($(password).attr('type') === 'password' ? 'text' : 'password'));
};

const isValid = (pwd, confirmation) => {
  return pwd === confirmation;
};

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

export const addShowHidePasswordControl = (options) => {
  if (isObject(options) && isString(options.selector)) {
    $(options.selector).each((idx, pwd) => {
      $(pwd).parent().append(getShowPasswordCheckbox(pwd));
      $(pwd).siblings('#password_toggle').on('change', (e) => {
        togglePassword(pwd);
      });
    });
  }
};
