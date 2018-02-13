import { isObject, isString } from '../../utils/isType';
import { renderNotice, renderAlert } from '../../utils/notificationHelper';

$(() => {
  const toggleSignInCreateAccount = (signin = true) => {
    if (signin) {
      $('[data-target="#sign-in-form-tab"]').closest('li').addClass('active');
      $('[data-target="#create-account-form-tab"]').closest('li').removeClass('active');
      $('#signin_create_form .create-account-fields').hide();
      $('#signin_create_form .signin-fields').show();
      $('#signin_create_form input[type="submit"]').text('Sign in');
    } else {
      $('[data-target="#sign-in-form-tab"]').closest('li').removeClass('active');
      $('[data-target="#create-account-form-tab"]').closest('li').addClass('active');
      $('#signin_create_form .create-account-fields').show();
      $('#signin_create_form .signin-fields').hide();
      $('#signin_create_form input[type="submit"]').text('Create account');
    }
  };

  $('#access-control-tabs [data-target="#sign-in-form-tab"]').click((e) => {
    e.preventDefault();
    toggleSignInCreateAccount(true);
  });
  $('#access-control-tabs [data-target="#create-account-form-tab"]').click((e) => {
    e.preventDefault();
    toggleSignInCreateAccount(false);
  });
  $('#show-create-account-via-shib-ds, #show-create-account-form').click(() => {
    toggleSignInCreateAccount(false);
  })
  $('#show-sign-in-form, #sign-in-create-account').click(() => {
    toggleSignInCreateAccount(true);
  });
  toggleSignInCreateAccount();

  // Handling ldap username lookup here to take advantage of shared signin-create logic
  $('form#forgot_email_form').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      renderNotice(data.msg);
      if (data.email === '' || data.email === null) {
        //
      } else {
        toggleSignInCreateAccount(true);
        $('#sign-in-create-account').modal('show');
        $('input[id=user_email]').val(data.email);
      }
    }
  });
  $('form#forgot_email_form').on('ajax:error', (e, xhr) => {
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
    }
  });
});
