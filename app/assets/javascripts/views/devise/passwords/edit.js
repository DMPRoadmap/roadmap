import ariatiseForm from '../../../utils/ariatiseForm';
import { addMatchingPasswordValidator, togglisePasswords } from '../../../utils/passwordHelper';

$(() => {
  ariatiseForm({ selector: '#user_reset_password_form' });
  addMatchingPasswordValidator({ selector: '#user_reset_password_form' });
  togglisePasswords({ selector: '#user_reset_password_form' });
});
