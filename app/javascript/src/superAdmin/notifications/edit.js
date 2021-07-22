import { Tinymce } from '../../utils/tinymce.js.erb';

// add the info on selecting the check from notification suitable
import { paginableSelector } from '../../utils/paginable';
import * as notifier from '../../utils/notificationHelper';

$(() => {
  Tinymce.init({ selector: '.notification-text', forced_root_block: '' });

  $(paginableSelector).on('click, change', '.enable_notification input[type="checkbox"]', (e) => {
    const form = $(e.target).closest('form');
    form.submit();
  });

  $(paginableSelector).on('ajax:success', '.enable_notification', (e) => {
    const data = e.detail[0];
    if (data.code === 1 && data.msg && data.msg !== '') {
      notifier.renderNotice(data.msg);
    } else {
      notifier.renderAlert(data.msg);
    }
  });
});
