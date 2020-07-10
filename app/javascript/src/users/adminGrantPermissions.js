import { isObject, isString } from '../utils/isType';
import { renderNotice, renderAlert } from '../utils/notificationHelper';
import { scrollTo } from '../utils/scrollTo';

$(() => {
  // Activate/Deactivate user account
  $('body').on('ajax:success', '.activate-user', (e) => {
    const data = e.detail[0];
    if (data.code === 1 && data.msg && data.msg !== '') {
      renderNotice(data.msg);
    } else {
      renderAlert(data.msg);
    }
  });
  $('body').on('ajax:error', '.activate-user', () => {
    renderAlert('Unexpected error');
  });

  let currentPrivileges = null;
  $('body').on('click', 'a[href$="admin_grant_permissions"]', (e) => {
    e.preventDefault();
    const target = $(e.target);
    currentPrivileges = target.closest('td').find('.privilege-description');
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
  $('body').on('ajax:success', '.admin_update_permissions', (e) => {
    const data = e.detail[0];
    if (isObject(data)) {
      if (isString(data.msg)) {
        renderNotice(data.msg);
        scrollTo('#notification-area');
      }
      if (isString(data.current_privileges) && currentPrivileges.length > 0) {
        currentPrivileges.html(data.current_privileges);
      }
    }
    $('#modal-permissions').modal('hide');
  });
  // Event delegation handler after an error response is obtained
  $('body').on('ajax:error', '.admin_update_permissions', (e) => {
    const xhr = e.detail[2];
    if (isObject(xhr)) {
      const error = xhr.responseJSON;
      if (isObject(xhr) && isString(error.msg)) {
        renderAlert(error.msg);
        scrollTo('#notification-area');
      }
    }
    $('#modal-permissions').modal('hide');
  });
});

$(() => {
  $('body').on('click', '#org_admin_privileges', () => {
    if ($('#org_admin_privileges').prop('checked')) {
      $('.org_grant_privileges:checkbox').prop('checked', true);
    } else {
      $('.org_grant_privileges:checkbox').prop('checked', false);
    }
  });
  $('body').on('change', '.org_grant_privileges', () => {
    if ($('.org_grant_privileges:checked').length === $('.org_grant_privileges').length) {
      $('#org_admin_privileges').prop('checked', true);
    } else {
      $('#org_admin_privileges').prop('checked', false);
    }
  });
});

$(() => {
  $('body').on('click', '#super_admin_privileges', () => {
    if ($('#super_admin_privileges').prop('checked')) {
      $('.super_grant_privileges:checkbox').prop('checked', true);
    } else {
      $('.super_grant_privileges:checkbox').prop('checked', false);
    }
  });
  $('body').on('change', '.super_grant_privileges', () => {
    if ($('.super_grant_privileges:checked').length === $('.super_grant_privileges').length) {
      $('#super_admin_privileges').prop('checked', true);
    } else {
      $('#super_admin_privileges').prop('checked', false);
    }
  });
});
