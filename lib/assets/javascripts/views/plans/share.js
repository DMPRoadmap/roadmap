import * as notifier from '../../utils/notificationHelper';
import ariatiseForm from '../../utils/ariatiseForm';
import { isObject, isString } from '../../utils/isType';

$(() => {
  // Invite Collaborators form on the Share page
  ariatiseForm({ selector: '#new_role' });

  $('#set_visibility [name="plan[visibility]"]').click((e) => {
    $(e.target).closest('form').submit();
  });
  $('#set_visibility').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      notifier.renderNotice(data.msg);
    }
  });
  $('#set_visibility').on('ajax:error', (e, xhr) => {
    if (isObject(xhr.responseJSON)) {
      notifier.renderAlert(xhr.responseJSON.msg);
    } else {
      notifier.renderAlert(`${xhr.statusCode} - ${xhr.statusText}`);
    }
  });
});
