import getConstant from '../constants';
import { Tinymce } from './tinymce';
import { isObject, isArray, isString } from './isType';
import * as inputValidator from './isValidInputType';

/*
 * This code expects the following attributes on your fields to properly
 * wire up field validation. <input> in the example below is interchangeable
 * with <textarea>, <select> and <... class="tinymce">
 *
 * You should not enableValidations until after all other JS that helps
 * render your form fields has finsihed (e.g. Tinymce, autocomplete, etc.)
 *
 * Default validation error messages are defined in the json block
 * at the bottom of app/views/layouts/application.rb
 *
 * <input id="???"                       // A unique id is required!
 *        type="???"                     // Determines location of error text and validation logic
 *        validatable                    // Will add validation to field
 *        validatable-type="???"         // Override the field's type, see below
 *        validatable-required           // Will add an asterisk (*) to label and ensure no blanks
 *        validatable-error="???"        // Overrides default error message
 *        validatable-no-blur>           // Skips the field blur event handler
 *
 * If you specify 'validatable-required' you do not need to include 'validatable'
 *
 * The 'validatable-type' entry allows you to override the object's type. For
 * example <input type="text" validatable="true" validatable-type="email"> would
 * ensure that the value of the text field is an email. You can exclude this
 * attribute if you do not wish to override the field's type.
 *
 * The code will then attach the following:
 *   1) A required asterisk (*) <span> to the label (if applicable)
 *   2) A block that contains your error message
 *   3) Handlers for both the field's blur and form's submit events
 */
// -----------------------------------
// Validatable attributes
// --------------------------------
const validatableAttr = 'validatable';
const isRequiredAttr = 'validatable-required';
const typeOverrideAttr = 'validatable-type';
const errorMessageAttr = 'validatable-error';
const noBlurAttr = 'validatable-no-blur';

const validatableSelector = `[${validatableAttr}], [${isRequiredAttr}]`;

const isValidatable = jqueryObj => jqueryObj.is(validatableSelector) && isString(jqueryObj.attr('id'));
const isRequired = jqueryObj => jqueryObj.is(`[${isRequiredAttr}]`);
const skipBlurHandler = jqueryObj => jqueryObj.is(`[${noBlurAttr}]`);
const typeOverride = jqueryObj => jqueryObj.attr(`${typeOverrideAttr}`);
const messageOverride = jqueryObj => jqueryObj.attr(`${errorMessageAttr}`);

// -----------------------------------
// Validation type
// -----------------------------------
const getValidationType = (jqueryObj) => {
  const override = typeOverride(jqueryObj);
  if (override) {
    return override;
  // Otherwise if the element is required validate based on its type
  } else if (isRequired(jqueryObj)) {
    if (jqueryObj.is('fieldset')) {
      return 'multi-option';
    } else if (jqueryObj.is('select')) {
      return 'select';
    } else if (jqueryObj.is('.tinymce')) {
      return 'tinymce';
    } else if (jqueryObj.is('textarea')) {
      return 'textarea';
    }
    return jqueryObj.attr('type');
  }
  return false;
};

// -----------------------------------
// Validation message
// -----------------------------------
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
      case 'password-match':
        return getConstant('VALIDATION_MESSAGE_PASSWORDS_MATCH');
      default:
        return getConstant('VALIDATION_MESSAGE_DEFAULT');
    }
  }
  return false;
};

const getValidationMessage = (jqueryObj) => {
  const override = messageOverride(jqueryObj);
  if (isString(override)) {
    return override;
  }
  return getDefaultValidationMessage(jqueryObj);
};

// -----------------------------------
// Dom elements
// --------------------------------
const asteriskBlockId = jqueryObj => `${jqueryObj.attr('id')}-asterisk`;
const helpBlockId = jqueryObj => `${jqueryObj.attr('id')}-help`;
const asteriskBlock = (jqueryObj, msg) => {
  if (isString(msg)) {
    return `<span id="${asteriskBlockId(jqueryObj)}" class="red asterisk" title="${msg}">* </span>`;
  }
  return '';
};
const helpBlock = (id, msg) => {
  if (isString(msg)) {
    return `<span id="${id}" class="help-block" role="alert" style="display:none;">${msg}</span>`;
  }
  return '';
};

const addDomElements = (jqueryObj) => {
  const isFieldset = jqueryObj.is('fieldset');
  const label = (isFieldset ? jqueryObj.find('legend') : jqueryObj.closest('.form-group').find('label'));
  const asterisk = asteriskBlock(jqueryObj, getConstant('VALIDATION_MESSAGE_TEXT'));
  const help = helpBlock(helpBlockId(jqueryObj), getValidationMessage(jqueryObj));

  if (isRequired(jqueryObj)) {
    label.html(`${asterisk} ${label.text()}`);
  }
  if (isFieldset) {
    label.after(help);
  } else {
    jqueryObj.after(help);
  }
};

const removeDomElements = (jqueryObj) => {
  const id = jqueryObj.attr('id');
  if (isString(id)) {
    $(asteriskBlockId(jqueryObj)).remove();
    $(helpBlockId(jqueryObj)).remove();
  }
};

// -----------------------------------
// Aria attributes
// --------------------------------
const ariaInvalidAttr = 'aria-invalid';
const ariaRequiredAttr = 'aria-required';
const ariaDescribedByAttr = 'aria-describedby';

