import getConstant from './constants';
import { format, register } from 'timeago.js';

const TimeagoFactory = (() => {
  const defaultLocale = 'en'

  const convertTime = (currentLocale, el) => {
    return format($(el).attr('datetime'), `${currentLocale}`);
  };

  return {
    render: (el) => {
      if (el.length > 1) {
        // If we were passed an array of JQuery elements then handle each one
        $(el).each((idx, e) => {
          $(e).text(convertTime(defaultLocale, e));
        });
      } else {
        $(el).text(convertTime(defaultLocale, el));
      }
    },
  };
})();

export default TimeagoFactory;
