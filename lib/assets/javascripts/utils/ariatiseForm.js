/*
 This module allows you to add the necessary aria tags to your form elements to 
 make them accessible and wire up client-side error handling. Usage:

 Required Fields
 ------------------------
 To make a field required just add the `aria-required="true"` attribute to the 
 input element. The element's `type` attribute will be used to determine what 
 validation method will be used. 
   Example: `<input type="email" aria-required="true" />`

 Validation for fields that are not required
 ------------------------
 To add validation to a field that is not required, just add the 
 `data-validation="<type>"` to the input element. Validation checks will only 
 be run if the field has a value.
   Example: `<input type="email" data-validation="email" />`

 Validation for radio buttons
 ------------------------
 To add validation to a set of `radio` buttons, use the rules listed above, 
 but you should only attach them to the last `<input>` in the set.
   Example: `<input type="radio" name="radioInput" val="1" /> 
             <input type="radio" name="radioInput" val="2" aria-required="true" />`
*/

import { isObject, isString, isBoolean } from './isType';
import * as constants from '../constants';
import * as validator from './isValidInputType';

const validatableFields = (selector) => {
  if (isString(selector)) {
    return $(selector).find('[data-validation], [aria-required="true"]');
  }
  return [];
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
    return validation;

  // Otherwise if the element is required validate based on its type
  } else if ($(el).attr('aria-required') === 'true') {
    if ($(el).is('input')) {
      return $(el).attr('type'); // available types at https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Form_<input>_types
    } else if ($(el).is('select')) {
      return 'select';
    } else if ($(el).is('textarea')) {
      return 'textarea';
    }
  }
  return false;
};

const getValue = (type, el) => {
  switch (type) {
    case 'radio':
      return $(el).closest('form').find(`input[name="${$(el).attr('name')}"]:checked`).val();
    default:
      return $(el).val();
  }
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
    case 'radio':
      return validator.isValidText(value);
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
    case 'radio':
      return constants.VALIDATION_MESSAGE_RADIO;
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
      let anyInvalid = false;
      validatable.each((i, el) => {
        const type = getValidationTypeForElement(el);
        const required = ($(el).attr('aria-required') && $(el).attr('aria-required') === 'true');

        // If the field is required OR its not empty
        if (required || $(el).val().trim() !== '') {
          if (isValid(type, getValue(type, el))) {
            valid(el);
          } else {
            anyInvalid = true;
            invalid(el, getValidationMessage(type));
          }
        }
      });
      if (anyInvalid) {
        e.preventDefault();
      }
    });
  }
};
