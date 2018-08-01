import * as Validator from '../../../utils/validator';
import togglisePasswords from '../../../utils/passwordHelper';

$(() => {
  Validator.enableValidations({ selector: '#user_reset_password_form' });
  togglisePasswords({ selector: '#user_reset_password_form' });
});
