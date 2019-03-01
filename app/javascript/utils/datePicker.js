import 'jquery-ui/ui/widgets/datepicker';

/*
 * Date picker polyfill:
 * Wire up the JQuery UI DatePicker if the browser does not support the HTML5 date
 */
export default () => {
  console.log('Init DatePicker');
  if ($('[type="date"]').prop('type') !== 'date') {
    console.log(`BOOM - WIRING #${$('[type="date"]').attr('id')}`);

    $('[type="date"]').datepicker({
      dateFormat: 'yy-mm-dd',
      constrainInput: true,
      navigationAsDateFormat: true,
    });
  }
};
