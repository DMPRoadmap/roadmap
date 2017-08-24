import { isObject, isString } from './isType';
import * from './isValidInputType';

const validatableFields = (selector) => {
  return $(selector).find('.form-control').filter('[data-validation],[aria-required="true"]');
}
const blockHelp = (id) => {
  return '<span id="'+id+'" class="help-block" style="display:none;"></span>';
}
const ariaDescribedBy = (value) => {
  return { 'aria-describedby': value };
}
const ariaInvalid = (value) => {
  return { 'aria-invalid': value };
}

const validationStates = {
  hasWarning: 'has-warning',
  hasError: 'has-error',
  hasSuccess: 'has-success'
};
    
const getValidationTypeForElement = (el) => {
  const validation = $(el).attr('data-validation');
  // if the specified validation type is defined
  if(validation && dmproadmap.utils.validate[validation]){
    return $(el).attr('data-validation');

  // Otherwise if the element is required validate based on its type
  }else if($(el).attr('aria-required') === 'true'){
    // TODO: Need to deal with select and radio as well!
    return ($(el).prop('tagName') === 'textarea' ? 'text' : $(el).attr('type'));
  }
  return false;
}
    
const isValid = (type,value) => {
  // TODO add more validation for each new type coming along by:
  // 1. defining a function at dmproadmap.utils.validate
  // 2. adding the case in the switch below

  // See if a specific data-validation was specified 
  switch(type){
  case 'text':
    return isValidText(value);
  case 'number':
    return isValidNumber(value);
  case 'email':
    return isValidEmail(value);
  case 'password':
    return isValidPassword(value);
  default:
    return false;
  }
}

const getValidationMessage = (type) => {
  switch(type){
  case 'text':
    return VALIDATION_MESSAGE_TEXT;
  case 'number':
    return VALIDATION_MESSAGE_NUMBER;
  case 'email':
    return VALIDATION_MESSAGE_EMAIL;
  case 'password':
    return VALIDATION_MESSAGE_PASSWORD;
  default:
    return VALIDATION_MESSAGE_DEFAULT;
  }
}

const valid = (el) => {
  $(el).parent().removeClass(validationStates.hasError);
  $(el).attr(ariaInvalid(false));
  $(el).next().hide();
})
const invalid = (el,msg) => {
  $(el).parent().addClass(validationStates.hasError);
  $(el).attr(ariaInvalid(true));
  $(el).next().text(msg).show();
})
    
export let ariatisedForm = (...options) => {
  if($ && isObject(options) && isString(options.selector)){
    // Add validation error message sections for each validatable input element
    validatableFields(options.selector).each(function(i,el){
      $(el).attr(ariaDescribedBy('help'+i));
      $(el).after(blockHelp('help'+i, getValidationTypeForElement(el)));
    });

    // Bind validations to the form's submit button
    $(options.selector+' [type="submit"]').click(function(e){
      validatableFields(options.selector).each(function(i,el){
        const type = getValidationTypeForElement(el);
        if(isValid(type)){
          valid(el);
        }else{
          e.preventDefault();
          invalid(el, getValidationMessage(type));
        }
      });
    });
  }
};

// Allows you to programmatically hide an error message
ariatisedForm.hideValidationError = (el) => {
  if(isObject(el)){
    valid(el);
  }
}
// Allows you to programmatically display an error message
ariatisedForm.showValidationError = (el,msg) => {
  if(isObject(el) && isString(msg)){
    invalid(el,msg);
  }
}
