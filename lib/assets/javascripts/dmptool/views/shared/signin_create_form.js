import * as Cookies from 'js-cookie';
import ariatiseForm from '../../../utils/ariatiseForm';
import { isObject, isString } from '../../../utils/isType';
import { renderNotice, renderAlert } from '../../../utils/notificationHelper';

$(() => {
  ariatiseForm({ selector: '#signin_create_form' });

  const email = Cookies.get('dmproadmap_email');

  // If the user's email was stored in the browser's cookies the pre-populate the field
  if (email && email !== '') {
    $('#signin_create_form #remember_email').attr('checked', 'checked');
    $('#signin_create_form #user_email').val(email);
  }

  // When the user checks the 'remember email' box store the value in the browser storage
  $('#signin_create_form #remember_email').click((e) => {
    if ($(e.currentTarget).is(':checked')) {
      Cookies.set('dmproadmap_email', $('#signin_create_form #user_email').val(), { expires: 14 });
    } else {
      Cookies.remove('dmproadmap_email');
    }
  });

  // If the email is changed and the user has asked to remember it update the browser storage
  $('#signin_create_form #user_email').change((e) => {
    if ($('#signin_create_form #remember_email').is(':checked')) {
      Cookies.set('dmproadmap_email', $(e.currentTarget).val(), { expires: 14 });
    }
  });

  // handle toggling between shared signin/create account forms
  const toggleSignInCreateAccount = (signin = true) => {
    const signinTab = $('[data-target="#sign-in-form-tab"]');
    const createTab = $('[data-target="#create-account-form-tab"]');
    if (signin) {
      $('#signin_create_form').attr('action', signinTab.attr('data-action')).attr('method', signinTab.attr('data-method'));
      $('[data-target="#sign-in-form-tab"]').closest('li').addClass('active');
      $('[data-target="#create-account-form-tab"]').closest('li').removeClass('active');
      $('#signin_create_form .create-account-fields').hide();
      $('#signin_create_form .signin-fields').show();
      $('#signin_create_form input[type="submit"]').text('Sign in');
    } else {
      $('#signin_create_form').attr('action', createTab.attr('data-action')).attr('method', createTab.attr('data-method'));
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
    return false;
  });
  $('#access-control-tabs [data-target="#create-account-form-tab"]').click((e) => {
    e.preventDefault();
    toggleSignInCreateAccount(false);
    return false;
  });
  $('#show-create-account-via-shib-ds, [data-target="#sign-in-create-account"]').click(() => {
    toggleSignInCreateAccount(false);
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

