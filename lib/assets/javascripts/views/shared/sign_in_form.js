import * as Cookies from 'js-cookie';
import ariatiseForm from '../../utils/ariatiseForm';
import { isValidText } from '../../utils/isValidInputType';

$(() => {
  // Constants and methods
  const rememberEmail = $('#sign_in_form input[name="remember_email"]');
  const userEmail = $('#sign_in_form input[name="user[email]"]');
  const emailCookieKey = 'dmproadmap_email';
  const getEmailCookie = () => Cookies.get(emailCookieKey);
  const setEmailCookie = (value = null) => {
    if (value === null) {
      Cookies.remove(emailCookieKey);
    } else {
      Cookies.set(emailCookieKey, value, { expires: 14 });
    }
  };
  // Event handlers
  rememberEmail.click(() => {
    if (rememberEmail.is(':checked')) {
      setEmailCookie(userEmail.val());
    } else {
      setEmailCookie(null);
    }
  });
  userEmail.change(() => {
    if (rememberEmail.is(':checked')) {
      setEmailCookie(userEmail.val());
    }
  });
  // Initialisation
  if (isValidText(getEmailCookie())) {
    rememberEmail.attr('checked', 'checked');
    userEmail.val(getEmailCookie());
  }
  ariatiseForm({ selector: '#sign_in_form' });
});
