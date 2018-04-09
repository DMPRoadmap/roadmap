import { paginableSelector } from '../../utils/paginable';
import { isObject, isString } from '../../utils/isType';
import { renderNotice, renderAlert, hideNotifications } from '../../utils/notificationHelper';
import { scrollTo } from '../../utils/scrollTo';

$(() => {
  // Activate/Deactivate user account
  $(paginableSelector).on('click, change', '.activate-user input[type="checkbox"]', (e) => {
    const form = $(e.target).closest('form');
    hideNotifications();
    form.submit();
  });
  $(paginableSelector).on('ajax:success', '.activate-user', (e, data) => {
    if (data.code === 1 && data.msg && data.msg !== '') {
      renderNotice(data.msg);
    } else {
      renderAlert(data.msg);
    }
  });
  $(paginableSelector).on('ajax:error', '.activate-user', () => {
    renderAlert('Unexpected error');
  });

  let currentPrivileges = null;
  $(paginableSelector).on('click', 'a[href$="admin_grant_permissions"]', (e) => {
    e.preventDefault();
    const target = $(e.target);
    currentPrivileges = target.closest('td').siblings('td[data-descriptor="current_privileges"]');
    $.ajax({
      method: 'GET',
      url: target.attr('href'),
    }).done((data) => {
      $('#modal-permissions').html(data.user.html);
      if ($('.org_grant_privileges:checked').length === $('.org_grant_privileges').length) {
        $('#org_admin_privileges').prop('checked', true);
      }
      if ($('.super_grant_privileges:checked').length === $('.super_grant_privileges').length) {
        $('#super_admin_privileges').prop('checked', true);
      }
    }).fail((xhr) => {
      const error = xhr.responseJSON;
      if (isObject(error) && isString(error.msg)) {
        $('#modal-permissions').html(error.msg);
      } else {
        $('#modal-permissions').html('Unexpected error');
      }
    }).always(() => {
      // The modal is deferred until a successful response is got
      $('#modal-permissions').modal('show');
    });
  });
  // Event delegation handler after a successful response is obtained
  $(paginableSelector).on('ajax:success', '.admin_update_permissions', (e, data) => {
    if (isObject(data)) {
      if (isString(data.msg)) {
        renderNotice(data.msg);
        scrollTo('#notification-area');
      }
      if (isString(data.current_privileges) && currentPrivileges) {
        currentPrivileges.html(data.current_privileges);
      }
    }
    $('#modal-permissions').modal('hide');
  });
  // Event delegation handler after an error response is obtained
  $(paginableSelector).on('ajax:error', '.admin_update_permissions', (e, xhr) => {
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error.msg)) {
      renderAlert(error.msg);
      scrollTo('#notification-area');
    }
    $('#modal-permissions').modal('hide');
  });
});

$(() => {
  $(paginableSelector).on('click', '#org_admin_privileges', () => {
    if ($('#org_admin_privileges').prop('checked')) {
      $('.org_grant_privileges:checkbox').prop('checked', true);
    } else {
      $('.org_grant_privileges:checkbox').prop('checked', false);
    }
  });
  $(paginableSelector).on('change', '.org_grant_privileges', () => {
    if ($('.org_grant_privileges:checked').length === $('.org_grant_privileges').length) {
      $('#org_admin_privileges').prop('checked', true);
    } else {
      $('#org_admin_privileges').prop('checked', false);
    }
  });
});

$(() => {
  $(paginableSelector).on('click', '#super_admin_privileges', () => {
    if ($('#super_admin_privileges').prop('checked')) {
      $('.super_grant_privileges:checkbox').prop('checked', true);
    } else {
      $('.super_grant_privileges:checkbox').prop('checked', false);
    }
  });
  $(paginableSelector).on('change', '.super_grant_privileges', () => {
    if ($('.super_grant_privileges:checked').length === $('.super_grant_privileges').length) {
      $('#super_admin_privileges').prop('checked', true);
    } else {
      $('#super_admin_privileges').prop('checked', false);
    }
  });
});