const addAriaAttrs = (jqueryObj) => {
  if (isRequired(jqueryObj)) {
    jqueryObj.attr(ariaRequiredAttr, 'true');
  }
  jqueryObj.attr(ariaDescribedByAttr, helpBlockId(jqueryObj));
};
const removeAriaAttrs = (jqueryObj) => {
  jqueryObj.removeAttr(ariaRequiredAttr);
  jqueryObj.removeAttr(ariaDescribedByAttr);
};
const setValidAriaAttrs = jqueryObj => jqueryObj.attr(ariaInvalidAttr, 'false');
const setInvalidAriaAttrs = jqueryObj => jqueryObj.attr(ariaInvalidAttr, 'true');

// -----------------------------------
// Validation
// -----------------------------------
const getMultipleValues = (jqueryObjArray) => {
  if (isArray(jqueryObjArray)) {
    return jqueryObjArray.map(i => i.val()).filter(j => j);
  }
  return [];
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
    case 'password-match':
      return getMultipleValues([
        jqueryObj,
        $(`#${jqueryObj.attr('validatable-match-against')}`),
      ]);
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
    case 'password-match':
      return inputValidator.isValidMatch(getValue(jqueryObj));
    default:
      return false;
  }
};

// -----------------------------------
// Hide/Show validation message
// -----------------------------------
const bootstrapErrorClass = 'has-error';

const makeFieldValid = (jqueryObj) => {
  jqueryObj.parent().removeClass(`${bootstrapErrorClass}`);
  setValidAriaAttrs(jqueryObj);
  $(`#${helpBlockId(jqueryObj)}`).hide();
};
const makeFieldInvalid = (jqueryObj) => {
  jqueryObj.parent().addClass(`${bootstrapErrorClass}`);
  setInvalidAriaAttrs(jqueryObj);
  $(`#${helpBlockId(jqueryObj)}`).show();
};
const toggleValidationMessage = (jqueryObj) => {
  if (isObject(jqueryObj) && isValidatable(jqueryObj)) {
    if (isValid(jqueryObj)) {
      makeFieldValid(jqueryObj);
    } else {
      makeFieldInvalid(jqueryObj);
      return false;
    }
  }
  return true;
};

// -----------------------------------
// Validation event handlers
// -----------------------------------
const validationHandler = event => toggleValidationMessage($(event.target));
const removeBlurHandler = jqueryObj => jqueryObj.unbind('blur', e => validationHandler(e));
const addBlurHandler = jqueryObj => jqueryObj.bind('blur', e => validationHandler(e));
const removeSubmitHandler = formObj => formObj.unbind('submit', e => validationHandler(e));
const addSubmitHandler = formObj => formObj.bind('submit', (e) => {
  let firstFailure;
  $(e.target).find(validatableSelector).each((i, el) => {
    const target = $(el);
    if (!toggleValidationMessage(target) && !firstFailure) {
      firstFailure = target;
    }
  });

  if (firstFailure) {
    e.preventDefault();
    firstFailure.focus();
  }
});

const removeFieldEventHandlers = jqueryObj => removeBlurHandler(jqueryObj);
const addFieldEventHandlers = (jqueryObj) => {
  if (!skipBlurHandler(jqueryObj)) {
    addBlurHandler(jqueryObj);
  }
};

// -----------------------------------
// Entrypoints
// -----------------------------------
// Allows validations to be displayed hidden outside of the normal
// blur and submit events (e.g. checking that passwords match)
export const showValidationError = (jqueryObj) => {
  if (isObject(jqueryObj) && isValidatable(jqueryObj)) {
    makeFieldValid(jqueryObj);
  }
};
export const hideValidationError = (jqueryObj) => {
  if (isObject(jqueryObj) && isValidatable(jqueryObj)) {
    makeFieldInvalid(jqueryObj);
  }
};

// Enable or disable the specific JQuery object
export const enableValidation = (jqueryObj) => {
  if (isObject(jqueryObj) && isValidatable(jqueryObj)) {
    addAriaAttrs(jqueryObj);
    addDomElements(jqueryObj);
    addFieldEventHandlers(jqueryObj);
  }
};
export const disableValidation = (jqueryObj) => {
  if (isObject(jqueryObj) && isValidatable(jqueryObj)) {
    removeAriaAttrs(jqueryObj);
    removeDomElements(jqueryObj);
    removeFieldEventHandlers(jqueryObj);
  }
};

// Enable, disable or validate by selector (can be a form, form field, etc.)
export const enableValidations = (options) => {
  if (isObject(options) && options.selector) {
    const jqueryObj = $(`${options.selector}`);
    if (isValidatable(jqueryObj)) {
      enableValidation(jqueryObj);
    } else {
      jqueryObj.find(validatableSelector).each((i, el) => {
        enableValidation($(el));
      });
      if (!options.skipSubmitHandler && jqueryObj.is('form')) {
        addSubmitHandler(jqueryObj);
      }
    }
  }
};
export const disableValidations = (options) => {
  if (isObject(options) && options.selector) {
    const jqueryObj = $(`${options.selector}`);
    if (isValidatable(jqueryObj)) {
      disableValidation(jqueryObj);
    } else {
      jqueryObj.find(validatableSelector).each((i, el) => {
        disableValidation($(el));
      });
      removeSubmitHandler(jqueryObj);
    }
  }
};
export const validate = (options) => {
  if (isObject(options) && options.selector) {
    const jqueryObj = $(`${options.selector}`);
    if (isValidatable(jqueryObj)) {
      toggleValidationMessage(jqueryObj);
    } else {
      jqueryObj.find(validatableSelector).each((i, el) => {
        toggleValidationMessage($(el));
      });
    }
  }
};
