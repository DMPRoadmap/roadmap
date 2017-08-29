import ariatiseForm from '../../utils/ariatiseForm';
import { addMatchingPasswordValidator, togglisePasswords } from '../../utils/passwordHelper';
import { SHOW_SELECT_ORG_MESSAGE, SHOW_OTHER_ORG_MESSAGE } from '../../constants';

/*
  Ariatise all of the devise forms
*/
if ($ && document) {
  $(document).ready(() => {
    ariatiseForm({ selector: '#sign_in_form' });
    ariatiseForm({ selector: '#create_account_form' });
    ariatiseForm({ selector: '#user_request_reset_password_form' });
    ariatiseForm({ selector: '#user_reset_password_form' });
    ariatiseForm({ selector: '#invitation_create_account_form' });

    addMatchingPasswordValidator({ selector: '#user_reset_password_form' });

    togglisePasswords({ selector: '#sign_in_form' });
    togglisePasswords({ selector: '#create_account_form' });
    togglisePasswords({ selector: '#user_reset_password_form' });

    $('#other_org_link').click((e) => {
      e.preventDefault();
      const other = $('#user_other_organisation');
      const selector = $('.combobox-container');
      if ($(other).css('display') === 'none') {
        $('#other_org_link').text(SHOW_SELECT_ORG_MESSAGE);
        $(selector).hide();
        $(other).show();
      } else {
        $('#other_org_link').text(SHOW_OTHER_ORG_MESSAGE);
        $(selector).show();
        $(other).val('').hide();
      }
    });
  });
}
