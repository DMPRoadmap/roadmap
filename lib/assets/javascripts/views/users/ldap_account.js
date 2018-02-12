import { isObject, isString } from '../../utils/isType';
import { renderNotice, renderAlert } from '../../utils/notificationHelper';

$(() => {
  $('form#forgot_email_form').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      renderNotice(data.msg);
      if (data.email === '' || data.email === null) {
        //
      } else {
        $('#sign-in-create-account').modal('show');
        $('input[id=user_email]').val(data.email);
      }
    }
  });
  $('form#forgot_email_form').on('ajax:error', (e, xhr) => {
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
    }
  });
});

