import toggleConditionalFields from '../utils/conditionalFields';
import { addMatchingPasswordValidator, togglisePasswords } from '../utils/passwordHelper';

$(() => {
  addMatchingPasswordValidator({ selector: 'form#edit_user' });
  togglisePasswords({ selector: '#form#edit_user' });

  // Hide or show the change password fields
  const passwordToggle = $('a.js-toggle-profile-password');
  if (passwordToggle.length > 0) {
    const toggleables = passwordToggle.closest('conditional').find('.toggleable-field');

    // If the user checks the ethical_issues field then display the other ethics fields
    if (toggleables.length > 0) {
      passwordToggle.on('click', (e) => {
        toggleConditionalFields(passwordToggle, $(toggleables[0]).css('display') === 'none');
        e.preventDefault();
      });

      toggleConditionalFields(passwordToggle, false);
    }

    // Add a handler that displays the warning message to the user after they change their
    // email address and open the password section so they can provide their current password
    const emailField = $('#user_email');
    emailField.on('change keyup', (e) => {
      const originalEmail = $('#original_email').val();
      if (originalEmail === $(e.currentTarget).val()) {
        $(emailField).parent().siblings('.email-change-warning').addClass('hide');
        toggleConditionalFields(passwordToggle, false);
      } else {
        $(emailField).parent().siblings('.email-change-warning').removeClass('hide');
        toggleConditionalFields(passwordToggle, true);
      }
    });
  }
});
