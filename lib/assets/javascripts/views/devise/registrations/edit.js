import ariatiseForm from '../../../utils/ariatiseForm';
import { DISABLE_ORG_COMBO_MESSAGE } from '../../../constants';
import { addMatchingPasswordValidator, togglisePasswords } from '../../../utils/passwordHelper';

$(() => {
  ariatiseForm({ selector: '#personal_details_registration_form' });
  ariatiseForm({ selector: '#password_details_registration_form' });
  ariatiseForm({ selector: '#preferences_registration_form' });
  addMatchingPasswordValidator({ selector: '#password_details_registration_form' });
  togglisePasswords({ selector: '#password_details_registration_form' });

  // Disable organisation autocomplete if the user has linked their account to Shibboleth
  if ($('.identifier-scheme #unlink-shibboleth').length > 0) {
    $('#org-controls #user_org_name').attr('disabled', true)
      .attr('data-toggle', 'tooltip')
      .attr('title', DISABLE_ORG_COMBO_MESSAGE);
    $('#org-controls .combobox-clear-button').hide();
    $('#other_org_toggle a').hide();
  }
});
