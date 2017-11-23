import { renderNotice, renderAlert } from '../../utils/notificationHelper';
import { isString, isObject } from '../../utils/isType';

$(() => {
  $('form.edit_role select').on('change', (e) => {
    $(e.target).closest('form').submit();
  });
  $('form.edit_role').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      renderNotice(data.msg);
    }
  });
  $('form.edit_role').on('ajax:error', (e, xhr) => {
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
    }
  });
});
