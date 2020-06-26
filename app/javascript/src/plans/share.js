import * as notifier from '../utils/notificationHelper';
import { isObject, isString } from '../utils/isType';

$(() => {
  $('#set_visibility').on('ajax:success', (e) => {
    const data = e.detail[0];
    if (isObject(data) && isString(data.msg)) {
      notifier.renderNotice(data.msg);
    }
  });
  $('#set_visibility').on('ajax:error', (e) => {
    const xhr = e.detail[2];
    if (isObject(xhr.responseJSON)) {
      notifier.renderAlert(xhr.responseJSON.msg);
    } else {
      notifier.renderAlert(`${xhr.statusCode} - ${xhr.statusText}`);
    }
  });

  $('.toggle-existing-user-access')
    .on('ajax:success', (e) => {
      const data = e.detail[0];
      notifier.renderNotice(`foo: ${data.msg}`);
    })
    .on('ajax:error', (e) => {
      const xhr = e.detail[2];
      if (isObject(xhr.responseJSON)) {
        notifier.renderAlert(xhr.responseJSON.msg);
      } else {
        notifier.renderAlert(`${xhr.statusCode} - ${xhr.statusText}`);
      }
    });
});
