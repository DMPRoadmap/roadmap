import ariatiseForm from '../../utils/ariatiseForm';
import addMatchingPasswordValidator from '../../utils/matchingPasswordValidator';

/*
  Ariatise all of the devise forms and attach a
  @param value to check
  @return true or false
*/
if (document) {
  document.addEventListener('DOMContentLoaded', () => {
    ariatiseForm({ selector: '#sign_in_form' });
    ariatiseForm({ selector: '#create_account_form' });
    ariatiseForm({ selector: '#user_request_reset_password_form' });
    ariatiseForm({ selector: '#user_reset_password_form' });
    ariatiseForm({ selector: '#invitation_create_account_form' });

    addMatchingPasswordValidator({ selector: '#user_reset_password_form' });
  });
}
