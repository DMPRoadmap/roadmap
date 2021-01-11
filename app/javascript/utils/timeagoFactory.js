import frCA from '../locale/fr-CA/timeago';
import enCA from '../locale/en-CA/timeago';
import enGB from '../locale/en-GB/timeago';


/* global timeago */

const TimeagoFactory = (() => {
  timeago.register('fr-CA', frCA);
  timeago.register('en-CA', enCA);
  timeago.register('en-GB', enGB);
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
      // global i18nLocale defined in application.html.erb 
      timeago().render(el, i18nLocale);
    },
  };
})();

export default TimeagoFactory;
