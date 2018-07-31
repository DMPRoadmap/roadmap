import getConstant from '../constants';
import { Tinymce } from './tinymce';
import { isObject, isString } from './isType';
import * as inputValidator from './isValidInputType';

const asteriskBlock = `<span class="red asterisk" title="${getConstant('VALIDATION_MESSAGE_TEXT')}">* </span>`;

const ariaInvalidAttr = 'aria-invalid';
const requiredFieldAttr = 'aria-required';
const validationTypeAttr = 'data-validation';
const validationErrorMessageAttr = 'data-validation-error';
const referenceToErrorMessageAttr = 'aria-describedby';
const validationErrorClass = 'has-error';

const asteriskSelector = '.asterisk';
const multiOptionSelector = '[type="radio"], [type="checkbox"]';
const validatableSelector = `[${validationTypeAttr}], [${requiredFieldAttr}="true"]`;

const isValidatable = jqueryObj => isObject(jqueryObj) &&
  jqueryObj.is(`${validatableSelector}`) &&
  isString(jqueryObj.attr('id'));

const isMultiOption = (jqueryObj) => {
  if (jqueryObj.is(`${multiOptionSelector}`)) {
    const fieldset = jqueryObj.closest('fieldset');
    return fieldset.length > 0 && fieldset.find('legend').length > 0;
  }
  return false;
};

const getHelpBlock = (id, msg) => {
  if (isString(id) && isString(msg)) {
    return `<span id="${id}" class="help-block" style="display:none;">${msg}</span>`;
  }
  return '';
};

const getValidationType = (jqueryObj) => {
  const validation = jqueryObj.attr(`${validationTypeAttr}`);
  // if the specified validation type is defined
  if (validation) {
    return validation;
  // Otherwise if the element is required validate based on its type
  } else if (jqueryObj.attr(`${requiredFieldAttr}`) === 'true') {
    if (jqueryObj.is('input')) {
      const type = jqueryObj.attr('type'); // available types at https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Form_<input>_types
      if (isMultiOption(jqueryObj)) {
        return 'multi-option';
      }
      return type;
    } else if (jqueryObj.is('select')) {
      return 'select';
    } else if (jqueryObj.is('.tinymce')) {
      return 'tinymce';
    } else if (jqueryObj.is('textarea')) {
      return 'textarea';
    }
  }
  return false;
};

const getDefaultValidationMessage = (jqueryObj) => {
  const type = getValidationType(jqueryObj);
  if (isString(type)) {
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
      case 'multi-option':
        return getConstant('VALIDATION_MESSAGE_MULTI_OPTION');
      case 'js-combobox':
        return getConstant('VALIDATION_MESSAGE_SELECT');
      default:
        return getConstant('VALIDATION_MESSAGE_DEFAULT');
    }
  }
  return false;
};

const getValidationMessage = (jqueryObj) => {
  if ($(jqueryObj).attr(`${validationErrorMessageAttr}`)) {
    return $(jqueryObj).attr(`${validationErrorMessageAttr}`);
  }
  // Use the default validation error message if none was specified
  return getDefaultValidationMessage(jqueryObj);
};

const removeAsterisk = (jqueryObj) => {
  if (isMultiOption(jqueryObj)) {
    jqueryObj.closest('fieldset').find(`${asteriskSelector}`).remove();
  } else {
    jqueryObj.closest('.form-group').find(`${asteriskSelector}`).remove();
  }
};

// Add an asterisk to the Field's Label or the Fieldset Legend
const addAsterisk = (jqueryObj) => {
  if (isMultiOption(jqueryObj)) {
    const legend = jqueryObj.closest('fieldset').find('legend');
    if (isObject(legend)) {
      legend.html(`${asteriskBlock} ${legend.html()}`);
    }
  } else {
    const label = jqueryObj.closest('.form-group').find('label');
    if (isObject(label)) {
      label.html(`${asteriskBlock} ${label.html()}`);
    }
  }
};

