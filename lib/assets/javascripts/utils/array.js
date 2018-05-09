import { isFunction } from './isType';

if (!Array.prototype.find) {
  Array.prototype.find = function (predicate) { // eslint-disable-line no-extend-native, func-names
    if (!isFunction(predicate)) {
      throw new TypeError('predicate must be a function');
    }
    const array = Object(this);
    const length = array.length;
    let i = 0;
    while (i < length) {
      if (predicate.call(this, array[i], i, array)) {
        return array[i];
      }
      i += 1;
    }
    return undefined;
  };
}

