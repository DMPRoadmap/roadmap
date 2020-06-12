// TODO: We should switch this over to an erb.js and then pull in the appropriate
//       file for the user's selected locale
import enGB from '../locale/en_GB/timeago';

const TimeagoFactory = (() => {
  timeago.register('en_GB', enGB);
  /*
    @param el - DOM element
    @returns
  */
  return {
    render: (el) => {
      // timeago().render(el, 'en_GB');
      timeago.format($(el).text(), 'en_GB');
    },
  };
})();

export default TimeagoFactory;
