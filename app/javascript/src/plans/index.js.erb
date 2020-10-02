import * as notifier from '../utils/notificationHelper';
import getConstant from '../utils/constants';
import { paginableSelector } from '../utils/paginable';

$(() => {
  $(paginableSelector).on('ajax:success', 'input.set_test_plan', (e) => {
    const checkbox = $(e.target);
    const data = e.detail[0]; 
    if (data.code === 1 && data.msg && data.msg !== '') {
      notifier.renderNotice(data.msg);
    } else {
      notifier.renderAlert(data.msg);
    }

    if (checkbox.is(':checked')) {
      checkbox.parent().siblings('.plan-visibility').html(getConstant('PLAN_VISIBILITY_WHEN_TEST'))
        .attr('title', '');
    } else {
      checkbox.parent().siblings('.plan-visibility').html(getConstant('PLAN_VISIBILITY_WHEN_NOT_TEST'))
        .attr('title', getConstant('PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP'));
    }
  });
  $(paginableSelector).on('ajax:error', 'input.set_test_plan', (e) => {
    const xhr = e.detail(2);
    notifier.renderAlert(xhr.responseText);
  });

  $('#create-modal').modal('show');
});
