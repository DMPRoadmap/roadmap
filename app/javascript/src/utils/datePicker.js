import 'jquery-ui/datepicker';

/*
 * Date picker polyfill:
 * Wire up the JQuery UI DatePicker if the browser does not support the HTML5 date
 */
export default () => {
  if ($('[type="date"]').prop('type') !== 'date') {
    $('[type="date"]').datepicker({
      dateFormat: 'yy-mm-dd',
      constrainInput: true,
      navigationAsDateFormat: true,
      goToCurrent: true,
    });
  }
};
