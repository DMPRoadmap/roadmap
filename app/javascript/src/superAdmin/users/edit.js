import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../../utils/autoComplete';

$(() => {
  const updateMergeConfirmation = (userSelect) => {
    // update the confirmation dialogue with the selected user's email address
    const editingUserEmail = $('#superadmin_user_email').val();
    const chosenUserEmail = userSelect.find('option:selected').text();
    const submitButton = userSelect.closest('form').find(':submit');
    submitButton.attr('data-confirm',
      `Confirm Account Merge: The account for ${editingUserEmail} will be merged with ${chosenUserEmail}.
      All plans and account information for ${chosenUserEmail} will now be accessible via ${editingUserEmail}.
      The account for ${chosenUserEmail} will then be destroyed.`);
  };

  $('#merge_form').on('ajax:success', (e) => {
    const data = e.detail[0];
    // replace the search form with the merge form
    $('#merge_form_container').html(data.form);
    const userSelect = $('#merge_id');
    userSelect.on('change', () => updateMergeConfirmation(userSelect));
    userSelect.change();
  });

  if ($('#super-admin-user-org-controls').length > 0) {
    initAutocomplete('#super-admin-user-org-controls .autocomplete');
    // Scrub out the large arrays of data used for the Org Selector JS so that they
    // are not a part of the form submissiomn
    scrubOrgSelectionParamsOnSubmit('#super_admin_user_edit');
  }
});
