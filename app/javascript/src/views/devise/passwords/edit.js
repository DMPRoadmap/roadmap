import { addMatchingPasswordValidator, togglisePasswords } from '../../utils/passwordHelper';

$(() => {
  addMatchingPasswordValidator({ selector: '#user_reset_password_form' });
  togglisePasswords({ selector: '#user_reset_password_form' });
});
