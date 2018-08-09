import ariatiseForm from '../../utils/ariatiseForm';
import { togglisePasswords } from '../../utils/passwordHelper';
import initMyOrgCombobox from '../shared/my_org';

$(() => {
  const options = { selector: '#create-account-form' };
  initMyOrgCombobox(options);
  ariatiseForm(options);
  togglisePasswords(options);
});
