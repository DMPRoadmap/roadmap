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

 Validation with a custom error message
 ------------------------
 To add a custom error message to a field's validation (default messages can be found
 in the constants.js file) just add a 'data-validation-error' attribute to the field.
   Example: `<input type="checkbox" name="user_accept_terms" val="0" aria-required="true"
                    data-validation-error="You must agree to the terms and conditions." />`

 Validation for radio buttons
 ------------------------
 To add validation to a set of `radio` buttons, use the rules listed above,
 but you should only attach them to the last `<input>` in the set.
   Example: `<input type="radio" name="radioInput" val="1" />
             <input type="radio" name="radioInput" val="2" aria-required="true" />`
*/
import { Tinymce } from './tinymce';
import { isObject, isString, isBoolean } from './isType';
import getConstant from '../constants';
import * as validator from './isValidInputType';

const validatableFields = (selector) => {
  if (isString(selector)) {
    return $(selector).find('[data-validation], [aria-required="true"]');
  }
  return [];
};
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
    } else if ($(el).is('.tinymce')) {
      return 'tinymce';
    } else if ($(el).is('textarea')) {
      return 'textarea';
    }
  }
  return false;
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
const addAsterisk = (el) => {
  const asterisk = '<span class="red" title="This field is required.">* </span>';
  if (isObject(el)) {
    switch (getValidationTypeForElement(el)) {
      case 'checkbox': {
        el.after(asterisk);
        break;
      }
      default: {
        const label = el.closest('.form-group').find('label');
        if (isObject(label)) {
          $(label[0]).before(asterisk);
        }
        break;
      }
    }
  }
};
const validationStates = {
  hasWarning: 'has-warning',
  hasError: 'has-error',
  hasSuccess: 'has-success',
};
const getValue = (type, el) => {
  switch (type) {
    case 'radio':
      return $(el).closest('form').find(`input[name="${$(el).attr('name')}"]:checked`).val();
    case 'select':
      return $(el).find(':selected').val();
    case 'tinymce':
      return Tinymce.findEditorById($(el).attr('id')).getContent();
    case 'checkbox':
      return ($(el).is(':checked') ? 'checked' : '');
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
    case 'textarea':
      return validator.isValidText(value);
    case 'tinymce':
      return validator.isValidText(value);
    case 'number':
      return validator.isValidNumber(value);
    case 'email':
      return validator.isValidEmail(value);
    case 'password':
      return validator.isValidPassword(value);
    case 'radio':
      return validator.isValidText(value);
    case 'select':
    case 'checkbox':
      return validator.isValidText(value);
    case 'js-combobox':
      return validator.isValidText(value);
    default:
      return false;
  }
};

const getDefaultValidationMessage = (type) => {
  switch (type) {
    case 'text':
      return getConstant('VALIDATION_MESSAGE_TEXT');
    case 'textarea':
      return getConstant('VALIDATION_MESSAGE_TEXT');
    case 'number':
      return getConstant('VALIDATION_MESSAGE_NUMBER');
    case 'email':
      return getConstant('VALIDATION_MESSAGE_EMAIL');
    case 'password':
      return getConstant('VALIDATION_MESSAGE_PASSWORD');
    case 'radio':
      return getConstant('VALIDATION_MESSAGE_RADIO');
    case 'checkbox':
      return getConstant('VALIDATION_MESSAGE_CHECKBOX');
    case 'js-combobox':
      return getConstant('VALIDATION_MESSAGE_SELECT');
    default:
      return getConstant('VALIDATION_MESSAGE_DEFAULT');
  }
};

const getValidationMessage = (el) => {
  if ($(el).attr('data-validation-error')) {
    return $(el).attr('data-validation-error');
  }
  // Use the default validation error message if none was specified
  return getDefaultValidationMessage(getValidationTypeForElement(el));
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
      const target = $(el);
      target.attr(ariaDescribedBy(`help${i}`));
      target.after(blockHelp(`help${i}`, getValidationMessage(el)));
      if (target.attr('aria-required') === 'true' && !options.excludeAsterisks) {
        addAsterisk(target);
      }
    });

    // Bind validations to the form's submit button
    $(`${options.selector}`).submit((e) => {
      let anyInvalid = false;
      let firstInvalid;
      validatable.each((i, el) => {
        const type = getValidationTypeForElement(el);
        const required = ($(el).attr('aria-required') && $(el).attr('aria-required') === 'true');

        // If the field is required OR its not empty
        if (required || $(el).val().trim() !== '') {
          if (isValid(type, getValue(type, el))) {
            valid(el);
          } else {
            anyInvalid = true;
            invalid(el);
            if (!isObject(firstInvalid)) {
              firstInvalid = el;
            }
          }
        }
      });
      if (anyInvalid) {
        e.preventDefault();
        // Set focus on the first invalid input
        if (isObject(firstInvalid)) {
          firstInvalid.focus();
        }
      }
    });
  }
};
