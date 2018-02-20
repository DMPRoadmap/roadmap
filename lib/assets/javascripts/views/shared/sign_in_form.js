import * as Cookies from 'js-cookie';
import ariatiseForm from '../../utils/ariatiseForm';
import { togglisePasswords } from '../../utils/passwordHelper';

$(() => {
  ariatiseForm({ selector: '#sign_in_form' });
  togglisePasswords({ selector: '#sign_in_form' });

  const email = Cookies.get('dmproadmap_email');

  // If the user's email was stored in the browser's cookies the pre-populate the field
  if (email && email !== '') {
    $('#sign_in_form #remember_email').attr('checked', 'checked');
    $('#sign_in_form #user_email').val(email);
  }

  // When the user checks the 'remember email' box store the value in the browser storage
  $('#sign_in_form #remember_email').click((e) => {
    if ($(e.currentTarget).is(':checked')) {
      Cookies.set('dmproadmap_email', $('#sign_in_form #user_email').val(), { expires: 14 });
    } else {
      Cookies.remove('dmproadmap_email');
    }
  });

  // If the email is changed and the user has asked to remember it update the browser storage
  $('#sign_in_form #user_email').change((e) => {
    if ($('#sign_in_form #remember_email').is(':checked')) {
      Cookies.set('dmproadmap_email', $(e.currentTarget).val(), { expires: 14 });
    }
  });
});
