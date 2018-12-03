/* eslint-env browser */ // This allows us to reference 'window' below
import * as Cookies from 'js-cookie';
import initAutoComplete from '../../../utils/autoComplete';
import { isObject, isString } from '../../../utils/isType';
import { renderAlert, renderNotice } from '../../../utils/notificationHelper';
import getConstant from '../../../constants';

$(() => {
  initAutoComplete();
  const email = Cookies.get('dmproadmap_email');

  // Signin remember me
  // -----------------------------------------------------
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

  // Signin / Create Account form toggle
  // -----------------------------------------------------
  // handle toggling between shared signin/create account forms
  const toggleSignInCreateAccount = (signin = true) => {
    const signinTab = $('a[href="#sign-in-panel"]').closest('li');
    const createTab = $('a[href="#create-account-panel"]').closest('li');
    const signinPanel = $('#sign-in-panel');
    const createAccountPanel = $('#create-account-panel');

    if (signin) {
      signinTab.addClass('active');
      signinPanel.addClass('active');

      createTab.removeClass('active');
      createAccountPanel.removeClass('active');
    } else {
      signinTab.removeClass('active');
      signinPanel.removeClass('active');

      createTab.addClass('active');
      createAccountPanel.addClass('active');
    }
  };

  const clearLogo = () => {
    $('#org-sign-in-logo').html('');
    $('#user_org_id').val('');
  };

  $('#show-create-account-via-shib-ds, #show-create-account-form').click(() => {
    clearLogo();
    toggleSignInCreateAccount(false);
  });
  $('#show-sign-in-form').click(() => {
    clearLogo();
    toggleSignInCreateAccount(true);
  });

  // Old LDAP username lookup
  // -----------------------------------------------------
  // Handling ldap username lookup here to take advantage of shared signin-create logic
  $('form#forgot_email_form').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      if (data.code === 0) {
        renderAlert(data.msg);
      } else {
        renderNotice(data.msg);
      }
      if (data.email === '' || data.email === null) {
        //
      } else {
        toggleSignInCreateAccount(true);
        $('#sign-in-create-account').modal('show');
        $('#signin_user_email').val(data.email);
      }
    }
  });
  $('form#forgot_email_form').on('ajax:error', (e, xhr) => {
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
    }
  });

  // Shibboleth DS
  // -----------------------------------------------------
  const logoSuccess = (data) => {
    // Render the html in the org-sign-in modal
    if (isObject(data) && isObject(data.org) && isString(data.org.html)) {
      $('#org-sign-in-logo').html(data.org.html);
      $('#user_org_id').val(data.org.id);
      toggleSignInCreateAccount(true);
      $('#sign-in-create-account').modal('show');
    }
  };
  const logoError = () => {
    // There was an ajax error so just route the user to the sign-in modal
    // and let them sign in as a Non-Partner Institution
    $('#access-control-tabs a[data-target="#sign-in-form"]').tab('show');
  };

  $('.org-sign-in').click((e) => {
    const target = $(e.target);
    $('#org-sign-in').html('');
    $.ajax({
      method: 'GET',
      url: target.attr('href'),
    }).done((data) => {
      logoSuccess(data);
    }, logoError);
    e.preventDefault();
  });

  $('#show_list').click((e) => {
    e.preventDefault();
    const target = $('#full_list');
    if (target.is('.hidden')) {
      target.removeClass('hidden').attr('aria-hidden', 'false');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST'));
    } else {
      target.addClass('hidden').attr('aria-hidden', 'true');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST'));
    }
  });

  // When the user clicks 'Go' click the corresponding link from the list
  // of all orgs
  $('#org-select-go').click((e) => {
    e.preventDefault();
    const id = $('#shib-ds_org_id').val();
    if (isString(id)) {
      const link = $(`a[data-content="${id}"]`);
      if (isObject(link)) {
        // If the org doesn't have a shib setup then display the org sign in modal
        if (link.is('.org-sign-in')) {
          link.click();
        } else {
          window.location.replace(link.attr('href'));
        }
      }
    }
  });

  // Get Started button click
  // -----------------------------------------------------
  $('#get-started').click((e) => {
    e.preventDefault();
    $('#header-signin').dropdown('toggle');
  });
});
