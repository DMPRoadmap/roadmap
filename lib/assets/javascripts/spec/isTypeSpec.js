import {
  isArray,
  isBoolean,
  isDate,
  isFunction,
  isNumber,
  isNull,
  isObject,
  isRegExp,
  isString,
  isUndefined } from '../utils/isType';

describe('isArray test suite', () => {
  it('expect true for []', () => expect(isArray([])).toBe(true));
  it('expect false for Boolean', () => expect(isArray(true)).toBe(false));
  it('expect false for Date', () => expect(isArray(new Date())).toBe(false));
  it('expect false for Function', () => expect(isArray(() => {})).toBe(false));
  it('expect false for Number', () => expect(isArray(1)).toBe(false));
  it('expect false for Null', () => expect(isArray(null)).toBe(false));
  it('expect false for Object', () => expect(isArray({})).toBe(false));
  it('expect false for RegExp', () => expect(isArray(/foo/)).toBe(false));
  it('expect false for String', () => expect(isArray('Hello World!')).toBe(false));
  it('expect false for Undefined', () => expect(isArray(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isArray()).toBe(false));
});

describe('isBoolean test suite', () => {
  it('expect true for true', () => expect(isBoolean(true)).toBe(true));
  it('expect true for false', () => expect(isBoolean(true)).toBe(true));
  it('expect false for []', () => expect(isBoolean([])).toBe(false));
  it('expect false for Date', () => expect(isBoolean(new Date())).toBe(false));
  it('expect false for Function', () => expect(isBoolean(() => {})).toBe(false));
  it('expect false for Number', () => expect(isBoolean(1)).toBe(false));
  it('expect false for Null', () => expect(isBoolean(null)).toBe(false));
  it('expect false for Object', () => expect(isBoolean({})).toBe(false));
  it('expect false for RegExp', () => expect(isBoolean(/foo/)).toBe(false));
  it('expect false for String', () => expect(isBoolean('Hello World!')).toBe(false));
  it('expect false for Undefined', () => expect(isBoolean(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isBoolean()).toBe(false));
});

describe('isDate test suite', () => {
  it('expect true for Date', () => expect(isDate(new Date())).toBe(true));
  it('expect fase for []', () => expect(isDate([])).toBe(false));
  it('expect fase for Boolean', () => expect(isDate(true)).toBe(false));
  it('expect fase for Function', () => expect(isDate(() => {})).toBe(false));
  it('expect fase for Number', () => expect(isDate(1)).toBe(false));
  it('expect fase for Null', () => expect(isDate(null)).toBe(false));
  it('expect fase for Object', () => expect(isDate({})).toBe(false));
  it('expect fase for RegExp', () => expect(isDate(/foo/)).toBe(false));
  it('expect fase for String', () => expect(isDate('Hello World!')).toBe(false));
  it('expect fase for zero args', () => expect(isDate(undefined)).toBe(false));
});

describe('isFunction test suite', () => {
  it('expect true for Function', () => expect(isFunction(() => {})).toBe(true));
  it('expect false for []', () => expect(isFunction([])).toBe(false));
  it('expect false for Boolean', () => expect(isFunction(true)).toBe(false));
  it('expect false for Date', () => expect(isFunction(new Date())).toBe(false));
  it('expect false for Number', () => expect(isFunction(1)).toBe(false));
  it('expect false for Null', () => expect(isFunction(null)).toBe(false));
  it('expect false for Object', () => expect(isFunction({})).toBe(false));
  it('expect false for RegExp', () => expect(isFunction(/foo/)).toBe(false));
  it('expect false for String', () => expect(isFunction('Hello World!')).toBe(false));
  it('expect false for undefined', () => expect(isFunction(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isFunction()).toBe(false));
});

describe('isNumber test suite', () => {
  it('expect true for 1', () => expect(isNumber(1)).toBe(true));
  it('expect true for NaN', () => expect(isNumber(NaN)).toBe(true));
  it('expect true for Infinity', () => expect(isNumber(Infinity)).toBe(true));
  it('expect false for []', () => expect(isNumber([])).toBe(false));
  it('expect false for Boolean', () => expect(isNumber(true)).toBe(false));
  it('expect false for Date', () => expect(isNumber(new Date())).toBe(false));
  it('expect false for Null', () => expect(isNumber(null)).toBe(false));
  it('expect false for Object', () => expect(isNumber({})).toBe(false));
  it('expect false for RegExp', () => expect(isNumber(/foo/)).toBe(false));
  it('expect false for String', () => expect(isNumber('Hello World!')).toBe(false));
  it('expect false for undefined', () => expect(isNumber(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isNumber()).toBe(false));
});

describe('isNull test suite', () => {
  it('expect true for Null', () => expect(isNull(null)).toBe(true));
  it('expect false for []', () => expect(isNull([])).toBe(false));
  it('expect false for Boolean', () => expect(isNull(true)).toBe(false));
  it('expect false for Date', () => expect(isNull(new Date())).toBe(false));
  it('expect false for Number', () => expect(isNull(1)).toBe(false));
  it('expect false for Object', () => expect(isNull(Object.create(null))).toBe(false));
  it('expect false for RegExp', () => expect(isNull(/foo/)).toBe(false));
  it('expect false for String', () => expect(isNull('null')).toBe(false));
  it('expect false for undefined', () => expect(isNull(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isNull()).toBe(false));
});

describe('isObject test suite', () => {
  it('expect true for {}', () => expect(isObject({})).toBe(true));
  it('expect true for []', () => expect(isObject([])).toBe(true));
  it('expect true for Date', () => expect(isObject(new Date())).toBe(true));
  it('expect true for RegExp', () => expect(isObject(/foo/)).toBe(true));
  it('expect false for Number', () => expect(isObject(1)).toBe(false));
  it('expect false for Null', () => expect(isObject(null)).toBe(false));
  it('expect false for String', () => expect(isObject('Hello World!')).toBe(false));
  it('expect false for undefined', () => expect(isObject(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isObject()).toBe(false));
});

describe('isRegExp test suite', () => {
  it('expect true for RegExp', () => expect(isRegExp(/foo/)).toBe(true));
  it('expect true for RegExp', () => expect(isRegExp(new RegExp('foo'))).toBe(true));
  it('expect false for []', () => expect(isRegExp([])).toBe(false));
  it('expect false for Boolean', () => expect(isRegExp(true)).toBe(false));
  it('expect false for Date', () => expect(isRegExp(new Date())).toBe(false));
  it('expect false for Number', () => expect(isRegExp(1)).toBe(false));
  it('expect false for Null', () => expect(isRegExp(null)).toBe(false));
  it('expect false for String', () => expect(isRegExp('Hello World!')).toBe(false));
  it('expect false for undefined', () => expect(isRegExp(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isRegExp()).toBe(false));
});

describe('isString test suite', () => {
  it('expect true for String', () => expect(isString('Hello World!')).toBe(true));
  it('expect false for []', () => expect(isString([])).toBe(false));
  it('expect false for Boolean', () => expect(isString(true)).toBe(false));
  it('expect false for Date', () => expect(isString(new Date())).toBe(false));
  it('expect false for Function', () => expect(isString(() => {})).toBe(false));
  it('expect false for Number', () => expect(isString(1)).toBe(false));
  it('expect false for Null', () => expect(isString(null)).toBe(false));
  it('expect false for RegExp', () => expect(isString(/foo/)).toBe(false));
  it('expect false for Undefined', () => expect(isString(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isString()).toBe(false));
});

describe('isUndefined test suite', () => {
  it('expect true for Undefined', () => expect(isUndefined(undefined)).toBe(true));
  it('expect false for zero args', () => expect(isUndefined()).toBe(true));
  it('expect false for []', () => expect(isUndefined([])).toBe(false));
  it('expect false for Boolean', () => expect(isUndefined(true)).toBe(false));
  it('expect false for Date', () => expect(isUndefined(new Date())).toBe(false));
  it('expect false for Function', () => expect(isUndefined(() => {})).toBe(false));
  it('expect false for Number', () => expect(isUndefined(1)).toBe(false));
  it('expect false for Null', () => expect(isUndefined(null)).toBe(false));
  it('expect false for RegExp', () => expect(isUndefined(/foo/)).toBe(false));
  it('expect false for String', () => expect(isUndefined('Hello World!')).toBe(false));
});
