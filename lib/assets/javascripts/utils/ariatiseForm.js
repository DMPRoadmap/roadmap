import { isObject, isString, isBoolean } from './isType';
import * as constants from '../constants';
import * as validator from './isValidInputType';

const validatableFields = (selector) => {
  if (isString(selector)) {
    return $(selector).find('[data-validation], [aria-required="true"]');
  }
};
const blockHelp = (id, msg) => {
  if (isString(id) && isString(msg)) {
    return `<span id="${id}" class="help-block" style="display:none;">${msg}</span>`;
  }
  return '';
};
const ariaDescribedBy = (value) => {
  if (value) {
    return { 'aria-describedby': value };
  }
  return null;
};
const ariaInvalid = (value) => {
  if (isBoolean(value)) {
    return { 'aria-invalid': value };
  }
  return { 'aria-invalid': false };
};

const validationStates = {
  hasWarning: 'has-warning',
  hasError: 'has-error',
  hasSuccess: 'has-success' };

const getValidationTypeForElement = (el) => {
  const validation = $(el).attr('data-validation');
  // if the specified validation type is defined
  if (validation) {
    return $(el).attr('data-validation');

  // Otherwise if the element is required validate based on its type
  } else if ($(el).attr('aria-required') === 'true') {
    // TODO: Need to deal with select and radio as well!
    return ($(el).prop('tagName') === 'textarea' ? 'text' : $(el).attr('type'));
  }
  return false;
};

const isValid = (type, value) => {
  // TODO add more validation for each new type coming along by:
  // 1. defining a function at dmproadmap.utils.validate
  // 2. adding the case in the switch below

  // See if a specific data-validation was specified 
  switch (type) {
    case 'text':
      return validator.isValidText(value);
    case 'number':
      return validator.isValidNumber(value);
    case 'email':
      return validator.isValidEmail(value);
    case 'password':
      return validator.isValidPassword(value);
    default:
      return false;
  }
};

const getValidationMessage = (type) => {
  switch (type) {
    case 'text':
      return constants.VALIDATION_MESSAGE_TEXT;
    case 'number':
      return constants.VALIDATION_MESSAGE_NUMBER;
    case 'email':
      return constants.VALIDATION_MESSAGE_EMAIL;
    case 'password':
      return constants.VALIDATION_MESSAGE_PASSWORD;
    default:
      return constants.VALIDATION_MESSAGE_DEFAULT;
  }
};

const valid = (el) => {
  $(el).parent().removeClass(validationStates.hasError);
  $(el).attr(ariaInvalid(false));
  $(el).next().hide();
};
const invalid = (el) => {
  $(el).parent().addClass(validationStates.hasError);
  $(el).attr(ariaInvalid(true));
  $(el).next().show();
};

export default (options) => {
  if (isObject(options) && options.selector) {
    const validatable = validatableFields(options.selector);

    // Add validation error message sections for each validatable input element
    validatable.each((i, el) => {
      const type = getValidationTypeForElement(el);
      $(el).attr(ariaDescribedBy(`help${i}`));
      $(el).after(blockHelp(`help${i}`, getValidationMessage(type)));
    });

    // Bind validations to the form's submit button
    $(`${options.selector} [type="submit"]`).click((e) => {
      validatable.each((i, el) => {
        const type = getValidationTypeForElement(el);
        const required = ($(el).attr('aria-required') && $(el).attr('aria-required') === 'true');

        // If the field is required OR its not empty
        if (required || $(el).val().trim() !== '') {
          if (isValid(type, $(el).val())) {
            valid(el);
          } else {
            e.preventDefault();
            invalid(el, getValidationMessage(type));
          }
        }
      });
    });
  }
};
