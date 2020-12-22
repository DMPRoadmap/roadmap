import fr_CA from '../locale/fr_CA/timeago';
import en_CA from '../locale/en_CA/timeago';
import en_GB from '../locale/en_GB/timeago';

/* global timeago */

const TimeagoFactory = (() => {

  timeago.register('fr_CA', fr_CA);
  timeago.register('en_CA', en_CA);
  timeago.register('en_GB', en_GB);
  /*
    @param el - DOM element
    @returns
  */

  return {
    render: (el) => {
      // The global variable i18nLocale is being used to fetch rails locale.
      // This variable is defined on application.html.erb
      // We are using a global variable since fetching from $('body').dataset
      // was not working.
      timeago().render(el, i18nLocale);
    },
  };
})();

export default TimeagoFactory;