const removeValidationMessage = (jqueryObj) => {
  if (!isString(jqueryObj.attr(`${referenceToErrorMessageAttr}`))) {
    $(jqueryObj.attr(`${referenceToErrorMessageAttr}`)).remove();
  }
};

const addValidationMessage = (jqueryObj) => {
  const helpBlockId = `help-${jqueryObj.attr('id')}`;
  const helpBlock = getHelpBlock(helpBlockId, getValidationMessage(jqueryObj));

  if (!isString(jqueryObj.attr(`${referenceToErrorMessageAttr}`))) {
    if (isMultiOption(jqueryObj)) {
      jqueryObj.closest('.form-group').before(helpBlock);
    } else {
      jqueryObj.after(helpBlock);
    }
    jqueryObj.attr(`${referenceToErrorMessageAttr}`, helpBlockId);
  }
};

const getValue = (jqueryObj) => {
  switch (getValidationType(jqueryObj)) {
    case 'radio':
      return jqueryObj.closest('form').find(`input[name="${jqueryObj.attr('name')}"]:checked`).val();
    case 'select':
      return jqueryObj.find(':selected').val();
    case 'tinymce':
      return Tinymce.findEditorById(jqueryObj.attr('id')).getContent();
    case 'checkbox':
    case 'multi-checkbox':
      return (jqueryObj.is(':checked') ? 'checked' : '');
    default:
      return jqueryObj.val();
  }
};

const isValid = (jqueryObj) => {
  // See if a specific data-validation was specified
  switch (getValidationType(jqueryObj)) {
    case 'text':
    case 'textarea':
    case 'tinymce':
    case 'select':
    case 'radio':
    case 'js-combobox':
      return inputValidator.isValidText(getValue(jqueryObj));
    case 'number':
      return inputValidator.isValidNumber(getValue(jqueryObj));
    case 'email':
      return inputValidator.isValidEmail(getValue(jqueryObj));
    case 'password':
      return inputValidator.isValidPassword(getValue(jqueryObj));
    case 'checkbox':
      return inputValidator.isValidCheckbox(jqueryObj);
    case 'multi-checkbox':
      return inputValidator.isValidMultiOption(jqueryObj);
    default:
      return false;
  }
};

const toggleValidationMessage = (jqueryObj) => {
  if (isObject(jqueryObj)) {
    if (isValid(jqueryObj)) {
      jqueryObj.parent().removeClass(`${validationErrorClass}`);
      jqueryObj.attr(`${ariaInvalidAttr}`, 'false');
      $(`#${jqueryObj.attr(`${referenceToErrorMessageAttr}`)}`).hide();
    } else {
      jqueryObj.parent().addClass(`${validationErrorClass}`);
      jqueryObj.attr(`${ariaInvalidAttr}`, 'true');
      $(`#${jqueryObj.attr(`${referenceToErrorMessageAttr}`)}`).show();
    }
  }
};

// Exportable methods
export const enableValidation = (jqueryObj, checkOnBlur = true, excludeAsterisk = false) => {
  if (isValidatable(jqueryObj)) {
    addValidationMessage(jqueryObj);
    if (jqueryObj.attr('aria-required') === 'true' && !excludeAsterisk) {
      addAsterisk(jqueryObj);
    }
    if (checkOnBlur) {
      jqueryObj.on('blur', e => toggleValidationMessage($(e.target)));
    }
  }
};

export const disableValidation = (jqueryObj) => {
  if (isObject(jqueryObj) && jqueryObj.is(`${validatableSelector}`)) {
    removeValidationMessage(jqueryObj);
    removeAsterisk(jqueryObj);
  }
};

export const enableValidations = (jqueryObj, checkOnBlur = true, excludeAsterisks = false) => {
  if (isObject(jqueryObj)) {
    jqueryObj.find(`${validatableSelector}`).each((i, el) => {
      enableValidation($(el), checkOnBlur, excludeAsterisks);
    });
  }
};
