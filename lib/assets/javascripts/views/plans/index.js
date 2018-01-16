import * as notifier from '../../utils/notificationHelper';

import {
  PLAN_VISIBILITY_WHEN_TEST,
  PLAN_VISIBILITY_WHEN_NOT_TEST,
  PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP,
} from '../../constants';

$(() => {
  $('.set_test_plan input[type="checkbox"]').on('click, change', (e) => {
    const form = $(e.target).closest('form');
    form.submit();
  });
  $('.set_test_plan').on('ajax:success', (e, data) => {
    const form = $(e.target);
    if (data.code === 1 && data.msg && data.msg !== '') {
      notifier.renderNotice(data.msg);
    } else {
      notifier.renderAlert(data.msg);
    }

    if (form.find('input[type="checkbox"]').is(':checked')) {
      form.parent().siblings('.plan-visibility').html(PLAN_VISIBILITY_WHEN_TEST)
        .attr('title', '');
    } else {
      form.parent().siblings('.plan-visibility').html(PLAN_VISIBILITY_WHEN_NOT_TEST)
        .attr('title', PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP);
    }
  });
  $('.set_test_plan').on('ajax:error', () => {
    // TODO adequate error handling for network error
  });
});
