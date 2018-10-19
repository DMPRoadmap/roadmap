import {
  isValidEmail,
  isValidNumber,
  isValidPassword,
  isValidText,
} from '../utils/isValidInputType';

describe('isValidEmail test suite', () => {
  it('expect true for someone@somewhere.com', () => expect(isValidEmail('someone@somewhere.com')).toBe(true));
  it('expect true for s@somewhere.ac.uk', () => expect(isValidEmail('s@somewhere.ac.uk')).toBe(true));
  it('expect true for someone@somewhere.gov.ac.uk', () => expect(isValidEmail('someone@somewhere.gov.ac.uk')).toBe(true));
  it('expect false for @somewhere.com', () => expect(isValidEmail('@somewhere.com')).toBe(false));
  it('expect false for s@somewhere.ac.u', () => expect(isValidEmail('s@somewhere.ac.u')).toBe(false));
  it('expect false for someone@somewhere.gov.ac.u', () => expect(isValidEmail('someone@somewhere.gov.ac.u')).toBe(false));
});

describe('isValidNumber test suite', () => {
  it('expect true for 1', () => expect(isValidNumber(1)).toBe(true));
  it('expect true for \'1\'', () => expect(isValidNumber('1')).toBe(true));
  it('expect true for Infinity', () => expect(isValidNumber(Infinity)).toBe(true));
  it('expect false for Array', () => expect(isValidNumber([])).toBe(false));
  it('expect false for Boolean', () => expect(isValidNumber(true)).toBe(false));
  it('expect false for Date', () => expect(isValidNumber(new Date())).toBe(false));
  it('expect false for Function', () => expect(isValidNumber(() => {})).toBe(false));
  it('expect false for Object', () => expect(isValidNumber({})).toBe(false));
  it('expect false for RegExp', () => expect(isValidNumber(/foo/)).toBe(false));
  it('expect false for String', () => expect(isValidNumber('Hello World!')).toBe(false));
  it('expect false for Null', () => expect(isValidNumber(null)).toBe(false));
  it('expect false for Array', () => expect(isValidNumber(undefined)).toBe(false));
  it('expect false for zero args', () => expect(isValidNumber()).toBe(false));
});

describe('isValidPassword test suite', () => {
  it('expect true for hjkl7890', () => expect(isValidPassword('hjkl7890')).toBe(true));
  it('expect false for hjkl', () => expect(isValidPassword('hjkl')).toBe(false));
  it('expect false for \' abcd   \'', () => expect(isValidPassword(' abcd   ')).toBe(false));
  it('expect false for non-string', () => expect(isValidPassword(null)).toBe(false));
});

describe('isValid test suite', () => {
  it('expect true for h', () => expect(isValidText('h')).toBe(true));
  it('expect false for \' \'', () => expect(isValidText(' ')).toBe(false));
});
