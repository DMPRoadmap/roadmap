import * as notifications from '../../../utils/notificationHelper';
import { isObject } from '../../../utils/isType';
import { isValidNumber } from '../../../utils/isValidInputType';

$(() => {
  // enable the Actions dropdown for each template belonging to the current user's org
  const enableActions = (ctx) => {
    if (isValidNumber($(ctx).find('#user_org_id').val())) {
      $('tr .dropdown .super-admin-template-org').map((idx, el) => {
        if (isValidNumber($(el).text()) && $(ctx).find('#user_org_id').val().toString() === $(el).text()) {
          $(el).parent().removeClass('hide');
        } else {
          $(el).parent().addClass('hide');
        }
        return true;
      });
    }
  };
  const swapOrg = (ctx) => {
    if (isValidNumber($(ctx).find('#user_org_id').val())) {
      notifications.hideNotifications();
      $.ajax({
        method: $(ctx).attr('method'),
        url: $(ctx).attr('action'),
        data: $(ctx).serializeArray(),
      }).done((data) => {
        if (data.msg.length > 0) {
          notifications.renderNotice(data.msg);
        } else if (data.err.length > 0) {
          notifications.renderAlert(data.err);
        }
        enableActions(ctx);
      }).fail((err) => {
        notifications.renderAlert(err);
      });
    }
  };

  if (isObject($('form#super-admin-switch-org'))) {
    $('form#super-admin-switch-org').on('submit', (e) => {
      e.preventDefault();
      swapOrg(e.target);
    });
    enableActions($('form#super-admin-switch-org'));
  }

  // Update the contents of the table when user clicks on a scope link
  $('.template-scope').on('ajax:success', 'a[data-remote="true"]', (e, data) => {
    $(e.target).closest('.paginable').html(data);
  });
});
