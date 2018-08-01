import togglisePasswords from '../../utils/passwordHelper';
import initMyOrgCombobox from '../shared/my_org';
import * as Validator from '../../utils/validator';

$(() => {
  const options = { selector: '#create_account_form' };
  initMyOrgCombobox(options);
  togglisePasswords(options);
  Validator.enableValidations(options);
});
