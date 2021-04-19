import { togglisePasswords } from '../../utils/passwordHelper';
import { initOrgSelection } from './my_org';

$(() => {
  const options = { selector: '#create-account-form' };
  togglisePasswords(options);
  initOrgSelection(options);
});
