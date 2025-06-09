import { isString, isObject } from './isType';

/*
  Helpers that will display the specified message in in the notification
  area at the top of the page
*/

export function hideNotifications() {
  $('#notification-area')
    .addClass('d-none')
    .removeClass('notification-area--floating');
}

function renderMessage(options = {}) {
  const notificationArea = $('#notification-area');

  if (isString(options.message) && isObject(notificationArea)) {

    if (options.floating) {
      notificationArea.addClass('notification-area--floating');
    }
    
    // Remove class
    if (options.removeClass) {
      notificationArea.removeClass('alert-info');
      notificationArea.removeClass('alert-warning');
    }

    notificationArea.addClass(options.className);

    notificationArea.find('i, span').remove();
    notificationArea.append(`
      <i class="fas fa-${options.icon}" aria-hidden="true"></i>
      <span>${options.message}</span>
    `);

    notificationArea.removeClass('d-none');

    if (options.autoDismiss) {
      setTimeout(() => { hideNotifications(); }, 5000);
    }
  }
}

export function renderNotice(msg, options = {}) {
  renderMessage({
    message: msg,
    icon: 'circle-check',
    className: 'alert-info',
    removeClass: true,
    floating: options.floating === true,
    autoDismiss: options.autoDismiss === true,
  });
}

export function renderAlert(msg, options = {}) {
  renderMessage({
    message: msg,
    icon: 'circle-xmark',
    className: 'alert-warning',
    removeClass: true,
    floating: options.floating === true,
    autoDismiss: options.autoDismiss === true,
  });
}
