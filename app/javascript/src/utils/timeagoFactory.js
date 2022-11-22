import getConstant from './constants';

import en_US from '../locale/en_US/timeago';
import pt_BR from '../locale/pt_BR/timeago';

const TimeagoFactory = (() => {
  // Register all of the locales with Timeago
  timeago.register('en_US', en_US);
  timeago.register('pt_BR', pt_BR);
  
  const defaultLocale = 'en_US'

  const convertTime = (currentLocale, el) => {
    return timeago.format($(el).attr('datetime'), `${currentLocale}`);
  };

  return {
    render: (el) => {
      const currentLocale = getConstant('CURRENT_LOCALE') || defaultLocale;

      if (el.length > 1) {
        // If we were passed an array of JQuery elements then handle each one
        $(el).each((idx, e) => {
          $(e).text(convertTime(currentLocale, e));
        });
      } else {
        $(el).text(convertTime(currentLocale, el));
      }
    },
  };
})();

export default TimeagoFactory;
