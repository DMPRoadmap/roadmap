import ariatiseForm from '../../../utils/ariatiseForm';
import { addMatchingPasswordValidator, togglisePasswords } from '../../../utils/passwordHelper';

$(() => {
  ariatiseForm({ selector: '#personal_details_registration_form' });
  ariatiseForm({ selector: '#password_details_registration_form' });
  ariatiseForm({ selector: '#preferences_registration_form' });
  addMatchingPasswordValidator({ selector: '#password_details_registration_form' });
  togglisePasswords({ selector: '#password_details_registration_form' });
});
