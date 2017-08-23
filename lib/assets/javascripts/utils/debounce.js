import { isFunction, isNumber } from './isType';

export default function debounce(func, wait) {
  if (isFunction(func) && (wait || isNumber(wait))) {
    let timeoutID = null;
    const closureDebounce = (...args) => {
      const delayed = () => {
        timeoutID = null;
        func.apply(this, args);
      };
      clearTimeout(timeoutID);
      timeoutID = setTimeout(delayed, wait || 1000);
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
