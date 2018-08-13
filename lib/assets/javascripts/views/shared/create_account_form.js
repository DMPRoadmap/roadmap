import ariatiseForm from '../../utils/ariatiseForm';
import { togglisePasswords } from '../../utils/passwordHelper';
import validateOrgSelection from '../shared/my_org';
import { isValidText } from '../../utils/isValidInputType';

$(() => {
  const options = { selector: '#create-account-form' };
  ariatiseForm(options);
  togglisePasswords(options);

  $('#create_account_form').on('submit', (e) => {
    // Additional validation to force the user to choose an org or type something for other
    if (validateOrgSelection()) {
      $('#help-org').hide();
    } else {
      e.preventDefault();
      $('#help-org').show();
    }
  });
});
