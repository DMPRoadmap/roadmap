import enGB from '../locale/en_GB/timeago';

/* global timeago */
const TimeagoFactory = (() => {
  timeago.register('en_GB', enGB);
  /*
    @param el - DOM element
    @returns
  */
  return {
    render: (el) => {
      timeago().render(el, 'en_GB');
    },
  };
})();

export default TimeagoFactory;
