import * as notifier from '../../../utils/notificationHelper';
import toggleSpinner from '../../../utils/spinner';

$(() => {
  $('#maincontent').on('ajax:success', 'input.set_featured_plan', (e) => {
    const data = e.detail[0];
    if (data.code === 1 && data.msg && data.msg !== '') {
      notifier.renderNotice(data.msg);
    } else {
      notifier.renderAlert(data.msg);
    }
    toggleSpinner(false);
  });

  $('#maincontent').on('ajax:error', 'input.set_test_plan', (e) => {
    const xhr = e.detail(2);
    notifier.renderAlert(xhr.responseText);
  });
});
