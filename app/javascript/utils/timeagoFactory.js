import frCA from '../locale/fr_CA/timeago';
import enCA from '../locale/en_CA/timeago';
import enGB from '../locale/en_GB/timeago';


/* global timeago */

const TimeagoFactory = (() => {
  timeago.register('fr_CA', frCA);
  timeago.register('en_CA', enCA);
  timeago.register('en_GB', enGB);
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
      /* global i18nLocale */
      timeago().render(el, i18nLocale);
    },
  };
})();

export default TimeagoFactory;
