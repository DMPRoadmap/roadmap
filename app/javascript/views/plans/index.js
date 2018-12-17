import * as notifier from '../../utils/notificationHelper';
import getConstant from '../../constants';
import { paginableSelector } from '../../utils/paginable';

$(() => {
  $(paginableSelector).on('click, change', '.set_test_plan input[type="checkbox"]', (e) => {
    const form = $(e.target).closest('form');
    form.submit();
  });
  $(paginableSelector).on('ajax:success', '.set_test_plan', (e, data) => {
    const form = $(e.target);
    if (data.code === 1 && data.msg && data.msg !== '') {
      notifier.renderNotice(data.msg);
    } else {
      notifier.renderAlert(data.msg);
    }

    if (form.find('input[type="checkbox"]').is(':checked')) {
      form.parent().siblings('.plan-visibility').html(getConstant('PLAN_VISIBILITY_WHEN_TEST'))
        .attr('title', '');
    } else {
      form.parent().siblings('.plan-visibility').html(getConstant('PLAN_VISIBILITY_WHEN_NOT_TEST'))
        .attr('title', getConstant('PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP'));
    }
  });
  $(paginableSelector).on('ajax:error', '.set_test_plan', () => {
    // TODO adequate error handling for network error
  });
});
