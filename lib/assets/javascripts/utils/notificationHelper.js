import { isString, isObject } from './isType';
/*
  Helpers that will display the specified message in in the notification
  area at the top of the page
*/
export const renderNotice = (msg) => {
  const notificationArea = $('#notification-area');

  if (isString(msg) && isObject(notificationArea)) {
    notificationArea.removeClass('alert-warning').addClass('alert-info');
    notificationArea.find('i, span').remove();
    notificationArea.append(`
      <i class="fa fa-check-circle" aria-hidden="true"></i><span>${msg}</span>`);
    notificationArea.removeClass('hide');
  }
};

export const renderAlert = (msg) => {
  const notificationArea = $('#notification-area');

  if (isString(msg) && isObject(notificationArea)) {
    notificationArea.removeClass('alert-info').addClass('alert-warning');
    notificationArea.find('i, span').remove();
    notificationArea.append(`
      <i class="fa fa-times-circle" aria-hidden="true"></i><span>${msg}</span>`);
    notificationArea.removeClass('hide');
  }
};

export const hideNotifications = () => {
  $('#notification-area').addClass('hide');
};
