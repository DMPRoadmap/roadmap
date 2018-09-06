import { isObject, isString, isNumber } from './isType';
import getConstant from '../constants';
/*
  Validates whether or not the value passed matches to a valid email
  @param value String to search for a match
  @return true or false
*/
export const isValidEmail = (value) => {
  if (isString(value)) {
    return /[^@\s]+@(?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,}$/.test(value);
  }
  return false;
};

/*
  Validates whether or not the value passed matches to a valid url
  @param value String to search for a match
  @return true or false
*/
export const isValidUrl = (value) => {
  if (isString(value)) {
    return /https?:\/\/[-a-zA-Z0-9@:%_+.~#?&=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_+.~#?&=]*)?/.test(value);
  }
  return false;
};

/*
  Validates whether or not the value passed is a valid number.
  @param value Number to validate
*/
export const isValidNumber = (value) => {
  if (isString(value)
  && value.trim().length > 0) { // Only if is non-empty string value we try to convert to Number
    // since Number([]), Number(new Date()), Number(null) are converted to zero
    return !isNaN(Number(value));
  }
  return isNumber(value);
};

/*
  Validates whether or not the value passed falls between the min and max length
  string specified for a password.
  @param value String to verify its length
  @return true or false
*/
export const isValidPassword = (value) => {
  if (isString(value)) {
    const trimmed = value.trim();
    return trimmed.length >= getConstant('PASSWORD_MIN_LENGTH') &&
    trimmed.length <= getConstant('PASSWORD_MAX_LENGTH');
  }
  return false;
};

/*
  Validates whether or not the value passed is a non-empty String type.
  @param value String to verify its length
  @return true or false
*/
export const isValidText = (value) => {
  if (isString(value)) {
    return value.trim().length > 0;
  }
  return false;
};

export const isValidCheckbox = (el) => {
  if (isObject(el)) {
    return el.is(':checked');
  }
  return false;
};

export const isValidMultiCheckbox = (el) => {
  if (isObject(el) && isObject(el.closest('fieldset'))) {
    return el.closest('fieldset').find('input:checked').length > 0;
  }
  return false;
};
