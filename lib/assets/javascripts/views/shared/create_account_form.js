import ariatiseForm from '../../utils/ariatiseForm';
import { togglisePasswords } from '../../utils/passwordHelper';
import initMyOrgCombobox from '../shared/my_org';

$(() => {
  ariatiseForm({ selector: '#create_account_form' });
  togglisePasswords({ selector: '#create_account_form' });
  initMyOrgCombobox({ selector: '#create-account-form' });
});
