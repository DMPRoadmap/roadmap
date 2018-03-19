import ariatiseForm from '../../../utils/ariatiseForm';
import { isString } from '../../../utils/isType';
import { isValidPassword } from '../../../utils/isValidInputType';
import { addMatchingPasswordValidator, togglisePasswords } from '../../../utils/passwordHelper';

$(() => {
  ariatiseForm({ selector: '#personal_details_registration_form' });
  ariatiseForm({ selector: '#password_details_registration_form' });
  ariatiseForm({ selector: '#preferences_registration_form' });
  addMatchingPasswordValidator({ selector: '#password_details_registration_form' });
  togglisePasswords({ selector: '#password_details_registration_form' });

  const sensitiveInfoCheck = (event) => {
    const originalEmail = $('#original_email').val();
    const originalOrg = $('#original_org').val();
    const email = $('#personal_details_registration_form #user_email').val();
    const org = $('#personal_details_registration_form #user_org_id').val();
    const pwd = $('#password-confirmation input[name="user[current_password]"]').val();
    const orgConfirm = $('#confirm_org_change').is(':checked');
    let display = false;

    $('#email-change').addClass('hide');
    $('#org-change').addClass('hide');

    // If the Email has changed show the Password confirmation
    if (isString(originalEmail) && isString(email)) {
      if (originalEmail.toLowerCase() !== email.toLowerCase() && !isValidPassword(pwd)) {
        $('#email-change').removeClass('hide');
        display = true;
      }
    }
    // If the orginalOrg is present and the selected Org has changed, show the confirmation box
    if (isString(originalOrg) && isString(org)) {
      if (originalOrg !== org && !orgConfirm) {
        $('#org-change').removeClass('hide');
        display = true;
      }
    }
    if (display) {
      event.preventDefault();
      $('#password-confirmation').modal('show');
    }
  };

  // If the user has changed their email address display the password
  // confirmation modal on form submission
  $('#personal_details_registration_form').submit((e) => {
    sensitiveInfoCheck(e);
  });

  // Devise seems to require both the password and current_password so sync them
  // when the user enters their password in the modal
  $('#password-confirmation input[name="user[current_password]"]').change((e) => {
    $('#password-confirmation #user_password').val($(e.target).val());
  });

  // Submit the form when the user clicks the confirmation button on the modal
  $('#pwd-confirmation').click((e) => {
    $(e.target).closest('form').submit();
  });
});
