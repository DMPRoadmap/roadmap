import initAutoComplete from '../../utils/autoComplete';
import ariatiseForm from '../../utils/ariatiseForm';
import { togglisePasswords } from '../../utils/passwordHelper';
import { isValidText } from '../../utils/isValidInputType';

$(() => {
  initAutoComplete();
  ariatiseForm({ selector: '#create_account_form' });
  togglisePasswords({ selector: '#create_account_form' });

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
