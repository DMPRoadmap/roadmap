const toString = Object.prototype.toString;
/*
  Checks whether or the value passed is type Array.
  @param value to check
  @return true or false
*/
export const isArray = Array.isArray;
/*
  Checks whether or the value passed is type boolean.
  Note the use of new is discouraged, e.g. new Boolean(true) and might return false in some cases
  @param value to check
  @return true or false
*/
export const isBoolean = value => typeof value === 'boolean';
/*
  Checks whether or the value passed is type Date.
  @param value to check
  @return true or false
*/
export const isDate = value => toString.call(value) === '[object Date]';
/*
  Checks whether or the value passed is type function.
  Note the use of new is discouraged, e.g. new Function(...) and might return false in some cases
  @param value to check
  @return true or false
*/
export const isFunction = value => typeof value === 'function';
/*
  Checks whether or the value passed is type number.
  Note the use of new is discouraged, e.g. new Number(1) and might return false in some cases.
  This method will return true for NaN and Infinity too.
  @param value to check
  @return true or false
*/
export const isNumber = value => typeof value === 'number';
/*
  Checks whether or the value passed is type null.
  @param value to check
  @return true or false
*/
export const isNull = value => value === null;
/*
  Checks whether or the value passed is type object.
  This will return true for any kind of object (Array, Date, RegExp ...) so consider
  using more accurate method defined here.
  @param value to check
  @return true or false
*/
export const isObject = value => value !== null && typeof value === 'object';
/*
  Checks whether or the value passed is type RegExp
  @param value to check
  @return true or false
*/
export const isRegExp = value => toString.call(value) === '[object RegExp]';
/*
  Checks whether or the value passed is type string.
  Note the use of new is discouraged, e.g. new String('aaa') and might return false in some cases
  @param value to check
  @return true or false
*/
export const isString = value => typeof value === 'string';
/*
  Checks whether or the value passed is type undefined.
  @param value to check
  @return true or false
*/
export const isUndefined = value => value === undefined;
