import { initOrgSelection, validateOrgSelection } from '../../shared/my_org';

$(() => {
  const options = { selector: '#super_admin_user_edit' };
  initOrgSelection(options);

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

  $('#super_admin_user_edit').on('submit', (e) => {
    // Additional validation to force the user to choose an org or type something for other
    if (!validateOrgSelection(options)) {
      e.preventDefault();
    }
  });

  $('#merge_form').on('ajax:success', (e, data) => {
    // replace the search form with the merge form
    $('#merge_form_container').html(data.form);
    const userSelect = $('#merge_id');
    userSelect.on('change', () => updateMergeConfirmation(userSelect));
    userSelect.change();
  });
});
