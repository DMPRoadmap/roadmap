import ariatiseForm from '../../utils/ariatiseForm';
import { togglisePasswords } from '../../utils/passwordHelper';
import initMyOrgCombobox from '../shared/my_org';
import { isValidText } from '../../utils/isValidInputType';

$(() => {
  const options = { selector: '#create-account-form' };
  initMyOrgCombobox(options);
  ariatiseForm(options);
  togglisePasswords(options);

  $('#create_account_form').on('submit', (e) => {
    // Additional validation to force the user to choose an org or type something for other
    const orgId = $('[name="user[org_id]"]');
    const otherOrg = $('[name="user[other_organisation]"]');
    if (isValidText(orgId.val()) || isValidText(otherOrg.val())) {
      $('#help-org').hide();
    } else {
      e.preventDefault();
      $('#help-org').show();
    }
  });
});
