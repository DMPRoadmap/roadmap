import { isObject, isString, isArray } from './isType';

const togglePassword = (password) => {
  $(password).attr('type', ($(password).attr('type') === 'password' ? 'text' : 'password'));
};

/*
 *   This function is expecting your HTML to be in the following format. Only one toggle
 *   is needed per form. It will toggle all password fields within the containing form:
 *     <input type="checkbox" class="passwords_toggle" />
 */
export default (options) => {
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
