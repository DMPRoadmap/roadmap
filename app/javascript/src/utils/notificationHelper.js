import { isString, isObject } from './isType';

/*
  Helpers that will display the specified message in in the notification
  area at the top of the page
*/

export function hideNotifications() {
  $('#notification-area')
    .addClass('hide')
    .removeClass('notification-area--floating');
}

function renderMessage(options = {}) {
  const notificationArea = $('#notification-area');

  if (isString(options.message) && isObject(notificationArea)) {
    const block = notificationArea.find(options.className);

    if (block.length > 0) {
      block.html(options.message);
      block.removeClass('hide');
    }

    // DMPTool customization to work with new layout

    // notificationArea
    //   .removeClass('c-notification-area__info', 'c-notification-area__warning')
    //   .addClass(options.className);
    //
    // if (options.floating) {
    //   notificationArea.addClass('notification-area--floating');
    // }

    // notificationArea.find('i, span').remove();
    // notificationArea.append(`
    //   <i class="fas fa-${options.icon}" aria-hidden="true"></i>
    //   <span>${options.message}</span>
    // `);

    // notificationArea.removeClass('hide');

    if (options.autoDismiss) {
      setTimeout(() => { hideNotifications(); }, 5000);
    }
  }
}

export function renderNotice(msg, options = {}) {
  renderMessage({
    message: msg,
    icon: 'check-circle',
    className: '.c-notification--info',
    floating: options.floating === true,
    autoDismiss: options.autoDismiss === true,
  });
}

export function renderAlert(msg, options = {}) {
  renderMessage({
    message: msg,
    icon: 'times-circle',
    className: '.c-notification--danger',
    floating: options.floating === true,
    autoDismiss: options.autoDismiss === true,
  });
}
