import { togglisePasswords } from '../../utils/passwordHelper';
import { initOrgSelection, validateOrgSelection } from './my_org';

$(() => {
  const options = { selector: '#create-account-form' };
  togglisePasswords(options);
  initOrgSelection(options);

  $('#create_account_form').on('submit', (e) => {
    // Additional validation to force the user to choose an org or type something for other
    if (!validateOrgSelection(options)) {
      e.preventDefault();
    }
  });
});
