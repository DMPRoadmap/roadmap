import * as validator from './isValidInputType';
import getConstant from '../constants';
import { isObject, isString, isBoolean } from './isType';

const isValidatableField = jqueryObj => $(jqueryObj).is('[data-validatable] | [aria-required="true"]');

const getValidationType = (jqueryObj) => {
  const validation = $(jqueryObj).attr('data-validation');
  // if the specified validation type is defined
  if (validation) {
    return validation;

  // Otherwise if the element is required validate based on its type
  } else if ($(jqueryObj).attr('aria-required') === 'true') {
    if ($(jqueryObj).is('input')) {
      const type = $(jqueryObj).attr('type'); // available types at https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Form_<input>_types
      if (type === 'checkbox' && $(jqueryObj).closest('fieldset').length > 0) {
        return 'options';
      }
      return type;
    } else if ($(jqueryObj).is('select')) {
      return 'select';
    } else if ($(jqueryObj).is('.tinymce')) {
      return 'tinymce';
    } else if ($(jqueryObj).is('textarea')) {
      return 'textarea';
    }
  }
  return false;
};

const getDefaultValidationMessage = (type) => {
  switch (type) {
    case 'text':
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
    case 'multi-checkbox':
      return getConstant('VALIDATION_MESSAGE_MULTI_CHECKBOX');
    case 'js-combobox':
      return getConstant('VALIDATION_MESSAGE_SELECT');
    default:
      return getConstant('VALIDATION_MESSAGE_DEFAULT');
  }
};

const getValidationMessage = (jqueryObj) => {
  if ($(jqueryObj).attr('data-validation-error')) {
    return $(jqueryObj).attr('data-validation-error');
  }
  // Use the default validation error message if none was specified
  return getDefaultValidationMessage(getValidationType(jqueryObj));
};

const removeAsterisk = (jqueryObj) => {
  if (isObject(jqueryObj)) {
    const type = getValidationType(jqueryObj);
    if (jqueryObj.closest('fieldset').length > 0) {
      jqueryObj.closest('fieldset').find('.asterisk').remove();
    } else {
      jqueryObj.closest('.form-group').find('.asterisk').remove();
    }
  }
};

const addAsterisk = (jqueryObj) => {
  if (isObject(jqueryObj)) {
    const asterisk = `<span class="red asterisk" title="${getConstant('VALIDATION_MESSAGE_TEXT')}">* </span>`;
    const type = getValidationType(jqueryObj);
    if (jqueryObj.closest('fieldset').length > 0 &&
        jqueryObj.closest('fieldset').find('legend').length > 0) {
      const legend = jqueryObj.closest('fieldset').find('legend');
      legend.html(`${asterisk} ${legend.html()}`);
    } else if (type === 'checkbox' || type === 'radio') {
      jqueryObj.after(asterisk);
    } else {
      const label = jqueryObj.closest('.form-group').find('label');
      if (isObject(label)) {
        $(label[0]).before(asterisk);
      }
    }
  }
};

const addValidationMessage = (jqueryObj) => {
  if (isString(jqueryObj.attr('id'))) {
    const fieldId = jqueryObj.attr('id');
    const fieldType = getValidationType(jqueryObj);
    const helpBlock = blockHelp(`help-${id}`, getValidationMessage(el));

    if (!isString(jqueryObj.attr('aria-describedby'))) {
      if (typ === 'radio' || typ === 'checkbox') {
        jqueryObj.closest('.form-group').before(blockHelp(`help-${id}`, getValidationMessage(jqueryObj)));
      } else {
        jqueryObj.after(blockHelp(`help-${id}`, getValidationMessage(jqueryObj)));
      }
      jqueryObj.attr('validation-help-block', `help-${id}`);
      jqueryObj.attr('data-validatable', 'true');
    }
  }
};

const removeValidationMessage = (jqueryObj) => {

};

const toggleValidationMessage = (jqueryObj) => {

};

const isValid = (jqueryObj) => {

};

// Exportable methods
export const enableValidation = (jqueryObj, excludeAsterisk=false) => {
  if (validatableField(jqueryObj)) {
    addValidationMessage(jqueryObj);
    if (jqueryObj.attr('aria-required') === 'true' && !excludeAsterisks) {
      addAsterisk(jqueryObj);
    }
  }
};

export const disableValidation = (jqueryObj) => {
  if (validatableField(jqueryObj)) {
    removeValidationMessage(jqueryObj);
    removeAsterisk(jqueryObj);
  }
};

export const validate = (jqueryObj) => {
  let anyInvalid = false;
  let firstInvalid;
  if (isObject(jqueryObj)) {
    if ($(jqueryObj).is('input')) {
      anyInvalid = !checkValidations(jqueryObj);
    } else {
      validatableFields(jqueryObj).each((i, el) => {
        if (!checkValidations(el)) {
          anyInvalid = true;
          if (!isObject(firstInvalid)) {
            firstInvalid = el;
          }
        }
      });
      // Set focus on the first invalid input
      if (isObject(firstInvalid)) {
        firstInvalid.focus();
      }
    }
  }
  return !anyInvalid;
};
