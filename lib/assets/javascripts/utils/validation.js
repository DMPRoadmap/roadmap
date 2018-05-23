import { Tinymce } from './tinymce';
import { isObject, isString, isBoolean } from './isType';
import getConstant from '../constants';
import * as validator from './isValidInputType';

const isValidatableField = ctx => $(ctx).attr('data-validatable') === 'true';
const validatableFields = (ctx) => {
  if (isObject(ctx)) {
    return $(ctx).find('[data-validation], [aria-required="true"]');
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
const ariaInvalid = (value) => {
  if (isBoolean(value)) {
    return { 'aria-invalid': value };
  }
  return { 'aria-invalid': false };
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
    case 'url':
      return validator.isValidUrl(value);
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
    case 'url':
      return getConstant('VALIDATION_MESSAGE_URL');
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
const addValidationMessage = (el, excludeAsterisks) => {
  const target = $(el);
  if (isString(target.attr('id'))) {
    const id = target.attr('id');
    if (!isString(target.attr('aria-describedby'))) {
      target.after(blockHelp(`help-${id}`, getValidationMessage(el)));
      target.attr('aria-describedby', `help-${id}`);
      target.attr('data-validatable', 'true');
    }
  }
  if (target.attr('aria-required') === 'true' && !excludeAsterisks) {
    addAsterisk(target);
  }
};
const removeValidationMessage = (el) => {
  const target = $(el);
  if (isString(target.attr('id'))) {
    const parent = target.parent();
    parent.removeClass(validationStates.hasError);
    parent.find('.help-block').remove();
    target.removeAttr('aria-describedby');
    target.removeAttr('data-validatable');
  }
};

const checkValidations = (el) => {
  const type = getValidationTypeForElement(el);
  const value = getValue(type, el);
  // A field is validatable if has data-validatable attribute set to true
  if (isValidatableField(el)) {
    if (isValid(type, value)) {
      valid(el);
      return true;
    }
    invalid(el);
    return false;
  }
  return true;
};

export const enableValidations = (ctx, excludeAsterisks = false) => {
  if (isObject(ctx)) {
    if ($(ctx).is('input')) {
      addValidationMessage(ctx, excludeAsterisks);
    } else {
      validatableFields(ctx).each((i, el) => {
        addValidationMessage(el, excludeAsterisks);
      });
    }
  }
};

export const disableValidations = (ctx) => {
  if (isObject(ctx)) {
    if ($(ctx).is('input')) {
      removeValidationMessage(ctx);
    } else {
      validatableFields(ctx).each((i, el) => {
        removeValidationMessage(el);
      });
    }
  }
};

export const validate = (ctx) => {
  let anyInvalid = false;
  let firstInvalid;
  if (isObject(ctx)) {
    if ($(ctx).is('input')) {
      anyInvalid = !checkValidations(ctx);
    } else {
      validatableFields(ctx).each((i, el) => {
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
