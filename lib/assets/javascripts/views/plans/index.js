import * as notifier from '../../utils/notificationHelper';
import {
  PLAN_VISIBILITY_WHEN_TEST,
  PLAN_VISIBILITY_WHEN_NOT_TEST,
  PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP,
} from '../../constants';

$(() => {
  const checkboxHandler = (el) => {
    const form = $(el).closest('form');

    $.ajax({
      method: $(form).attr('method'),
      url: $(form).attr('action'),
      data: $(form).serializeArray(),
    }).done((data) => {
      if (data.code === 1 && data.msg && data.msg !== '') {
        notifier.renderNotice(data.msg);
      } else {
        notifier.renderAlert(data.msg);
      }

      if ($(el).is(':checked')) {
        $(form).parent().siblings('.plan-visibility').html(PLAN_VISIBILITY_WHEN_TEST)
          .attr('title', '');
      } else {
        $(form).parent().siblings('.plan-visibility').html(PLAN_VISIBILITY_WHEN_NOT_TEST)
          .attr('title', PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP);
      }
    }, () => {
      // TODO adequate error handling for network error 
    });
  };

  $("#my-plans input[type='checkbox']").on('click, change', (e) => {
    checkboxHandler(e.currentTarget);
  });
});
