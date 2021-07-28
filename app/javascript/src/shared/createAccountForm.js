import { togglisePasswords } from '../utils/passwordHelper';

$(() => {
  togglisePasswords({ selector: '#create_account_form' });

  const createAccountForm = $('#create_account_form');

  const addValidationError = (field) => field.addClass('has-error');
  const removeValidationError = (field) => field.removeClass('has-error');

  const validateFormFields = (form) => {
    let anyInvalid = false;
    if (form.length > 0) {
      form.find('input[aria-required="true"]').each((_idx, el) => {
        const field = $(el);

        switch (field.attr('id')) {
        case 'org_index_name': {
          // We need to detemine if the user selected an item from the Org autocomplete
          // or provided a manually entered Org name
          const userEnteredField = form.find('#org_index_user_entered_name');
          const warningBlock = form.find('.autocomplete-warning');

          if (field.val().trim().length > 0 && warningBlock.hasClass('hide')) {
            removeValidationError(field);
          } else if (userEnteredField !== undefined && userEnteredField.val().trim().length > 0) {
            removeValidationError(field);
          } else {
            anyInvalid = true;
            addValidationError(field);
          }
          break;
        }
        case 'new_user_accept_terms': {
          if (!field.prop('checked')) {
            anyInvalid = true;
            addValidationError(field);
          } else {
            removeValidationError(field);
          }
          break;
        }
        default: {
          // All other text fields
          if (field.val().trim().length <= 0) {
            anyInvalid = true;
            addValidationError(field);
          } else {
            removeValidationError(field);
          }
          break;
        }
        }
      });
    }
    return !anyInvalid;
  };

  if (createAccountForm.length > 0) {
    const submit = createAccountForm.find('button[type="submit"]');

    // Perform client side form validation. If any required fields are missing then
    // cancel the form submission
    submit.on('click', (e) => {
      validateFormFields(createAccountForm);
      if (createAccountForm.find('.has-error').length > 0) {
        submit.siblings('.form-error-msg').removeClass('hide');
        e.preventDefault();
      }
    });
  }

  if ($('#sign-in-tab').length > 0) {
    const shibSignInForm = $('#new_org');
    if (shibSignInForm.length > 0) {
      const submit = shibSignInForm.find('button[type="submit"]');

      // Perform client side form validation. If any required fields are missing then
      // cancel the form submission
      submit.on('click', (e) => {
        validateFormFields(shibSignInForm);

        if (shibSignInForm.find('.has-error').length > 0) {
          submit.siblings('.form-error-msg').removeClass('hide');
          e.preventDefault();
        }
      });
    }
  }
});
