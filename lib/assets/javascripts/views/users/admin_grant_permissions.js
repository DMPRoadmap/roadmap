import { paginableSelector } from '../../utils/paginable';

$(() => {
  const success = (data) => {
    // Render the html in the modal-permissions modal
    $('#modal-permissions').html(data.user.html);
    if ($('.org_grant_privileges:checked').length === $('.org_grant_privileges').length) {
      $('#modal-permissions #org_admin_privileges').prop('checked', true);
    }
    if ($('.super_grant_privileges:checked').length === $('.super_grant_privileges').length) {
      $('#modal-permissions #super_admin_privileges').prop('checked', true);
    }
  };

  const error = () => {
    // There was an ajax error so just route the user to the sign-in modal
    // and let them sign in as a Non-Partner Institution
    $('a[data-target="#modal-permissions"]').tab('show');
  };

  $(paginableSelector).on('click', '.modal-window', (e) => {
    const target = $(e.target);
    $('#modal-permissions').html('');
    $.ajax({
      method: 'GET',
      url: target.attr('href'),
    }).done((data) => {
      success(data);
    }, error);
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
