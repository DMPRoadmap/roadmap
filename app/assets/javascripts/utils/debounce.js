import { isFunction, isNumber } from './isType';

export default function debounce(func, wait) {
  if (isFunction(func)) {
    let timeoutID = null;
    const delay = isNumber(wait) ? wait : 1000;
    const closureDebounce = (...args) => {
      const delayed = () => {
        timeoutID = null;
        func.apply(this, args);
      };
      clearTimeout(timeoutID);
      timeoutID = setTimeout(delayed, delay);
    };
    closureDebounce.cancel = () => {
      if (timeoutID) {
        clearTimeout(timeoutID);
        return true;
      }
      return false;
    };
    return closureDebounce;
  }
  return null;
}
